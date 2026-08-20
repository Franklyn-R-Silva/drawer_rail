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

/// The visual feedback shown when an item is hovered.
enum DrawerHoverEffect {
  /// The item lifts with a soft shadow (an opaque surface is painted behind it
  /// so the shadow reads as elevation rather than a colored haze).
  shadow,

  /// The item's background is tinted with a subtle highlight. No shadow.
  highlight,

  /// No hover feedback. The press micro-scale still applies.
  none,
}

/// How an interaction is triggered on pointer-capable platforms (web,
/// desktop).
///
/// Hover is always *additive*: the tap/click path keeps working in every mode,
/// so touch users — where hover events never fire — are never locked out of an
/// item.
enum DrawerActivationMode {
  /// The interaction only happens on tap/click. This is the default, and the
  /// only mode that works on touch devices.
  click,

  /// The interaction also happens when the mouse pointer rests over the
  /// target. Tap/click keeps working.
  hover,
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
    this.groupAnimationCurve = Curves.easeOutCubic,
    this.hoverAnimationDuration = const Duration(milliseconds: 160),
    this.hoverAnimationCurve = Curves.easeOut,
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
    this.hoverEffect = DrawerHoverEffect.shadow,
    this.hoverShadowColor,
    this.hoverHighlightColor,
    this.railTrigger = DrawerActivationMode.click,
    this.groupTrigger = DrawerActivationMode.click,
    this.linkTrigger = DrawerActivationMode.click,
    this.railAutoCollapse = false,
    this.hoverOpenDelay = const Duration(milliseconds: 120),
    this.hoverCloseDelay = const Duration(milliseconds: 220),
    this.hoverSelectDelay = const Duration(milliseconds: 300),
    this.hoverAutoCollapseDelay = const Duration(milliseconds: 450),
    this.clickableCursor = SystemMouseCursors.click,
    this.inertCursor = SystemMouseCursors.basic,
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

  /// The curve of the group expand/collapse reveal and its chevron rotation.
  /// Defaults to [Curves.easeOutCubic].
  final Curve groupAnimationCurve;

  /// How long an item's hover feedback (the shadow lift or background tint)
  /// takes to fade in and out. Defaults to 160ms.
  final Duration hoverAnimationDuration;

  /// The curve of the hover feedback fade. Defaults to [Curves.easeOut].
  final Curve hoverAnimationCurve;

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

  /// Which visual feedback an item shows on hover. Defaults to
  /// [DrawerHoverEffect.shadow]. Use [DrawerHoverEffect.none] to disable the
  /// hover effect entirely (the press micro-scale still applies).
  final DrawerHoverEffect hoverEffect;

  /// The color of the soft shadow shown when hovering an item, used when
  /// [hoverEffect] is [DrawerHoverEffect.shadow]. Defaults to a translucent
  /// [ColorScheme.primary].
  final Color? hoverShadowColor;

  /// The background tint shown when hovering an item, used when [hoverEffect]
  /// is [DrawerHoverEffect.highlight]. Defaults to a subtle translucent
  /// [ColorScheme.primary].
  final Color? hoverHighlightColor;

  /// How the collapsed rail expands. With [DrawerActivationMode.hover], moving
  /// the mouse over the rail expands it after [hoverOpenDelay] and leaving
  /// collapses it again after [hoverCloseDelay] — a temporary "peek" that does
  /// not change the pinned [DrawerRailController.collapsed] state. The
  /// collapse/expand button keeps working and pins the state. Defaults to
  /// [DrawerActivationMode.click].
  ///
  /// A peek only ever widens a *collapsed* rail. To also close a drawer the
  /// user left expanded when the pointer leaves, set [railAutoCollapse].
  final DrawerActivationMode railTrigger;

  /// How a [DrawerGroup] opens, both as a flyout in the collapsed rail and
  /// inline in the expanded panel. With [DrawerActivationMode.hover] it opens
  /// after [hoverOpenDelay] and closes after [hoverCloseDelay] once the pointer
  /// leaves — but only if hover opened it, so a group you opened by clicking
  /// stays open. Defaults to [DrawerActivationMode.click].
  final DrawerActivationMode groupTrigger;

  /// How a [DrawerLink] is activated. With [DrawerActivationMode.hover],
  /// resting the pointer on a link for [hoverSelectDelay] selects it *and* runs
  /// its `onTap` — the same thing a click does, navigation included.
  ///
  /// Use with care: on a dense menu this can navigate away while the user is
  /// only passing the pointer through. The dwell delay exists to make that
  /// unlikely, not impossible. Defaults to [DrawerActivationMode.click].
  final DrawerActivationMode linkTrigger;

  /// How long the pointer must rest before a hover-triggered open fires, for
  /// [railTrigger] and [groupTrigger]. Defaults to 120ms.
  final Duration hoverOpenDelay;

  /// How long after the pointer leaves before a hover-opened rail or group
  /// closes. Long enough to survive crossing the gap between a rail button and
  /// its flyout. Defaults to 220ms.
  final Duration hoverCloseDelay;

  /// How long the pointer must rest on a link before [linkTrigger] activates
  /// it. Deliberately longer than [hoverOpenDelay] because the action
  /// navigates. Defaults to 300ms.
  final Duration hoverSelectDelay;

  /// Whether leaving the drawer with the pointer also collapses a drawer the
  /// user left *expanded*, not just one peeked open from the rail.
  ///
  /// Only has an effect when [railTrigger] is [DrawerActivationMode.hover].
  /// This makes hover symmetric — the drawer opens on enter and closes on exit
  /// — at the cost of taking away a panel the user deliberately pinned open, so
  /// it is opt-in and defaults to `false`. An explicit click on the
  /// collapse/expand button always re-pins the state and wins over hover.
  ///
  /// The close runs after [hoverAutoCollapseDelay], which is longer than
  /// [hoverCloseDelay] precisely because more is at stake.
  final bool railAutoCollapse;

  /// How long after the pointer leaves before [railAutoCollapse] collapses a
  /// pinned-open drawer. Deliberately longer than [hoverCloseDelay] so brushing
  /// past the drawer does not close it. Defaults to 450ms.
  final Duration hoverAutoCollapseDelay;

  /// The cursor shown over anything clickable: links, group headers, rail
  /// buttons and flyout items. Defaults to [SystemMouseCursors.click].
  final MouseCursor clickableCursor;

  /// The cursor shown over the drawer's non-interactive chrome — section
  /// headers, dividers and the background — so the pointer reliably reverts
  /// after leaving a clickable item. Defaults to [SystemMouseCursors.basic].
  final MouseCursor inertCursor;

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

  /// A ready-made preset for pointer-driven apps: the rail expands when the
  /// mouse enters it and collapses again when the pointer leaves, and groups
  /// open on hover too.
  ///
  /// [linkTrigger] is deliberately *not* switched to hover — navigating because
  /// the pointer paused over a link is hostile, and impossible to undo with the
  /// keyboard. Opt into it explicitly on [base] if you really want it.
  ///
  /// Layer it over your own styling by passing [base]:
  ///
  /// ```dart
  /// DrawerRail(
  ///   theme: DrawerRailTheme.hoverAdaptive(
  ///     base: const DrawerRailTheme(hoverEffect: DrawerHoverEffect.highlight),
  ///   ),
  ///   // ...
  /// );
  /// ```
  ///
  /// Touch devices never fire hover events, so the click path stays the only
  /// one that runs there — the preset is safe to use unconditionally.
  factory DrawerRailTheme.hoverAdaptive({
    DrawerRailTheme base = const DrawerRailTheme(),
    bool autoCollapse = true,
    Duration? openDelay,
    Duration? closeDelay,
    Duration? autoCollapseDelay,
  }) {
    return base.copyWith(
      railTrigger: DrawerActivationMode.hover,
      groupTrigger: DrawerActivationMode.hover,
      railAutoCollapse: autoCollapse,
      hoverOpenDelay: openDelay,
      hoverCloseDelay: closeDelay,
      hoverAutoCollapseDelay: autoCollapseDelay,
    );
  }

  /// Returns a copy of this theme with the given fields replaced.
  ///
  /// Passing `null` for a field keeps the current value; it never resets one
  /// back to "derive from the [ColorScheme]" — construct a new
  /// [DrawerRailTheme] for that.
  DrawerRailTheme copyWith({
    double? expandedWidth,
    double? railWidth,
    double? borderRadius,
    double? itemBorderRadius,
    DrawerRailPosition? position,
    Duration? animationDuration,
    Curve? animationCurve,
    Duration? groupAnimationDuration,
    Curve? groupAnimationCurve,
    Duration? hoverAnimationDuration,
    Curve? hoverAnimationCurve,
    double? iconSize,
    double? railIconSize,
    double? railItemHeight,
    double? pressedScale,
    bool? sectionUppercase,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? itemPadding,
    double? groupChildIndent,
    Color? backgroundColor,
    Color? selectedColor,
    Color? onSelectedColor,
    Color? iconColor,
    Color? labelColor,
    Color? sectionColor,
    Color? badgeTextColor,
    Color? badgeCountColor,
    Color? menuBackgroundColor,
    Color? searchFillColor,
    DrawerHoverEffect? hoverEffect,
    Color? hoverShadowColor,
    Color? hoverHighlightColor,
    DrawerActivationMode? railTrigger,
    DrawerActivationMode? groupTrigger,
    DrawerActivationMode? linkTrigger,
    bool? railAutoCollapse,
    Duration? hoverOpenDelay,
    Duration? hoverCloseDelay,
    Duration? hoverSelectDelay,
    Duration? hoverAutoCollapseDelay,
    MouseCursor? clickableCursor,
    MouseCursor? inertCursor,
    List<BoxShadow>? shadow,
    TextStyle? labelTextStyle,
    TextStyle? selectedLabelTextStyle,
    TextStyle? sectionTextStyle,
    TextStyle? badgeTextStyle,
    IconData? collapseIcon,
    IconData? expandIcon,
    IconData? searchIcon,
    IconData? clearSearchIcon,
    IconData? groupTrailingIcon,
  }) {
    return DrawerRailTheme(
      expandedWidth: expandedWidth ?? this.expandedWidth,
      railWidth: railWidth ?? this.railWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      position: position ?? this.position,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      groupAnimationDuration:
          groupAnimationDuration ?? this.groupAnimationDuration,
      groupAnimationCurve: groupAnimationCurve ?? this.groupAnimationCurve,
      hoverAnimationDuration:
          hoverAnimationDuration ?? this.hoverAnimationDuration,
      hoverAnimationCurve: hoverAnimationCurve ?? this.hoverAnimationCurve,
      iconSize: iconSize ?? this.iconSize,
      railIconSize: railIconSize ?? this.railIconSize,
      railItemHeight: railItemHeight ?? this.railItemHeight,
      pressedScale: pressedScale ?? this.pressedScale,
      sectionUppercase: sectionUppercase ?? this.sectionUppercase,
      contentPadding: contentPadding ?? this.contentPadding,
      itemPadding: itemPadding ?? this.itemPadding,
      groupChildIndent: groupChildIndent ?? this.groupChildIndent,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      onSelectedColor: onSelectedColor ?? this.onSelectedColor,
      iconColor: iconColor ?? this.iconColor,
      labelColor: labelColor ?? this.labelColor,
      sectionColor: sectionColor ?? this.sectionColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      badgeCountColor: badgeCountColor ?? this.badgeCountColor,
      menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
      searchFillColor: searchFillColor ?? this.searchFillColor,
      hoverEffect: hoverEffect ?? this.hoverEffect,
      hoverShadowColor: hoverShadowColor ?? this.hoverShadowColor,
      hoverHighlightColor: hoverHighlightColor ?? this.hoverHighlightColor,
      railTrigger: railTrigger ?? this.railTrigger,
      groupTrigger: groupTrigger ?? this.groupTrigger,
      linkTrigger: linkTrigger ?? this.linkTrigger,
      railAutoCollapse: railAutoCollapse ?? this.railAutoCollapse,
      hoverOpenDelay: hoverOpenDelay ?? this.hoverOpenDelay,
      hoverCloseDelay: hoverCloseDelay ?? this.hoverCloseDelay,
      hoverSelectDelay: hoverSelectDelay ?? this.hoverSelectDelay,
      hoverAutoCollapseDelay:
          hoverAutoCollapseDelay ?? this.hoverAutoCollapseDelay,
      clickableCursor: clickableCursor ?? this.clickableCursor,
      inertCursor: inertCursor ?? this.inertCursor,
      shadow: shadow ?? this.shadow,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      selectedLabelTextStyle:
          selectedLabelTextStyle ?? this.selectedLabelTextStyle,
      sectionTextStyle: sectionTextStyle ?? this.sectionTextStyle,
      badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
      collapseIcon: collapseIcon ?? this.collapseIcon,
      expandIcon: expandIcon ?? this.expandIcon,
      searchIcon: searchIcon ?? this.searchIcon,
      clearSearchIcon: clearSearchIcon ?? this.clearSearchIcon,
      groupTrailingIcon: groupTrailingIcon ?? this.groupTrailingIcon,
    );
  }

  /// Returns a copy of this theme resolved against [scheme], filling every
  /// nullable value with its default so the widgets can read non-null values.
  ///
  /// When [reduceMotion] is `true` — normally from
  /// [MediaQuery.disableAnimationsOf] — every animation *duration* collapses to
  /// [Duration.zero] so the drawer snaps between states instead of sliding.
  /// Hover dwell delays are deliberately left alone: they gate an interaction,
  /// not a motion effect, and zeroing them would make the drawer fire on the
  /// slightest pointer movement.
  ResolvedDrawerRailTheme resolve(
    ColorScheme scheme, {
    bool reduceMotion = false,
  }) {
    Duration motion(Duration d) => reduceMotion ? Duration.zero : d;
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
      animationDuration: motion(animationDuration),
      animationCurve: animationCurve,
      groupAnimationDuration: motion(groupAnimationDuration),
      groupAnimationCurve: groupAnimationCurve,
      hoverAnimationDuration: motion(hoverAnimationDuration),
      hoverAnimationCurve: hoverAnimationCurve,
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
      hoverEffect: hoverEffect,
      hoverShadowColor:
          hoverShadowColor ?? scheme.primary.withValues(alpha: 0.12),
      hoverHighlightColor:
          hoverHighlightColor ?? scheme.primary.withValues(alpha: 0.08),
      railTrigger: railTrigger,
      groupTrigger: groupTrigger,
      linkTrigger: linkTrigger,
      railAutoCollapse: railAutoCollapse,
      hoverOpenDelay: hoverOpenDelay,
      hoverCloseDelay: hoverCloseDelay,
      hoverSelectDelay: hoverSelectDelay,
      hoverAutoCollapseDelay: hoverAutoCollapseDelay,
      clickableCursor: clickableCursor,
      inertCursor: inertCursor,
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
    required this.groupAnimationCurve,
    required this.hoverAnimationDuration,
    required this.hoverAnimationCurve,
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
    required this.hoverEffect,
    required this.hoverShadowColor,
    required this.hoverHighlightColor,
    required this.railTrigger,
    required this.groupTrigger,
    required this.linkTrigger,
    required this.railAutoCollapse,
    required this.hoverOpenDelay,
    required this.hoverCloseDelay,
    required this.hoverSelectDelay,
    required this.hoverAutoCollapseDelay,
    required this.clickableCursor,
    required this.inertCursor,
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

  /// See [DrawerRailTheme.groupAnimationCurve].
  final Curve groupAnimationCurve;

  /// See [DrawerRailTheme.hoverAnimationDuration].
  final Duration hoverAnimationDuration;

  /// See [DrawerRailTheme.hoverAnimationCurve].
  final Curve hoverAnimationCurve;

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

  /// See [DrawerRailTheme.hoverEffect].
  final DrawerHoverEffect hoverEffect;

  /// The resolved hover shadow color.
  final Color hoverShadowColor;

  /// The resolved hover highlight color.
  final Color hoverHighlightColor;

  /// See [DrawerRailTheme.railTrigger].
  final DrawerActivationMode railTrigger;

  /// See [DrawerRailTheme.groupTrigger].
  final DrawerActivationMode groupTrigger;

  /// See [DrawerRailTheme.linkTrigger].
  final DrawerActivationMode linkTrigger;

  /// See [DrawerRailTheme.hoverOpenDelay].
  final Duration hoverOpenDelay;

  /// See [DrawerRailTheme.hoverCloseDelay].
  final Duration hoverCloseDelay;

  /// See [DrawerRailTheme.hoverSelectDelay].
  final Duration hoverSelectDelay;

  /// See [DrawerRailTheme.railAutoCollapse].
  final bool railAutoCollapse;

  /// See [DrawerRailTheme.hoverAutoCollapseDelay].
  final Duration hoverAutoCollapseDelay;

  /// See [DrawerRailTheme.clickableCursor].
  final MouseCursor clickableCursor;

  /// See [DrawerRailTheme.inertCursor].
  final MouseCursor inertCursor;

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
