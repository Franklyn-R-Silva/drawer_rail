import 'package:flutter/material.dart';

/// Visual configuration for a [DrawerRail].
///
/// Every field is optional. Any value left `null` falls back to a sensible
/// default derived from the ambient [ThemeData] / [ColorScheme], so the drawer
/// blends into the surrounding app theme out of the box. Provide a
/// [DrawerRailTheme] only for the pieces you want to override.
@immutable
class DrawerRailTheme {
  /// Creates a drawer theme. All parameters are optional.
  const DrawerRailTheme({
    this.expandedWidth = 300,
    this.railWidth = 76,
    this.borderRadius = 24,
    this.itemBorderRadius = 14,
    this.animationDuration = const Duration(milliseconds: 240),
    this.animationCurve = Curves.easeOutCubic,
    this.backgroundColor,
    this.selectedColor,
    this.onSelectedColor,
    this.iconColor,
    this.labelColor,
    this.sectionColor,
    this.badgeTextColor,
    this.badgeCountColor,
    this.shadow,
  });

  /// The width of the drawer when expanded. Defaults to `300`.
  final double expandedWidth;

  /// The width of the collapsed icon rail. Defaults to `76`.
  final double railWidth;

  /// The corner radius applied to the trailing edge of the drawer.
  final double borderRadius;

  /// The corner radius of individual items (links, groups, rail buttons).
  final double itemBorderRadius;

  /// How long the collapse/expand width animation runs.
  final Duration animationDuration;

  /// The curve of the collapse/expand width animation.
  final Curve animationCurve;

  /// The drawer surface color. Defaults to [ColorScheme.surface].
  final Color? backgroundColor;

  /// The fill color of the selected item pill. Defaults to
  /// [ColorScheme.primary].
  final Color? selectedColor;

  /// The foreground color used on top of [selectedColor]. Defaults to
  /// [ColorScheme.onPrimary].
  final Color? onSelectedColor;

  /// The default icon color for unselected items. Defaults to
  /// [ColorScheme.onSurface].
  final Color? iconColor;

  /// The default label color for unselected items. Defaults to
  /// [ColorScheme.onSurface].
  final Color? labelColor;

  /// The color of section headers. Defaults to [ColorScheme.primary].
  final Color? sectionColor;

  /// The background color of text badges. Defaults to
  /// [ColorScheme.primaryContainer].
  final Color? badgeTextColor;

  /// The background color of count badges. Defaults to [ColorScheme.error].
  final Color? badgeCountColor;

  /// The shadow cast by the drawer. Defaults to a soft right-side shadow.
  final List<BoxShadow>? shadow;

  /// Returns a copy of this theme resolved against [scheme], filling every
  /// nullable color with its default so the widgets can read non-null values.
  ResolvedDrawerRailTheme resolve(ColorScheme scheme) {
    return ResolvedDrawerRailTheme(
      expandedWidth: expandedWidth,
      railWidth: railWidth,
      borderRadius: borderRadius,
      itemBorderRadius: itemBorderRadius,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      backgroundColor: backgroundColor ?? scheme.surface,
      selectedColor: selectedColor ?? scheme.primary,
      onSelectedColor: onSelectedColor ?? scheme.onPrimary,
      iconColor: iconColor ?? scheme.onSurface,
      labelColor: labelColor ?? scheme.onSurface,
      sectionColor: sectionColor ?? scheme.primary,
      badgeTextColor: badgeTextColor ?? scheme.primaryContainer,
      onBadgeTextColor: scheme.onPrimaryContainer,
      badgeCountColor: badgeCountColor ?? scheme.error,
      onBadgeCountColor: scheme.onError,
      surfaceVariantColor: scheme.onSurfaceVariant,
      errorColor: scheme.error,
      menuBackgroundColor: scheme.surfaceContainerHigh,
      searchFillColor: scheme.surfaceContainerHigh,
      shadow: shadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(2, 0),
            ),
          ],
    );
  }
}

/// A fully resolved [DrawerRailTheme] with no nullable colors, produced by
/// [DrawerRailTheme.resolve]. This is an internal convenience the drawer
/// widgets read from; you normally construct a [DrawerRailTheme] instead.
@immutable
class ResolvedDrawerRailTheme {
  /// Creates a resolved theme. Prefer [DrawerRailTheme.resolve] over calling
  /// this directly.
  const ResolvedDrawerRailTheme({
    required this.expandedWidth,
    required this.railWidth,
    required this.borderRadius,
    required this.itemBorderRadius,
    required this.animationDuration,
    required this.animationCurve,
    required this.backgroundColor,
    required this.selectedColor,
    required this.onSelectedColor,
    required this.iconColor,
    required this.labelColor,
    required this.sectionColor,
    required this.badgeTextColor,
    required this.onBadgeTextColor,
    required this.badgeCountColor,
    required this.onBadgeCountColor,
    required this.surfaceVariantColor,
    required this.errorColor,
    required this.menuBackgroundColor,
    required this.searchFillColor,
    required this.shadow,
  });

  /// See [DrawerRailTheme.expandedWidth].
  final double expandedWidth;

  /// See [DrawerRailTheme.railWidth].
  final double railWidth;

  /// See [DrawerRailTheme.borderRadius].
  final double borderRadius;

  /// See [DrawerRailTheme.itemBorderRadius].
  final double itemBorderRadius;

  /// See [DrawerRailTheme.animationDuration].
  final Duration animationDuration;

  /// See [DrawerRailTheme.animationCurve].
  final Curve animationCurve;

  /// The resolved drawer surface color.
  final Color backgroundColor;

  /// The resolved selected-pill color.
  final Color selectedColor;

  /// The resolved foreground color on the selected pill.
  final Color onSelectedColor;

  /// The resolved default icon color.
  final Color iconColor;

  /// The resolved default label color.
  final Color labelColor;

  /// The resolved section-header color.
  final Color sectionColor;

  /// The resolved text-badge background color.
  final Color badgeTextColor;

  /// The resolved text-badge foreground color.
  final Color onBadgeTextColor;

  /// The resolved count-badge background color.
  final Color badgeCountColor;

  /// The resolved count-badge foreground color.
  final Color onBadgeCountColor;

  /// A muted foreground color used for secondary text and inactive icons.
  final Color surfaceVariantColor;

  /// The error color, used for [DrawerLink.danger] items.
  final Color errorColor;

  /// The background color of collapsed group flyout menus.
  final Color menuBackgroundColor;

  /// The fill color of the search field.
  final Color searchFillColor;

  /// The resolved drawer shadow.
  final List<BoxShadow> shadow;
}
