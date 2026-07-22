import 'package:flutter/material.dart';

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

  @override
  State<DrawerRail> createState() => _DrawerRailState();
}

class _DrawerRailState extends State<DrawerRail> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  DrawerRailController get _controller => widget.controller;

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
    final theme = widget.theme.resolve(scheme);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final collapsed = _controller.collapsed;
        final width = collapsed ? theme.railWidth : theme.expandedWidth;

        return AnimatedContainer(
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
          // Lay content out at its natural width regardless of the animating
          // container width, so the tween never under-constrains it (no
          // overflow); the container clips the reveal.
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: double.infinity,
            child: SizedBox(
              width: width,
              child: Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(collapsed, theme),
                      if (widget.showSearch) _buildSearch(collapsed, theme),
                      Expanded(child: _buildMenu(collapsed, theme)),
                      if (widget.footerBuilder != null) ...[
                        if (widget.showFooterDivider) const Divider(height: 1),
                        widget.footerBuilder!(context, collapsed),
                      ],
                    ],
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

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null) header,
            if (widget.showCollapseButton)
              IconButton(
                tooltip: widget.labels.expandTooltip,
                icon: Icon(theme.expandIcon),
                onPressed: () => _controller.setCollapsed(false),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          if (header != null) Expanded(child: header) else const Spacer(),
          if (widget.showCollapseButton)
            IconButton(
              tooltip: widget.labels.collapseTooltip,
              icon: Icon(theme.collapseIcon),
              onPressed: () => _controller.setCollapsed(true),
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
          icon: Icon(theme.searchIcon),
          onPressed: () {
            _controller.setCollapsed(false);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _searchFocus.requestFocus());
          },
        ),
      );
    }
    final base = widget.searchDecoration ??
        InputDecoration(
          isDense: true,
          prefixIcon: Icon(theme.searchIcon, size: theme.iconSize),
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
        decoration: base.copyWith(
          hintText: base.hintText ?? widget.labels.searchHint,
          suffixIcon: _query.isEmpty
              ? base.suffixIcon
              : IconButton(
                  icon: Icon(theme.clearSearchIcon, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
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
          matches.addAll(e.children.where((c) => _matches(c.label)));
        }
      }
      if (matches.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              widget.labels.noResults,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.surfaceVariantColor),
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
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Divider(height: 1),
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
    final tint = link.danger ? theme.errorColor : theme.labelColor;
    final fg = isSelected ? theme.onSelectedColor : tint;
    final baseStyle =
        isSelected ? theme.selectedLabelTextStyle : theme.labelTextStyle;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 2,
        left: indent ? theme.groupChildIndent : 0,
      ),
      child: AnimatedPressCard(
        onTap: () => _openLink(link),
        pressedScale: theme.pressedScale,
        hoverEffect: theme.hoverEffect,
        hoverShadowColor: theme.hoverShadowColor,
        hoverHighlightColor: theme.hoverHighlightColor,
        surfaceColor: theme.backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(theme.itemBorderRadius)),
        child: Container(
          padding: theme.itemPadding,
          decoration: BoxDecoration(
            color: isSelected ? theme.selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(theme.itemBorderRadius),
          ),
          child: Row(
            children: [
              Icon(link.icon, size: theme.iconSize, color: fg),
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
    );
  }

  Widget _groupTile(
    DrawerGroup group,
    String? selected,
    ResolvedDrawerRailTheme theme,
  ) {
    final open = _controller.isGroupExpanded(group.id);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: AnimatedPressCard(
            onTap: () => _controller.toggleGroup(group.id),
            pressedScale: theme.pressedScale,
            hoverEffect: theme.hoverEffect,
            hoverShadowColor: theme.hoverShadowColor,
            hoverHighlightColor: theme.hoverHighlightColor,
            surfaceColor: theme.backgroundColor,
            borderRadius:
                BorderRadius.all(Radius.circular(theme.itemBorderRadius)),
            child: Container(
              padding: theme.itemPadding,
              child: Row(
                children: [
                  Icon(
                    group.icon,
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
                    child: Icon(
                      theme.groupTrailingIcon,
                      color: theme.surfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Column(
            children: [
              for (final child in group.children)
                _linkTile(child, selected == child.id, theme, indent: true),
            ],
          ),
          crossFadeState:
              open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: theme.groupAnimationDuration,
        ),
      ],
    );
  }

  // ---- Rail (collapsed) tiles ---------------------------------------------

  Widget _railLink(
    DrawerLink link,
    bool isSelected,
    ResolvedDrawerRailTheme theme,
  ) {
    return _RailButton(
      icon: link.icon,
      tooltip: link.label,
      selected: isSelected,
      danger: link.danger,
      badge: link.badge,
      theme: theme,
      onTap: () => _openLink(link),
    );
  }

  Widget _railGroup(
    DrawerGroup group,
    String? selected,
    ResolvedDrawerRailTheme theme,
  ) {
    return MenuAnchor(
      style: MenuStyle(
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
          MenuItemButton(
            leadingIcon:
                Icon(child.icon, size: theme.iconSize, color: theme.iconColor),
            onPressed: () => _openLink(child),
            child: Text(child.label),
          ),
      ],
      builder: (context, menu, _) => _RailButton(
        icon: group.icon,
        tooltip: group.label,
        selected: group.children.any((c) => c.id == selected),
        theme: theme,
        badge: group.badge,
        onTap: () => menu.isOpen ? menu.close() : menu.open(),
      ),
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
    _controller.select(link.id);
    link.onTap(context);
  }
}

/// A single icon button in the collapsed rail: tooltip, selected pill and an
/// optional badge dot.
class _RailButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final fg = selected
        ? theme.onSelectedColor
        : (danger ? theme.errorColor : theme.iconColor);
    final showDot = badge?.label != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Tooltip(
        message: tooltip,
        child: AnimatedPressCard(
          onTap: onTap,
          pressedScale: theme.pressedScale,
          hoverEffect: theme.hoverEffect,
          hoverShadowColor: theme.hoverShadowColor,
          hoverHighlightColor: theme.hoverHighlightColor,
          surfaceColor: theme.backgroundColor,
          borderRadius:
              BorderRadius.all(Radius.circular(theme.itemBorderRadius)),
          child: Container(
            height: theme.railItemHeight,
            decoration: BoxDecoration(
              color: selected ? theme.selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(theme.itemBorderRadius),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: theme.railIconSize, color: fg),
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
    );
  }
}
