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
  String? _selectedId;
  final Set<String> _expandedGroups;

  /// Whether the drawer is currently collapsed to the narrow icon rail.
  bool get collapsed => _collapsed;

  /// The id of the currently selected [DrawerLink], or `null` if none.
  String? get selectedId => _selectedId;

  /// The ids of the [DrawerGroup]s that are currently expanded.
  Set<String> get expandedGroups => Set.unmodifiable(_expandedGroups);

  /// Collapses or expands the drawer. No-op if already in [value].
  void setCollapsed(bool value) {
    if (_collapsed == value) return;
    _collapsed = value;
    notifyListeners();
  }

  /// Toggles between the expanded panel and the collapsed rail.
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
}
