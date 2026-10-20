import 'package:flutter/foundation.dart';

/// Holds and mutates the runtime state of a [DrawerRail]: whether it is
/// collapsed to the rail, which entry is currently selected, and which groups
/// are expanded.
///
/// The controller is a plain [ChangeNotifier], so it works without any external
/// state-management package. Create one, keep it alive (for example in a
/// [State]), pass it to the drawer, and call [dispose] when you are done.
///
/// ```dart
/// final controller = DrawerRailController(collapsed: false);
/// // ...
/// DrawerRail(controller: controller, entries: entries);
/// // ...
/// controller.dispose();
/// ```
///
/// Persistence is intentionally left to the caller: listen to the controller
/// (or read its values) and save [collapsed] / [selectedId] wherever you like
/// (for example `SharedPreferences`).
class DrawerRailController extends ChangeNotifier {
  /// Creates a controller.
  ///
  /// [collapsed] is the initial collapsed state, and [selectedId] optionally
  /// pre-selects an entry by its [DrawerLink.id]. Groups listed in
  /// [initiallyExpanded] start open. With [accordion] on, opening a group
  /// closes the one that was open.
  DrawerRailController({
    bool collapsed = false,
    String? selectedId,
    Set<String>? initiallyExpanded,
    this.accordion = false,
  })  : assert(
          !accordion || (initiallyExpanded?.length ?? 0) <= 1,
          'an accordion starts with at most one group open',
        ),
        _collapsed = collapsed,
        _selectedId = selectedId,
        _expandedGroups = {...?initiallyExpanded};

  /// Whether at most one group is open at a time: expanding a group — by
  /// click, by hover or from code — collapses every other one.
  final bool accordion;

  bool _collapsed;
  bool _hoverPeeking = false;
  bool _hoverHidden = false;
  bool _hoverHeld = false;
  bool _disposed = false;
  String? _selectedId;
  final Set<String> _expandedGroups;

  /// Whether the drawer is *pinned* collapsed to the narrow icon rail.
  ///
  /// This is the durable state — the one to persist. Hover never writes it: a
  /// peek ([hoverPeeking]) widens the drawer and an auto-hide ([hoverHidden])
  /// narrows it, both without changing this value, so a user brushing past the
  /// drawer never rewrites their saved preference. Read [railCollapsed] if you
  /// want to know what is actually on screen.
  bool get collapsed => _collapsed;

  /// Whether the collapsed rail is currently being held open by the mouse
  /// pointer, with `DrawerRailTheme.railTrigger` set to
  /// `DrawerActivationMode.hover`.
  ///
  /// Transient by nature: do not persist it.
  bool get hoverPeeking => _hoverPeeking;

  /// Whether the collapsed rail is currently being held *shut* by the pointer
  /// having left the drawer, with `DrawerRailTheme.railAutoCollapse` on.
  ///
  /// The mirror image of [hoverPeeking]: where a peek widens a pinned-collapsed
  /// drawer, this narrows a pinned-expanded one — again without touching
  /// [collapsed], so the user's saved preference survives either way.
  ///
  /// Transient by nature: do not persist it.
  bool get hoverHidden => _hoverHidden;

  /// Whether the app is holding a hover-opened drawer open — see
  /// [setHoverHold].
  ///
  /// Transient by nature: do not persist it.
  bool get hoverHeld => _hoverHeld;

  /// Whether the drawer is rendering the narrow icon rail right now — that is,
  /// either hidden by hover, or [collapsed] and not currently peeked open.
  ///
  /// This is the value to use for layout that must line up with the drawer's
  /// real width.
  bool get railCollapsed => _hoverHidden || (_collapsed && !_hoverPeeking);

  /// The id of the currently selected [DrawerLink], or `null` if none.
  String? get selectedId => _selectedId;

  /// The ids of the [DrawerGroup]s that are currently expanded.
  Set<String> get expandedGroups => Set.unmodifiable(_expandedGroups);

  /// Collapses or expands the drawer, pinning the state. No-op if already in
  /// [value] and not peeking.
  ///
  /// An explicit collapse/expand always wins over hover, so a peek or an
  /// auto-hide in flight is dropped here.
  void setCollapsed(bool value) {
    if (_collapsed == value && !_hoverPeeking && !_hoverHidden) return;
    _collapsed = value;
    _hoverPeeking = false;
    _hoverHidden = false;
    notifyListeners();
  }

  /// Starts or ends a temporary hover peek of the collapsed rail.
  ///
  /// Only meaningful while [collapsed] is `true`; it never changes [collapsed]
  /// itself, so the user's pinned preference survives. No-op if already in
  /// [value].
  void setHoverPeek(bool value) {
    if (_hoverPeeking == value) return;
    _hoverPeeking = value;
    notifyListeners();
  }

  /// Starts or ends a temporary hover-driven hide of the expanded panel.
  ///
  /// Only meaningful while [collapsed] is `false`; like [setHoverPeek] it never
  /// changes [collapsed] itself. No-op if already in [value].
  void setHoverHidden(bool value) {
    if (_hoverHidden == value) return;
    _hoverHidden = value;
    notifyListeners();
  }

  /// Holds the drawer open against hover (`true`), or lets it go (`false`).
  ///
  /// Hover closes the drawer when the pointer leaves it, and an overlay opened
  /// from inside it — a menu in the header, a popup from the footer — is drawn
  /// *outside* it, so reaching for one reads as leaving and the panel used to
  /// collapse from under the open menu. Hold it for as long as such an overlay
  /// is up:
  ///
  /// ```dart
  /// MenuAnchor(
  ///   onOpen: () => controller.setHoverHold(true),
  ///   onClose: () => controller.setHoverHold(false),
  ///   // ...
  /// )
  /// ```
  ///
  /// While held, a hover close is put off rather than dropped: once released,
  /// the drawer closes if the pointer is still away, exactly as it would have.
  /// Like the rest of the hover state it never changes [collapsed]. No-op if
  /// already in [value].
  void setHoverHold(bool value) {
    if (_hoverHeld == value) return;
    _hoverHeld = value;
    notifyListeners();
  }

  /// Toggles between the expanded panel and the collapsed rail.
  ///
  /// Toggles the *pinned* state, so a drawer currently hidden or peeked by
  /// hover resolves to the opposite of what the user pinned, not of what is on
  /// screen.
  void toggleCollapsed() => setCollapsed(!_collapsed);

  /// Marks the entry with [id] as selected. No-op if already selected.
  void select(String id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  /// Clears the current selection.
  void clearSelection() {
    if (_selectedId == null) return;
    _selectedId = null;
    notifyListeners();
  }

  /// Returns whether the group with [id] is currently expanded.
  bool isGroupExpanded(String id) => _expandedGroups.contains(id);

  /// Expands or collapses the group with [id].
  void toggleGroup(String id) {
    if (!_expandedGroups.remove(id)) {
      _expandGroup(id);
    }
    notifyListeners();
  }

  /// Opens [id] — after closing every other group, in an [accordion].
  void _expandGroup(String id) {
    if (accordion) _expandedGroups.clear();
    _expandedGroups.add(id);
  }

  /// Clears the transient hover state — [hoverPeeking], [hoverHidden] and
  /// [hoverHeld] — leaving the pinned [collapsed] preference untouched.
  ///
  /// [DrawerRail] calls this once it has left the tree, so a controller that
  /// outlives the drawer (one hoisted above the navigator, say) does not go on
  /// reporting a peek that no widget is holding open any more — nor a hold
  /// whose overlay went with the drawer. Safe to call on an already-disposed
  /// controller, since teardown order is the caller's to choose: it simply
  /// does nothing.
  void resetHoverState() {
    if (_disposed || (!_hoverPeeking && !_hoverHidden && !_hoverHeld)) return;
    _hoverPeeking = false;
    _hoverHidden = false;
    _hoverHeld = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Expands ([expanded] `true`) or collapses the group with [id]. No-op if it
  /// is already in that state.
  ///
  /// Unlike [toggleGroup] this is idempotent, which is what hover needs: moving
  /// the pointer onto an already-open group must not close it.
  void setGroupExpanded(String id, bool expanded) {
    if (expanded == _expandedGroups.contains(id)) return;
    if (expanded) {
      _expandGroup(id);
    } else {
      _expandedGroups.remove(id);
    }
    notifyListeners();
  }
}
