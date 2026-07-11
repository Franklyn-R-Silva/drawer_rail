import 'package:flutter/material.dart';

/// A badge shown on a drawer entry.
///
/// A badge is either a short text label — for example `"New"` — created with
/// [DrawerBadge.text], or a numeric counter created with [DrawerBadge.count].
/// Count badges are automatically hidden when the value is `0` and are clamped
/// to `"99+"` above 99.
@immutable
class DrawerBadge {
  /// Creates a text badge, e.g. `DrawerBadge.text('New')`.
  const DrawerBadge.text(this.text) : count = null;

  /// Creates a numeric badge, e.g. `DrawerBadge.count(4)`.
  ///
  /// The badge is hidden when [count] is `0` or negative.
  const DrawerBadge.count(this.count) : text = null;

  /// The literal text of a text badge, or `null` for a count badge.
  final String? text;

  /// The value of a count badge, or `null` for a text badge.
  final int? count;

  /// The visible label, or `null` when a count badge should be hidden.
  ///
  /// Counts greater than 99 render as `"99+"`.
  String? get label {
    if (text != null) return text;
    final c = count ?? 0;
    return c > 0 ? (c > 99 ? '99+' : '$c') : null;
  }

  /// Whether this badge represents a numeric count (as opposed to plain text).
  ///
  /// Count badges are rendered with an accent color to draw attention (see
  /// `DrawerRailTheme.badgeCountColor`).
  bool get isCount => count != null;
}

/// The base class for everything that can appear in a [NovaDrawer].
///
/// This type is `sealed`, so callers must build the drawer out of one of its
/// three concrete subtypes: [DrawerSection], [DrawerLink] or [DrawerGroup].
/// Being sealed also lets the drawer switch over entries exhaustively.
sealed class DrawerEntry {
  const DrawerEntry();
}

/// A non-interactive section label used to group entries, for example
/// `"ACCOUNT"` or `"ANALYSIS"`.
///
/// In the expanded panel it renders as an uppercase caption; in the collapsed
/// rail it renders as a thin divider.
class DrawerSection extends DrawerEntry {
  /// Creates a section header with the given [label].
  const DrawerSection(this.label);

  /// The text shown for this section (rendered uppercased in the panel).
  final String label;
}

/// A tappable destination in the drawer.
///
/// [onTap] receives the drawer's own [BuildContext] and is responsible for the
/// navigation (or any other side effect). The [id] must be unique across the
/// whole entry list; it is what the drawer uses to mark the selected item.
class DrawerLink extends DrawerEntry {
  /// Creates a link entry.
  const DrawerLink({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.danger = false,
  });

  /// A stable, unique identifier used for selection highlighting.
  final String id;

  /// The leading icon.
  final IconData icon;

  /// The visible label.
  final String label;

  /// Called with the drawer's context when the link is tapped.
  final void Function(BuildContext context) onTap;

  /// An optional badge (text or count) shown at the trailing edge.
  final DrawerBadge? badge;

  /// Whether this link uses destructive styling (e.g. "Sign out"), tinting the
  /// icon and label with the error color.
  final bool danger;
}

/// An expandable group of [DrawerLink]s, for example `"Reports"` containing
/// several report screens.
///
/// When the drawer is expanded the group expands inline; when the drawer is
/// collapsed to the rail the group opens as a flyout menu anchored to its icon.
class DrawerGroup extends DrawerEntry {
  /// Creates a group entry with the given [children].
  const DrawerGroup({
    required this.id,
    required this.icon,
    required this.label,
    required this.children,
    this.badge,
  });

  /// A stable, unique identifier for this group.
  final String id;

  /// The leading icon.
  final IconData icon;

  /// The visible label.
  final String label;

  /// The links revealed when the group is open.
  final List<DrawerLink> children;

  /// An optional badge shown at the trailing edge of the group header.
  final DrawerBadge? badge;
}
