import 'package:flutter/foundation.dart';

/// User-facing strings used by [DrawerRail].
///
/// The defaults are in English. Pass a translated instance to localize the
/// drawer's built-in chrome (search field, tooltips, empty state) without
/// wiring up a full localization delegate.
///
/// ```dart
/// DrawerRail(
///   labels: const DrawerRailLabels(
///     searchHint: 'Buscar...',
///     noResults: 'Nenhum resultado',
///     expandTooltip: 'Expandir',
///     collapseTooltip: 'Recolher',
///   ),
///   // ...
/// );
/// ```
@immutable
class DrawerRailLabels {
  /// Creates a set of labels. All parameters have English defaults.
  const DrawerRailLabels({
    this.searchHint = 'Search...',
    this.noResults = 'No results found',
    this.expandTooltip = 'Expand',
    this.collapseTooltip = 'Collapse',
    this.searchTooltip = 'Search',
  });

  /// Placeholder shown in the search field.
  final String searchHint;

  /// Message shown when a search matches no entries.
  final String noResults;

  /// Tooltip for the button that expands the collapsed rail.
  final String expandTooltip;

  /// Tooltip for the button that collapses the expanded panel.
  final String collapseTooltip;

  /// Tooltip for the search icon shown on the collapsed rail.
  final String searchTooltip;

  /// Returns a copy of these labels with the given strings replaced.
  DrawerRailLabels copyWith({
    String? searchHint,
    String? noResults,
    String? expandTooltip,
    String? collapseTooltip,
    String? searchTooltip,
  }) {
    return DrawerRailLabels(
      searchHint: searchHint ?? this.searchHint,
      noResults: noResults ?? this.noResults,
      expandTooltip: expandTooltip ?? this.expandTooltip,
      collapseTooltip: collapseTooltip ?? this.collapseTooltip,
      searchTooltip: searchTooltip ?? this.searchTooltip,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawerRailLabels &&
          other.searchHint == searchHint &&
          other.noResults == noResults &&
          other.expandTooltip == expandTooltip &&
          other.collapseTooltip == collapseTooltip &&
          other.searchTooltip == searchTooltip;

  @override
  int get hashCode => Object.hash(
        searchHint,
        noResults,
        expandTooltip,
        collapseTooltip,
        searchTooltip,
      );
}
