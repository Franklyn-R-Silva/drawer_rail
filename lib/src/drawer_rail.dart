import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'animated_press_card.dart';
import 'drawer_model.dart';
import 'drawer_rail_controller.dart';
import 'drawer_rail_labels.dart';
import 'drawer_rail_theme.dart';

/// Signature for building the optional header/footer of a [DrawerRail].
///
/// [collapsed] is `true` when the drawer is showing the narrow icon rail, so
/// the builder can return a compact variant (for example an avatar only)
/// instead of the full-width content.
typedef DrawerRailSlotBuilder = Widget Function(
  BuildContext context,
  bool collapsed,
);

/// A collapsible side navigation drawer.
///
/// It has two states, both themed by the ambient app theme rather than a fixed
/// palette:
///
/// * an **expanded panel** with an optional search field, uppercase section
///   labels, a selected pill, badges and inline-expandable groups; and
/// * a narrow **icon rail** where groups open as flyout menus.
///
/// State (collapsed, selection, expanded groups) lives in a
/// [DrawerRailController] you own, so the widget has no dependency on any
/// state-management package. Styling comes from an optional [DrawerRailTheme],
/// and user-facing strings from [DrawerRailLabels].
///
/// ```dart
/// DrawerRail(
///   controller: _controller,
///   entries: [
///     const DrawerSection('MENU'),
///     DrawerLink(
///       id: 'dashboard',
///       icon: Icons.dashboard_outlined,
///       label: 'Dashboard',
///       onTap: (context) => _open(const DashboardPage()),
///     ),
///   ],
/// );
/// ```
///
/// See also:
///
///  * [DrawerRailController], which holds the mutable state.
///  * [DrawerRailTheme], for visual customization.
///  * [DrawerEntry] and its subtypes, which describe the content.
class DrawerRail extends StatefulWidget {
  /// Creates a collapsible navigation drawer.
  const DrawerRail({
    super.key,
    required this.controller,
    required this.entries,
    this.theme = const DrawerRailTheme(),
    this.labels = const DrawerRailLabels(),
    this.showSearch = true,
    this.showCollapseButton = true,
    this.showFooterDivider = true,
    this.headerBuilder,
    this.footerBuilder,
    this.searchDecoration,
    this.selectOnTap = true,
  });

  /// Holds and mutates the drawer's runtime state. Must be kept alive by the
  /// caller and disposed when no longer needed.
  final DrawerRailController controller;

  /// The declarative content: sections, links and expandable groups, in order.
  final List<DrawerEntry> entries;

  /// Visual configuration. Defaults to a theme derived from the ambient
  /// [ColorScheme].
  final DrawerRailTheme theme;

  /// User-facing strings (search hint, tooltips, empty state). English by
  /// default.
  final DrawerRailLabels labels;

  /// Whether to show the built-in search field / rail search button.
  final bool showSearch;

  /// Whether to show the built-in collapse/expand toggle button.
  final bool showCollapseButton;

  /// Whether to draw a divider above the footer. Defaults to `true`.
  final bool showFooterDivider;

  /// Optional content shown above the search field (for example a user
  /// profile). Rebuilt whenever the collapsed state changes.
  final DrawerRailSlotBuilder? headerBuilder;

  /// Optional content shown below the menu, separated by a divider (for example
  /// a dark-mode toggle or a sign-out button).
  final DrawerRailSlotBuilder? footerBuilder;

  /// Overrides the decoration of the built-in search field. When null, a
  /// filled, rounded field derived from the theme is used. The controller's
  /// hint and clear button are applied on top, so you rarely need to set the
  /// hint or suffix here.
  final InputDecoration? searchDecoration;

  /// Whether tapping a link selects it before running its `onTap`. Defaults to
  /// `true`.
  ///
  /// Set it to `false` when the app drives the selection itself — from the
  /// current route, typically, by calling [DrawerRailController.select] as the
  /// location changes. Selecting on tap fights that: a link that pushes a
  /// route marks itself in the menu of the screen underneath, which stays
  /// mounted below the new one and is still showing the wrong item once the
  /// user comes back.
  final bool selectOnTap;

  @override
  State<DrawerRail> createState() => _DrawerRailState();
}

class _DrawerRailState extends State<DrawerRail> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  // Hover state. Every timer here is cancelled in dispose and every callback
  // bails out when the state is gone, so a pointer leaving right as the drawer
  // is torn down can never call setState on a dead State.
  Timer? _peekTimer;
  Timer? _linkTimer;

  // Groups and flyouts get a timer *per id*. A single shared timer used to lose
  // the pending close of the group the pointer had just left the moment it
  // entered the next one, stranding the first one open.
  final _groupTimers = <String, Timer>{};
  final _menuTimers = <String, Timer>{};

  /// The groups hover opened. Only these are closed again when the pointer
  /// leaves — a group the user opened by clicking stays open.
  ///
  /// A set rather than a single id: sweeping across several groups can leave
  /// more than one of them mid-close at the same time.
  final _hoverOpenedGroupIds = <String>{};

  /// The rail flyouts hover opened — the flyout counterpart of
  /// [_hoverOpenedGroupIds]. Only these close again when the pointer leaves.
  final _hoverOpenedMenuIds = <String>{};

  /// One [MenuController] per group id, so the flyout can be driven from both
  /// the rail button and the menu panel.
  final _menuControllers = <String, MenuController>{};

  /// The last *pinned* collapsed state seen, so the search can be cleared on
  /// the edge rather than on every notification.
  late bool _wasPinnedCollapsed;

  /// The last [DrawerRailController.hoverHeld] seen, so a release can be told
  /// apart from every other notification.
  late bool _wasHeld;

  /// Whether the pointer is over the drawer right now.
  bool _pointerInside = false;

  /// Whether a hover close was put off — by a focused search field or by
  /// [DrawerRailController.hoverHeld] — so it can run once nothing holds the
  /// drawer any more. Only a close that really was put off runs: a keyboard
  /// user tabbing out of the field, with the pointer never having left the
  /// drawer (or never been on it), must not close anything.
  bool _closeDeferred = false;

  /// Whether the panel is open only because the rail's search button opened
  /// it, and whether doing so undid an auto-hide that must come back after.
  bool _searchPeek = false;
  bool _searchPeekUnhid = false;

  /// The theme of the last build, for the deferred close, which runs outside
  /// of one.
  ResolvedDrawerRailTheme? _lastTheme;

  @override
  void initState() {
    super.initState();
    _wasPinnedCollapsed = widget.controller.collapsed;
    _wasHeld = widget.controller.hoverHeld;
    widget.controller.addListener(_onControllerChanged);
    _searchFocus.addListener(_runDeferredClose);
  }

  /// Whether something is keeping the drawer open against hover: someone
  /// typing in the search field, or the app holding it via
  /// [DrawerRailController.setHoverHold].
  bool get _heldOpen => _searchFocus.hasFocus || _controller.hoverHeld;

  /// Runs the hover close that [_onDrawerHover] put off, once nothing holds the
  /// drawer open any more and the pointer is still away.
  void _runDeferredClose() {
    final theme = _lastTheme;
    if (!mounted || theme == null || !_closeDeferred) return;
    if (_pointerInside || _heldOpen) return;
    _closeDeferred = false;
    _onDrawerHover(false, theme);
  }

  /// Drops a running search when the user pins the drawer collapsed, and runs
  /// a close put off by [DrawerRailController.setHoverHold] once released.
  ///
  /// The search field is not on screen in the rail, so a query left running
  /// there would silently filter the panel the next time it is expanded, with
  /// nothing on screen to explain the missing entries. A hover peek or
  /// auto-hide is deliberately *not* treated as collapsing: those are transient
  /// and must not throw away what someone typed.
  void _onControllerChanged() {
    final held = _controller.hoverHeld;
    if (held != _wasHeld) {
      _wasHeld = held;
      if (!held) _runDeferredClose();
    }
    final pinned = widget.controller.collapsed;
    if (pinned == _wasPinnedCollapsed) return;
    _wasPinnedCollapsed = pinned;
    if (pinned && _query.isNotEmpty) _clearSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    if (mounted) setState(() => _query = '');
  }

  @override
  void didUpdateWidget(DrawerRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller.removeListener(_onControllerChanged);
      // The old controller is being let go mid-peek just as surely as on
      // teardown, so it gets the same clean hand-back.
      _releaseHoverState(oldWidget.controller);
      widget.controller.addListener(_onControllerChanged);
      _wasPinnedCollapsed = widget.controller.collapsed;
      _wasHeld = widget.controller.hoverHeld;
      // Whatever was in flight belonged to the old controller; applied to the
      // new one it would hide or close a drawer that never opened that way.
      _searchPeek = false;
      _searchPeekUnhid = false;
      _closeDeferred = false;
    }
    if (identical(widget.entries, oldWidget.entries)) return;
    // Entries can be rebuilt at will, so forget the per-group bookkeeping of
    // groups that no longer exist instead of growing these maps forever.
    final ids = {
      for (final e in widget.entries)
        if (e is DrawerGroup) e.id,
    };
    _menuControllers.removeWhere((id, _) => !ids.contains(id));
    _groupTimers.removeWhere((id, timer) {
      if (ids.contains(id)) return false;
      timer.cancel();
      return true;
    });
    _menuTimers.removeWhere((id, timer) {
      if (ids.contains(id)) return false;
      timer.cancel();
      return true;
    });
    _hoverOpenedGroupIds.removeWhere((id) => !ids.contains(id));
    _hoverOpenedMenuIds.removeWhere((id) => !ids.contains(id));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    // Hover state belongs to this widget, not to the caller. A drawer torn down
    // mid-peek used to leave the controller claiming to be peeked open for
    // good, so a controller that outlives the drawer — one hoisted above the
    // navigator, say — reported the wrong railCollapsed from then on.
    _releaseHoverState(widget.controller);
    _peekTimer?.cancel();
    _linkTimer?.cancel();
    for (final timer in [..._groupTimers.values, ..._menuTimers.values]) {
      timer.cancel();
    }
    _searchController.dispose();
    _searchFocus
      ..removeListener(_runDeferredClose)
      ..dispose();
    super.dispose();
  }

  /// Clears the hover state this widget left on [controller], once the frame
  /// is over.
  ///
  /// Not on the spot: this runs from [dispose] and [didUpdateWidget], where the
  /// framework has the tree locked or mid-build, and the reset notifies — so
  /// any shell that rebuilds on the controller (the usual way to size a gutter
  /// beside the drawer) threw "setState() called when widget tree was locked"
  /// the moment the drawer left the tree mid-peek.
  void _releaseHoverState(DrawerRailController controller) {
    if (!controller.hoverPeeking &&
        !controller.hoverHidden &&
        !controller.hoverHeld) {
      return;
    }
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => controller.resetHoverState())
      ..ensureVisualUpdate();
  }

  DrawerRailController get _controller => widget.controller;

  // ---- Hover ---------------------------------------------------------------

  /// Runs [action] after [delay], replacing whatever was pending on the same
  /// slot. Returns the new timer so the caller can store it.
  Timer _after(Timer? pending, Duration delay, VoidCallback action) {
    pending?.cancel();
    return Timer(delay, () {
      if (mounted) action();
    });
  }

  /// The per-id variant of [_after]: each group keeps its own slot in [timers],
  /// so a pending close for one group is never cancelled by another group's
  /// pending open.
  void _afterFor(
    Map<String, Timer> timers,
    String id,
    Duration delay,
    VoidCallback action,
  ) {
    timers[id] = _after(timers[id], delay, () {
      timers.remove(id);
      action();
    });
  }

  /// Pins the collapsed state from an explicit user action, dropping any hover
  /// peek in flight so a pending timer cannot undo the click a frame later.
  void _pinCollapsed(bool value) {
    _peekTimer?.cancel();
    _searchPeek = false;
    _controller.setCollapsed(value);
  }

  /// Opens the panel from the rail's search button for the length of a search
  /// — the transient equivalent of a hover peek — and focuses the field.
  ///
  /// It used to *pin* the panel open, so searching from a rail the user had
  /// pinned collapsed silently rewrote that preference: an app persisting
  /// [DrawerRailController.collapsed] saved "expanded" because someone looked
  /// something up.
  void _openSearchFromRail() {
    _peekTimer?.cancel();
    _searchPeek = true;
    _searchPeekUnhid = _controller.hoverHidden;
    _controller.setHoverHidden(false);
    if (_controller.collapsed) _controller.setHoverPeek(true);
    // The drawer can leave the tree before that frame ends (the tap
    // navigated, say), and the focus node is disposed with it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  /// Ends a search the rail's button opened — a result was chosen, or a tap
  /// landed outside the drawer — and puts back the rail the user pinned.
  void _endSearchPeek() {
    if (!_searchPeek) return;
    // An overlay the app holds the drawer open for — a header menu, say — is
    // drawn outside the drawer, so a tap inside it reads as a tap outside.
    // While held, that is not the user leaving the search.
    if (_controller.hoverHeld) return;
    _searchPeek = false;
    // Under hover, a pointer still on the drawer owns the close from here, just
    // as for a peek it opened itself.
    final hover = _lastTheme?.railTrigger == DrawerActivationMode.hover;
    if (hover && _pointerInside) return;
    _peekTimer?.cancel();
    _controller.setHoverPeek(false);
    if (_searchPeekUnhid && !_controller.collapsed) {
      _controller.setHoverHidden(true);
    }
  }

  /// (A) Pointer entering/leaving the drawer opens or closes it.
  ///
  /// Entering always reveals the panel — either by peeking a pinned-collapsed
  /// rail or by undoing a previous auto-hide. Leaving reverses whichever of the
  /// two happened, and with `railAutoCollapse` also hides a drawer the user
  /// left expanded.
  void _onDrawerHover(bool entered, ResolvedDrawerRailTheme theme) {
    _pointerInside = entered;
    if (entered) _closeDeferred = false;
    if (theme.railTrigger != DrawerActivationMode.hover) return;
    // Someone typing in the search field, or working in an overlay the app
    // holds the drawer open for, is still using it wherever the pointer has
    // drifted: closing it pulled the field — or the menu's anchor — out from
    // under them. The close waits until nothing holds the drawer instead.
    if (!entered && _heldOpen) {
      _peekTimer?.cancel();
      _closeDeferred = true;
      return;
    }
    final pinnedOpen = !_controller.collapsed;
    if (!entered && pinnedOpen && !theme.railAutoCollapse) return;

    // More is at stake when closing a panel the user pinned open, so that exit
    // waits longer than an ordinary peek's.
    final delay = entered
        ? theme.hoverOpenDelay
        : (pinnedOpen ? theme.hoverAutoCollapseDelay : theme.hoverCloseDelay);

    _peekTimer = _after(_peekTimer, delay, () {
      if (entered) {
        _controller.setHoverHidden(false);
        if (_controller.collapsed) _controller.setHoverPeek(true);
        return;
      }
      // Hover has closed it, so a search the rail button opened is over too.
      _searchPeek = false;
      _controller.setHoverPeek(false);
      if (pinnedOpen) _controller.setHoverHidden(true);
      // A group hover opened inside the panel must not still be sitting open
      // the next time it is revealed.
      _closeHoverOpenedGroups();
    });
  }

  /// Closes every group hover opened and forgets them. A group the user clicked
  /// open is left alone.
  void _closeHoverOpenedGroups() {
    if (_hoverOpenedGroupIds.isEmpty) return;
    for (final id in _hoverOpenedGroupIds.toList()) {
      _groupTimers.remove(id)?.cancel();
      _controller.setGroupExpanded(id, false);
    }
    _hoverOpenedGroupIds.clear();
  }

  /// (C) Pointer entering/leaving an inline group in the expanded panel.
  void _onGroupHover(
    bool entered,
    DrawerGroup group,
    ResolvedDrawerRailTheme theme,
  ) {
    if (theme.groupTrigger != DrawerActivationMode.hover) return;
    _afterFor(
      _groupTimers,
      group.id,
      entered ? theme.hoverOpenDelay : theme.hoverCloseDelay,
      () {
        if (entered) {
          if (_controller.isGroupExpanded(group.id)) return;
          _hoverOpenedGroupIds.add(group.id);
          _controller.setGroupExpanded(group.id, true);
        } else if (_hoverOpenedGroupIds.remove(group.id)) {
          _controller.setGroupExpanded(group.id, false);
        }
      },
    );
  }

  /// (B) Pointer entering/leaving a rail group button or its flyout panel. The
  /// close is delayed so crossing the gap from button to overlay — which fires
  /// an exit — does not slam the menu shut.
  void _onMenuHover(
    bool entered,
    DrawerGroup group,
    MenuController menu,
    ResolvedDrawerRailTheme theme,
  ) {
    if (theme.groupTrigger != DrawerActivationMode.hover) return;
    _afterFor(
      _menuTimers,
      group.id,
      entered ? theme.hoverOpenDelay : theme.hoverCloseDelay,
      () {
        if (entered) {
          if (menu.isOpen) return;
          final opened = _openMenu(
            group.id,
            menu,
            hasItems: group.children.isNotEmpty,
          );
          if (opened) _hoverOpenedMenuIds.add(group.id);
        } else if (_hoverOpenedMenuIds.remove(group.id)) {
          // Only what hover opened, as with inline groups: a flyout the user
          // clicked open used to slam shut the moment the pointer left it.
          menu.close();
        }
      },
    );
  }

  /// Opens [menu] and shuts every other flyout at once, so sliding down the
  /// rail never leaves a trail of overlays hanging over the app. Returns
  /// whether it opened anything.
  ///
  /// A group with no children opens nothing: an empty flyout is a bare sliver
  /// of surface that the user then has to dismiss.
  bool _openMenu(
    String groupId,
    MenuController menu, {
    required bool hasItems,
  }) {
    if (!hasItems) return false;
    for (final entry in _menuControllers.entries) {
      if (entry.key == groupId) continue;
      _menuTimers.remove(entry.key)?.cancel();
      _hoverOpenedMenuIds.remove(entry.key);
      if (entry.value.isOpen) entry.value.close();
    }
    menu.open();
    return true;
  }

  /// (D) Pointer resting on a link activates it, navigation included.
  void _onLinkHover(
    bool entered,
    DrawerLink link,
    ResolvedDrawerRailTheme theme,
  ) {
    if (theme.linkTrigger != DrawerActivationMode.hover) return;
    _linkTimer?.cancel();
    // Leaving only ever cancels: a link that was not dwelled on long enough
    // must not fire on the way out.
    if (!entered) return;
    _linkTimer = _after(null, theme.hoverSelectDelay, () => _openLink(link));
  }

  /// Diacritic-insensitive `contains`, so "acao" matches "Ação".
  bool _matches(String text) {
    if (_query.isEmpty) return true;
    String norm(String s) {
      s = s.toLowerCase();
      const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
      const to = 'aaaaaeeeeiiiiooooouuuucn';
      final b = StringBuffer();
      for (final ch in s.split('')) {
        final i = from.indexOf(ch);
        b.write(i >= 0 ? to[i] : ch);
      }
      return b.toString();
    }

    return norm(text).contains(norm(_query));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Honour the platform's "reduce motion" setting: durations collapse to
    // zero, so the drawer snaps rather than slides.
    final theme = widget.theme.resolve(
      scheme,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
    _lastTheme = theme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // The rendered state, which a hover peek widens without touching the
        // pinned `collapsed` the caller persists.
        final collapsed = _controller.railCollapsed;
        final width = collapsed ? theme.railWidth : theme.expandedWidth;

        // A tap anywhere else ends a search the rail's button opened.
        return TapRegion(
          onTapOutside: (_) => _endSearchPeek(),
          child: MouseRegion(
            // The drawer's own chrome is inert, so the pointer reverts to an
            // arrow the moment it leaves an item instead of carrying the hand
            // cursor across the background.
            cursor: theme.inertCursor,
            onEnter: (_) => _onDrawerHover(true, theme),
            onExit: (_) => _onDrawerHover(false, theme),
            child: AnimatedContainer(
              duration: theme.animationDuration,
              curve: theme.animationCurve,
              width: width,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: theme.position == DrawerRailPosition.right
                    ? BorderRadius.horizontal(
                        left: Radius.circular(theme.borderRadius),
                      )
                    : BorderRadius.horizontal(
                        right: Radius.circular(theme.borderRadius),
                      ),
                boxShadow: theme.shadow,
              ),
              // Lay content out at its *target* width regardless of the
              // animating container width, so the tween never squeezes it (no
              // mid-animation ellipsis, no items sliding sideways); the container
              // clips the reveal. `minWidth: 0` is what makes that true — without
              // it the tight width of the animating container is inherited as a
              // floor and the content is laid out at the animating width after
              // all, then centred.
              child: OverflowBox(
                alignment: theme.position == DrawerRailPosition.right
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                minWidth: 0,
                maxWidth: double.infinity,
                child: SizedBox(
                  width: width,
                  child: Material(
                    type: MaterialType.transparency,
                    // Only the outer edge touches the screen's edge. Honouring
                    // the inset on the inner one too — a landscape notch on the
                    // far side, say — knocked the rail icons off centre in a
                    // rail barely wider than the inset itself.
                    child: SafeArea(
                      left: theme.position == DrawerRailPosition.left,
                      right: theme.position == DrawerRailPosition.right,
                      // Navigation is not text to be copied. Under an app-wide
                      // SelectionArea, a drag across the drawer used to leave a
                      // selection highlight trailing over every label.
                      child: SelectionContainer.disabled(
                        child: Column(
                          children: [
                            _buildHeader(collapsed, theme),
                            if (widget.showSearch)
                              _buildSearch(collapsed, theme),
                            Expanded(child: _buildMenu(collapsed, theme)),
                            if (widget.footerBuilder != null) ...[
                              if (widget.showFooterDivider)
                                Divider(height: 1, color: theme.dividerColor),
                              widget.footerBuilder!(context, collapsed),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---- Header --------------------------------------------------------------

  Widget _buildHeader(bool collapsed, ResolvedDrawerRailTheme theme) {
    final header = widget.headerBuilder?.call(context, collapsed);
    if (!widget.showCollapseButton && header == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: collapsed
          ? const EdgeInsets.symmetric(vertical: 12)
          : const EdgeInsets.fromLTRB(16, 12, 8, 8),
      // One Flex that turns on its side, rather than a Column swapped for a
      // Row: the header keeps its place in the tree across a collapse, so
      // whatever state it holds survives the drawer changing shape. Apps had to
      // pin a GlobalKey on a header menu because the swap tore it down — and
      // closed it — the moment a hover peek ended.
      child: Flex(
        direction: collapsed ? Axis.vertical : Axis.horizontal,
        mainAxisSize: collapsed ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Flexible(
            // Flex 0 lays the header out at its own size in the rail; in the
            // panel it takes the room left of the button.
            flex: collapsed ? 0 : 1,
            fit: FlexFit.tight,
            child: header ?? const SizedBox.shrink(),
          ),
          if (widget.showCollapseButton)
            IconButton(
              tooltip: collapsed
                  ? widget.labels.expandTooltip
                  : widget.labels.collapseTooltip,
              color: theme.mutedColor,
              icon: Icon(collapsed ? theme.expandIcon : theme.collapseIcon),
              onPressed: () => _pinCollapsed(!collapsed),
            ),
        ],
      ),
    );
  }

  // ---- Search --------------------------------------------------------------

  Widget _buildSearch(bool collapsed, ResolvedDrawerRailTheme theme) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: IconButton(
          tooltip: widget.labels.searchTooltip,
          color: theme.mutedColor,
          icon: Icon(theme.searchIcon),
          onPressed: _openSearchFromRail,
        ),
      );
    }
    final base = widget.searchDecoration ??
        InputDecoration(
          isDense: true,
          prefixIcon: Icon(
            theme.searchIcon,
            size: theme.iconSize,
            color: theme.mutedColor,
          ),
          filled: true,
          fillColor: theme.searchFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.itemBorderRadius),
            borderSide: BorderSide.none,
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        // Typed text follows the labels rather than the ambient text theme,
        // which on a dark drawer in a light app came out dark on dark.
        style: TextStyle(color: theme.labelColor),
        decoration: base.copyWith(
          hintText: base.hintText ?? widget.labels.searchHint,
          hintStyle: base.hintStyle ?? TextStyle(color: theme.mutedColor),
          suffixIcon: _query.isEmpty
              ? base.suffixIcon
              : IconButton(
                  color: theme.mutedColor,
                  icon: Icon(theme.clearSearchIcon, size: 18),
                  onPressed: _clearSearch,
                ),
        ),
      ),
    );
  }

  // ---- Menu ----------------------------------------------------------------

  Widget _buildMenu(bool collapsed, ResolvedDrawerRailTheme theme) {
    final selected = _controller.selectedId;

    // Search mode: flatten to matching links (sections/group headers dropped).
    if (_query.isNotEmpty && !collapsed) {
      final matches = <DrawerLink>[];
      for (final e in widget.entries) {
        if (e is DrawerLink && _matches(e.label)) {
          matches.add(e);
        } else if (e is DrawerGroup) {
          // A group that matches by its own name offers all of its children:
          // searching "Reports" used to come back empty unless a child happened
          // to carry the word too.
          matches.addAll(
            _matches(e.label)
                ? e.children
                : e.children.where((c) => _matches(c.label)),
          );
        }
      }
      if (matches.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              widget.labels.noResults,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.mutedColor),
            ),
          ),
        );
      }
      return ListView(
        padding: theme.contentPadding,
        children: [
          for (final link in matches)
            _linkTile(link, selected == link.id, theme, indent: false),
        ],
      );
    }

    return ListView(
      padding: theme.contentPadding,
      children: [
        for (final e in widget.entries) _entry(e, collapsed, selected, theme),
      ],
    );
  }

  Widget _entry(
    DrawerEntry e,
    bool collapsed,
    String? selected,
    ResolvedDrawerRailTheme theme,
  ) {
    return switch (e) {
      DrawerSection(:final label) => collapsed
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Divider(height: 1, color: theme.dividerColor),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
              child: Text(
                theme.sectionUppercase ? label.toUpperCase() : label,
                style: theme.sectionTextStyle,
              ),
            ),
      DrawerLink() => collapsed
          ? _railLink(e, selected == e.id, theme)
          : _linkTile(e, selected == e.id, theme, indent: false),
      DrawerGroup() => collapsed
          ? _railGroup(e, selected, theme)
          : _groupTile(e, selected, theme),
    };
  }

  // ---- Expanded tiles ------------------------------------------------------

  Widget _linkTile(
    DrawerLink link,
    bool isSelected,
    ResolvedDrawerRailTheme theme, {
    required bool indent,
  }) {
    // Icon and label are tinted separately: the icon used to take labelColor
    // too, so iconColor reached group headers and the rail but never a link in
    // the panel.
    final Color iconFg;
    final Color fg;
    if (isSelected) {
      iconFg = fg = theme.onSelectedColor;
    } else if (link.danger) {
      iconFg = fg = theme.errorColor;
    } else {
      iconFg = theme.iconColor;
      fg = theme.labelColor;
    }
    final baseStyle =
        isSelected ? theme.selectedLabelTextStyle : theme.labelTextStyle;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 2,
        left: indent ? theme.groupChildIndent : 0,
      ),
      child: MouseRegion(
        onEnter: (_) => _onLinkHover(true, link, theme),
        onExit: (_) => _onLinkHover(false, link, theme),
        child: AnimatedPressCard(
          onTap: () => _openLink(link),
          pressedScale: theme.pressedScale,
          pressAnimationDuration: theme.pressAnimationDuration,
          hoverEffect: theme.hoverEffect,
          hoverShadowColor: theme.hoverShadowColor,
          hoverHighlightColor: theme.hoverHighlightColor,
          hoverAnimationDuration: theme.hoverAnimationDuration,
          hoverAnimationCurve: theme.hoverAnimationCurve,
          clickableCursor: theme.clickableCursor,
          inertCursor: theme.inertCursor,
          focusColor: theme.focusColor,
          surfaceColor: theme.backgroundColor,
          baseColor: isSelected ? theme.selectedColor : Colors.transparent,
          borderRadius:
              BorderRadius.all(Radius.circular(theme.itemBorderRadius)),
          child: Container(
            padding: theme.itemPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(theme.itemBorderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? link.selectedIcon ?? link.icon : link.icon,
                  size: theme.iconSize,
                  color: iconFg,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    link.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: baseStyle.copyWith(color: fg),
                  ),
                ),
                if (link.badge != null) _badge(link.badge!, isSelected, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _groupTile(
    DrawerGroup group,
    String? selected,
    ResolvedDrawerRailTheme theme,
  ) {
    final open = _controller.isGroupExpanded(group.id);
    // The region spans header *and* children, so moving the pointer down into
    // the children does not read as leaving the group.
    return MouseRegion(
      onEnter: (_) => _onGroupHover(true, group, theme),
      onExit: (_) => _onGroupHover(false, group, theme),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: AnimatedPressCard(
              onTap: () => _toggleGroup(group),
              pressedScale: theme.pressedScale,
              pressAnimationDuration: theme.pressAnimationDuration,
              hoverEffect: theme.hoverEffect,
              hoverShadowColor: theme.hoverShadowColor,
              hoverHighlightColor: theme.hoverHighlightColor,
              hoverAnimationDuration: theme.hoverAnimationDuration,
              hoverAnimationCurve: theme.hoverAnimationCurve,
              clickableCursor: theme.clickableCursor,
              inertCursor: theme.inertCursor,
              focusColor: theme.focusColor,
              surfaceColor: theme.backgroundColor,
              baseColor: Colors.transparent,
              borderRadius:
                  BorderRadius.all(Radius.circular(theme.itemBorderRadius)),
              child: Container(
                padding: theme.itemPadding,
                child: Row(
                  children: [
                    Icon(
                      group.contains(selected)
                          ? group.selectedIcon ?? group.icon
                          : group.icon,
                      size: theme.iconSize,
                      color: theme.iconColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        group.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelTextStyle.copyWith(
                          color: theme.labelColor,
                        ),
                      ),
                    ),
                    if (group.badge != null) _badge(group.badge!, false, theme),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: theme.groupAnimationDuration,
                      curve: theme.groupAnimationCurve,
                      child: Icon(
                        theme.groupTrailingIcon,
                        color: theme.mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _groupReveal(group, open, selected, theme),
        ],
      ),
    );
  }

  /// The children of an inline group, revealed or hidden.
  Widget _groupReveal(
    DrawerGroup group,
    bool open,
    String? selected,
    ResolvedDrawerRailTheme theme,
  ) {
    final children = Column(
      children: [
        for (final child in group.children)
          _linkTile(child, selected == child.id, theme, indent: true),
      ],
    );
    // With no time to animate in — reduced motion, or a zero duration set on
    // purpose — the children are simply there or not. AnimatedCrossFade's
    // AnimatedSize cannot run at a zero duration: it mutates itself inside its
    // own layout and trips a framework assertion the moment a group opens.
    if (theme.groupAnimationDuration == Duration.zero) {
      return open ? children : const SizedBox(width: double.infinity);
    }
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: children,
      crossFadeState:
          open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: theme.groupAnimationDuration,
      // Without these the reveal defaults to a linear height tween, which
      // reads as mechanical next to the eased width animation.
      sizeCurve: theme.groupAnimationCurve,
      firstCurve: theme.groupAnimationCurve,
      secondCurve: theme.groupAnimationCurve,
    );
  }

  /// Toggles a group from an explicit click, which also *pins* it: a group the
  /// user clicked open must not close just because the pointer left.
  ///
  /// A click on a group hover already opened pins it as it is. Hover opens
  /// after [DrawerRailTheme.hoverOpenDelay] — quicker than anyone clicks — so
  /// toggling there shut nearly every group the user was reaching to open.
  void _toggleGroup(DrawerGroup group) {
    _groupTimers.remove(group.id)?.cancel();
    if (_hoverOpenedGroupIds.remove(group.id)) return;
    _controller.toggleGroup(group.id);
  }

  // ---- Rail (collapsed) tiles ---------------------------------------------

  Widget _railLink(
    DrawerLink link,
    bool isSelected,
    ResolvedDrawerRailTheme theme,
  ) {
    return MouseRegion(
      onEnter: (_) => _onLinkHover(true, link, theme),
      onExit: (_) => _onLinkHover(false, link, theme),
      child: _RailButton(
        icon: isSelected ? link.selectedIcon ?? link.icon : link.icon,
        tooltip: link.label,
        selected: isSelected,
        danger: link.danger,
        badge: link.badge,
        theme: theme,
        onTap: () => _openLink(link),
      ),
    );
  }

  Widget _railGroup(
    DrawerGroup group,
    String? selected,
    ResolvedDrawerRailTheme theme,
  ) {
    // Owned by the state (not the builder callback) so the flyout can be kept
    // open from the menu panel as well as from the rail button.
    final menu = _menuControllers.putIfAbsent(group.id, MenuController.new);
    final onRight = theme.position == DrawerRailPosition.right;
    // Captured outside the flyout, so the RTL wrapper below cannot leak into
    // the items themselves.
    final appDirection = Directionality.of(context);
    final anchored = MenuAnchor(
      controller: menu,
      // The flyout also closes on its own — a tap outside, Escape, an item
      // chosen — and must not be remembered as hover-opened after that.
      onClose: () => _hoverOpenedMenuIds.remove(group.id),
      // Open beside the rail, not below the button: the default placement drops
      // the flyout straight over the next rail buttons, so the group underneath
      // an open group could not be reached at all — fatal with hover, where the
      // pointer has to travel *through* the overlay to get anywhere.
      alignmentOffset: const Offset(_flyoutGap, 0),
      style: MenuStyle(
        alignment: AlignmentDirectional.topEnd,
        backgroundColor: WidgetStatePropertyAll(theme.menuBackgroundColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.itemBorderRadius),
          ),
        ),
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
      ),
      menuChildren: [
        for (final child in group.children)
          // Entering an item cancels the pending close, so the flyout survives
          // the pointer travelling from the rail button across to the overlay.
          MouseRegion(
            onEnter: (_) => _onMenuHover(true, group, menu, theme),
            onExit: (_) => _onMenuHover(false, group, menu, theme),
            child: Directionality(
              textDirection: appDirection,
              child: _flyoutItem(child, selected == child.id, theme),
            ),
          ),
      ],
      builder: (context, controller, _) => MouseRegion(
        onEnter: (_) => _onMenuHover(true, group, controller, theme),
        onExit: (_) => _onMenuHover(false, group, controller, theme),
        child: _RailButton(
          icon: group.contains(selected)
              ? group.selectedIcon ?? group.icon
              : group.icon,
          tooltip: group.label,
          selected: group.contains(selected),
          theme: theme,
          badge: group.badge,
          onTap: () {
            _menuTimers.remove(group.id)?.cancel();
            if (!controller.isOpen) {
              _openMenu(
                group.id,
                controller,
                hasItems: group.children.isNotEmpty,
              );
            } else if (!_hoverOpenedMenuIds.remove(group.id)) {
              controller.close();
            }
            // Otherwise hover opened it and the click pins it, exactly as
            // _toggleGroup does for an inline group.
          },
        ),
      ),
    );

    // A flyout on a right-hand rail has to grow *leftwards*, and the only lever
    // MenuAnchor gives for that is directionality: in RTL it measures from the
    // anchor's start edge instead of its end. Each item flips back to the app's
    // own direction so the icons and text still read normally.
    if (!onRight) return anchored;
    return Directionality(textDirection: TextDirection.rtl, child: anchored);
  }

  /// A link inside a rail group's flyout, styled like its counterpart in the
  /// panel. Flyout items used to be plain menu entries in the ambient text
  /// color: no selected pill, no danger tint, no badge, and labelColor
  /// ignored.
  Widget _flyoutItem(
    DrawerLink link,
    bool isSelected,
    ResolvedDrawerRailTheme theme,
  ) {
    final Color iconFg;
    final Color fg;
    if (isSelected) {
      iconFg = fg = theme.onSelectedColor;
    } else if (link.danger) {
      iconFg = fg = theme.errorColor;
    } else {
      iconFg = theme.iconColor;
      fg = theme.labelColor;
    }
    final style =
        isSelected ? theme.selectedLabelTextStyle : theme.labelTextStyle;
    return MenuItemButton(
      style: ButtonStyle(
        mouseCursor: WidgetStatePropertyAll(theme.clickableCursor),
        backgroundColor:
            isSelected ? WidgetStatePropertyAll(theme.selectedColor) : null,
        foregroundColor: WidgetStatePropertyAll(fg),
        iconColor: WidgetStatePropertyAll(iconFg),
      ),
      leadingIcon: Icon(
        isSelected ? link.selectedIcon ?? link.icon : link.icon,
        size: theme.iconSize,
        color: iconFg,
      ),
      trailingIcon: link.badge?.label == null
          ? null
          : _badge(link.badge!, isSelected, theme),
      onPressed: () => _openLink(link),
      child: Text(link.label, style: style.copyWith(color: fg)),
    );
  }

  // ---- Shared bits ---------------------------------------------------------

  Widget _badge(DrawerBadge badge, bool onPill, ResolvedDrawerRailTheme theme) {
    final label = badge.label;
    if (label == null) return const SizedBox.shrink();
    final Color bg;
    final Color fg;
    if (badge.isCount) {
      bg = theme.badgeCountColor;
      fg = theme.onBadgeCountColor;
    } else {
      bg = onPill ? theme.onSelectedColor : theme.badgeTextColor;
      fg = onPill ? theme.selectedColor : theme.onBadgeTextColor;
    }
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: theme.badgeTextStyle.copyWith(color: fg)),
    );
  }

  void _openLink(DrawerLink link) {
    // A click beats a hover dwell still counting down on some other item.
    _linkTimer?.cancel();
    // A result chosen from a search the rail button opened ends that search.
    _endSearchPeek();
    if (widget.selectOnTap) _controller.select(link.id);
    link.onTap(context);
  }
}

/// The breathing room left between the rail and a flyout opened beside it.
const double _flyoutGap = 4;

/// The horizontal inset of a rail button inside the rail. Shared with the
/// flyout placement, which measures from the rail's edge rather than the
/// button's.
const double _railButtonInset = 10;

/// A single icon button in the collapsed rail: tooltip, selected pill and an
/// optional badge dot.
class _RailButton extends StatefulWidget {
  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.theme,
    required this.onTap,
    this.danger = false,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final ResolvedDrawerRailTheme theme;
  final VoidCallback onTap;
  final bool danger;
  final DrawerBadge? badge;

  @override
  State<_RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<_RailButton> {
  final _tooltip = GlobalKey<TooltipState>();
  bool _tooltipFromFocus = false;

  /// A rail button is an icon and nothing else, so its tooltip *is* its label.
  /// A pointer gets it on hover; keyboard focus used to get nothing, leaving
  /// someone tabbing down the rail to guess what each icon does.
  void _onFocusChange(bool focused) {
    if (!focused) {
      // A tooltip shown with ensureTooltipVisible stays up until dismissed,
      // and Tooltip offers no way to dismiss just one. So this is global —
      // but it only runs when focus leaves a button whose tooltip focus
      // itself put up.
      if (_tooltipFromFocus) Tooltip.dismissAllToolTips();
      _tooltipFromFocus = false;
      return;
    }
    if (FocusManager.instance.highlightMode != FocusHighlightMode.traditional) {
      return;
    }
    // After the focus change has settled: the button losing focus dismisses
    // tooltips in the same pass, and must not take this one with it.
    scheduleMicrotask(() {
      if (!mounted) return;
      _tooltipFromFocus =
          _tooltip.currentState?.ensureTooltipVisible() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final badge = widget.badge;
    final fg = widget.selected
        ? theme.onSelectedColor
        : (widget.danger ? theme.errorColor : theme.iconColor);
    final showDot = badge?.label != null;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: _railButtonInset,
      ),
      child: Tooltip(
        key: _tooltip,
        message: widget.tooltip,
        // Reports focus landing on the button inside without being a focus
        // stop of its own.
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: _onFocusChange,
          child: AnimatedPressCard(
            onTap: widget.onTap,
            pressedScale: theme.pressedScale,
            pressAnimationDuration: theme.pressAnimationDuration,
            hoverEffect: theme.hoverEffect,
            hoverShadowColor: theme.hoverShadowColor,
            hoverHighlightColor: theme.hoverHighlightColor,
            hoverAnimationDuration: theme.hoverAnimationDuration,
            hoverAnimationCurve: theme.hoverAnimationCurve,
            clickableCursor: theme.clickableCursor,
            inertCursor: theme.inertCursor,
            focusColor: theme.focusColor,
            surfaceColor: theme.backgroundColor,
            baseColor:
                widget.selected ? theme.selectedColor : Colors.transparent,
            borderRadius:
                BorderRadius.all(Radius.circular(theme.itemBorderRadius)),
            child: SizedBox(
              height: theme.railItemHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(widget.icon, size: theme.railIconSize, color: fg),
                  if (showDot)
                    Positioned(
                      top: 8,
                      right: 14,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: badge!.isCount
                              ? theme.badgeCountColor
                              : theme.selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.backgroundColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
