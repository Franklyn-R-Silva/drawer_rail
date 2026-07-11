import 'package:flutter/material.dart';

/// Which side of the screen the drawer sits on.
///
/// Controls which edge is rounded and the direction of the default shadow.
enum DrawerRailPosition {
  /// The drawer sits on the left; its right edge is rounded.
  left,

  /// The drawer sits on the right; its left edge is rounded.
  right,
}

/// Visual configuration for a [DrawerRail].
///
/// Every field is optional. Any value left `null` falls back to a sensible
/// default derived from the ambient [ThemeData] / [ColorScheme], so the drawer
/// blends into the surrounding app theme out of the box. Provide a
/// [DrawerRailTheme] only for the pieces you want to override — the whole
/// surface (sizes, paddings, colors, text styles, icons, animation) is exposed
/// so the drawer can be styled to taste.
@immutable
class DrawerRailTheme {
  /// Creates a drawer theme. All parameters are optional.
  const DrawerRailTheme({
    this.expandedWidth = 300,
    this.railWidth = 76,
    this.borderRadius = 24,
    this.itemBorderRadius = 14,
    this.position = DrawerRailPosition.left,
    this.animationDuration = const Duration(milliseconds: 240),
    this.animationCurve = Curves.easeOutCubic,
    this.groupAnimationDuration = const Duration(milliseconds: 200),
    this.iconSize = 20,
    this.railIconSize = 22,
    this.railItemHeight = 44,
    this.pressedScale = 0.97,
    this.sectionUppercase = true,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.groupChildIndent = 24,
    this.backgroundColor,
    this.selectedColor,
    this.onSelectedColor,
    this.iconColor,
    this.labelColor,
    this.sectionColor,
    this.badgeTextColor,
    this.badgeCountColor,
    this.menuBackgroundColor,
    this.searchFillColor,
    this.hoverShadowColor,
    this.shadow,
    this.labelTextStyle,
    this.selectedLabelTextStyle,
    this.sectionTextStyle,
    this.badgeTextStyle,
    this.collapseIcon = Icons.chevron_left_rounded,
    this.expandIcon = Icons.chevron_right_rounded,
    this.searchIcon = Icons.search_rounded,
    this.clearSearchIcon = Icons.close_rounded,
    this.groupTrailingIcon = Icons.keyboard_arrow_down_rounded,
  });

  /// The width of the drawer when expanded. Defaults to `300`.
  final double expandedWidth;

  /// The width of the collapsed icon rail. Defaults to `76`.
  final double railWidth;

  /// The corner radius applied to the inner (rounded) edge of the drawer.
  final double borderRadius;

  /// The corner radius of individual items (links, groups, rail buttons).
  final double itemBorderRadius;

  /// Which side of the screen the drawer sits on. Defaults to
  /// [DrawerRailPosition.left].
  final DrawerRailPosition position;

  /// How long the collapse/expand width animation runs.
  final Duration animationDuration;

  /// The curve of the collapse/expand width animation.
  final Curve animationCurve;

  /// How long a group takes to expand/collapse and its chevron to rotate.
  final Duration groupAnimationDuration;

  /// The size of item icons in the expanded panel. Defaults to `20`.
  final double iconSize;

  /// The size of item icons in the collapsed rail. Defaults to `22`.
  final double railIconSize;

  /// The height of each button in the collapsed rail. Defaults to `44`.
  final double railItemHeight;

  /// The scale applied to an item while it is pressed. Defaults to `0.97`.
  final double pressedScale;

  /// Whether section labels are rendered uppercased. Defaults to `true`.
  final bool sectionUppercase;

  /// Padding around the scrolling menu list.
  final EdgeInsetsGeometry contentPadding;

  /// Inner padding of each link/group tile in the expanded panel.
  final EdgeInsetsGeometry itemPadding;

  /// The left indentation of a group's child links in the expanded panel.
  final double groupChildIndent;

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

  /// The background color of collapsed group flyout menus. Defaults to
  /// [ColorScheme.surfaceContainerHigh].
  final Color? menuBackgroundColor;

  /// The fill color of the search field. Defaults to
  /// [ColorScheme.surfaceContainerHigh].
  final Color? searchFillColor;

  /// The color of the soft shadow shown when hovering an item. Defaults to a
  /// translucent [ColorScheme.primary].
  final Color? hoverShadowColor;

  /// The shadow cast by the drawer. Defaults to a soft shadow on the outer
  /// edge (see [position]).
  final List<BoxShadow>? shadow;

  /// Base text style for item labels. The color is overridden per state
  /// (selected / danger). Defaults to a semi-bold body style.
  final TextStyle? labelTextStyle;

  /// Text style for the label of the selected item. Falls back to
  /// [labelTextStyle] when null. The color defaults to [onSelectedColor].
  final TextStyle? selectedLabelTextStyle;

  /// Text style for section headers. The color defaults to [sectionColor].
  final TextStyle? sectionTextStyle;

  /// Base text style for badge labels. The color is overridden per context.
  final TextStyle? badgeTextStyle;

  /// The icon of the button that collapses the expanded panel.
  final IconData collapseIcon;

  /// The icon of the button that expands the collapsed rail.
  final IconData expandIcon;

  /// The leading icon of the search field / rail search button.
  final IconData searchIcon;

  /// The icon of the button that clears the search field.
  final IconData clearSearchIcon;

  /// The trailing chevron of an expandable group in the expanded panel.
  final IconData groupTrailingIcon;

  /// Returns a copy of this theme resolved against [scheme], filling every
  /// nullable value with its default so the widgets can read non-null values.
  ResolvedDrawerRailTheme resolve(ColorScheme scheme) {
    final resolvedSelected = selectedColor ?? scheme.primary;
    final resolvedOnSelected = onSelectedColor ?? scheme.onPrimary;
    final resolvedLabel = labelColor ?? scheme.onSurface;
    final resolvedSection = sectionColor ?? scheme.primary;
    final baseLabel =
        (labelTextStyle ?? const TextStyle(fontWeight: FontWeight.w600));
    final onRight = position == DrawerRailPosition.right;

    return ResolvedDrawerRailTheme(
      expandedWidth: expandedWidth,
      railWidth: railWidth,
      borderRadius: borderRadius,
      itemBorderRadius: itemBorderRadius,
      position: position,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      groupAnimationDuration: groupAnimationDuration,
      iconSize: iconSize,
      railIconSize: railIconSize,
      railItemHeight: railItemHeight,
      pressedScale: pressedScale,
      sectionUppercase: sectionUppercase,
      contentPadding: contentPadding,
      itemPadding: itemPadding,
      groupChildIndent: groupChildIndent,
      backgroundColor: backgroundColor ?? scheme.surface,
      selectedColor: resolvedSelected,
      onSelectedColor: resolvedOnSelected,
      iconColor: iconColor ?? scheme.onSurface,
      labelColor: resolvedLabel,
      sectionColor: resolvedSection,
      badgeTextColor: badgeTextColor ?? scheme.primaryContainer,
      onBadgeTextColor: scheme.onPrimaryContainer,
      badgeCountColor: badgeCountColor ?? scheme.error,
      onBadgeCountColor: scheme.onError,
      surfaceVariantColor: scheme.onSurfaceVariant,
      errorColor: scheme.error,
      menuBackgroundColor: menuBackgroundColor ?? scheme.surfaceContainerHigh,
      searchFillColor: searchFillColor ?? scheme.surfaceContainerHigh,
      hoverShadowColor:
          hoverShadowColor ?? scheme.primary.withValues(alpha: 0.12),
      labelTextStyle: baseLabel,
      selectedLabelTextStyle: selectedLabelTextStyle ?? baseLabel,
      sectionTextStyle: (sectionTextStyle ??
              const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.0,
              ))
          .copyWith(color: sectionTextStyle?.color ?? resolvedSection),
      badgeTextStyle: badgeTextStyle ??
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      collapseIcon: collapseIcon,
      expandIcon: expandIcon,
      searchIcon: searchIcon,
      clearSearchIcon: clearSearchIcon,
      groupTrailingIcon: groupTrailingIcon,
      shadow: shadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: Offset(onRight ? -2 : 2, 0),
            ),
          ],
    );
  }
}

/// A fully resolved [DrawerRailTheme] with no nullable values, produced by
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
    required this.position,
    required this.animationDuration,
    required this.animationCurve,
    required this.groupAnimationDuration,
    required this.iconSize,
    required this.railIconSize,
    required this.railItemHeight,
    required this.pressedScale,
    required this.sectionUppercase,
    required this.contentPadding,
    required this.itemPadding,
    required this.groupChildIndent,
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
    required this.hoverShadowColor,
    required this.labelTextStyle,
    required this.selectedLabelTextStyle,
    required this.sectionTextStyle,
    required this.badgeTextStyle,
    required this.collapseIcon,
    required this.expandIcon,
    required this.searchIcon,
    required this.clearSearchIcon,
    required this.groupTrailingIcon,
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

  /// See [DrawerRailTheme.position].
  final DrawerRailPosition position;

  /// See [DrawerRailTheme.animationDuration].
  final Duration animationDuration;

  /// See [DrawerRailTheme.animationCurve].
  final Curve animationCurve;

  /// See [DrawerRailTheme.groupAnimationDuration].
  final Duration groupAnimationDuration;

  /// See [DrawerRailTheme.iconSize].
  final double iconSize;

  /// See [DrawerRailTheme.railIconSize].
  final double railIconSize;

  /// See [DrawerRailTheme.railItemHeight].
  final double railItemHeight;

  /// See [DrawerRailTheme.pressedScale].
  final double pressedScale;

  /// See [DrawerRailTheme.sectionUppercase].
  final bool sectionUppercase;

  /// See [DrawerRailTheme.contentPadding].
  final EdgeInsetsGeometry contentPadding;

  /// See [DrawerRailTheme.itemPadding].
  final EdgeInsetsGeometry itemPadding;

  /// See [DrawerRailTheme.groupChildIndent].
  final double groupChildIndent;

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

  /// The resolved hover shadow color.
  final Color hoverShadowColor;

  /// The resolved base label style (color applied per state).
  final TextStyle labelTextStyle;

  /// The resolved selected-label style (color applied per state).
  final TextStyle selectedLabelTextStyle;

  /// The resolved, fully-colored section-header style.
  final TextStyle sectionTextStyle;

  /// The resolved base badge style (color applied per context).
  final TextStyle badgeTextStyle;

  /// See [DrawerRailTheme.collapseIcon].
  final IconData collapseIcon;

  /// See [DrawerRailTheme.expandIcon].
  final IconData expandIcon;

  /// See [DrawerRailTheme.searchIcon].
  final IconData searchIcon;

  /// See [DrawerRailTheme.clearSearchIcon].
  final IconData clearSearchIcon;

  /// See [DrawerRailTheme.groupTrailingIcon].
  final IconData groupTrailingIcon;

  /// The resolved drawer shadow.
  final List<BoxShadow> shadow;
}
