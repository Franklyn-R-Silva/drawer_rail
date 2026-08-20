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
  /// [initiallyExpanded] start open.
  DrawerRailController({
    bool collapsed = false,
    String? selectedId,
    Set<String>? initiallyExpanded,
  })  : _collapsed = collapsed,
        _selectedId = selectedId,
        _expandedGroups = {...?initiallyExpanded};

  bool _collapsed;
  bool _hoverPeeking = false;
  bool _hoverHidden = false;
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
      _expandedGroups.add(id);
    }
    notifyListeners();
  }

  /// Expands ([expanded] `true`) or collapses the group with [id]. No-op if it
  /// is already in that state.
  ///
  /// Unlike [toggleGroup] this is idempotent, which is what hover needs: moving
  /// the pointer onto an already-open group must not close it.
  void setGroupExpanded(String id, bool expanded) {
    final changed =
        expanded ? _expandedGroups.add(id) : _expandedGroups.remove(id);
    if (!changed) return;
    notifyListeners();
  }
}
