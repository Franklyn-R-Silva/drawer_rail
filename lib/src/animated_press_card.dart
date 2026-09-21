import 'package:flutter/material.dart';

import 'drawer_rail_theme.dart';

/// An interactive container that gives springy, tactile feedback: it scales
/// down slightly on press and, on hover, either lifts with a soft shadow or
/// tints its background — see [hoverEffect].
///
/// Used internally by [DrawerRail] for every tappable item, but exported so it
/// can be reused in custom header/footer builders for a consistent feel.
class AnimatedPressCard extends StatefulWidget {
  /// Creates an animated press card wrapping [child].
  const AnimatedPressCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.pressedScale = 0.97,
    this.hoverEffect = DrawerHoverEffect.shadow,
    this.hoverShadowColor,
    this.hoverHighlightColor,
    this.surfaceColor,
    this.baseColor,
    this.hoverAnimationDuration = const Duration(milliseconds: 160),
    this.hoverAnimationCurve = Curves.easeOut,
    this.clickableCursor = SystemMouseCursors.click,
    this.inertCursor = SystemMouseCursors.basic,
    this.pressAnimationDuration = const Duration(milliseconds: 140),
  });

  /// The content of the card.
  final Widget child;

  /// Called when the card is tapped. When `null`, press/hover effects are off.
  final VoidCallback? onTap;

  /// The rounding used for the hover shadow/highlight.
  final BorderRadius borderRadius;

  /// The scale factor applied while the card is pressed. Defaults to `0.97`.
  ///
  /// Set it to `1` to turn the press micro-scale off entirely — which is what
  /// [DrawerRailTheme.resolve] does when the platform asks for reduced motion,
  /// since a scale is movement however short its duration.
  final double pressedScale;

  /// Which visual feedback to show on hover. Defaults to
  /// [DrawerHoverEffect.shadow].
  final DrawerHoverEffect hoverEffect;

  /// The color of the soft shadow shown on hover, used when [hoverEffect] is
  /// [DrawerHoverEffect.shadow]. Defaults to a translucent [ColorScheme.primary].
  final Color? hoverShadowColor;

  /// The background tint shown on hover, used when [hoverEffect] is
  /// [DrawerHoverEffect.highlight]. Defaults to a subtle translucent
  /// [ColorScheme.primary].
  final Color? hoverHighlightColor;

  /// The opaque surface painted behind the card in [DrawerHoverEffect.shadow]
  /// mode, so the shadow reads as elevation instead of bleeding through the
  /// (often transparent) child as a colored haze. Defaults to the ambient
  /// [ColorScheme.surface].
  final Color? surfaceColor;

  /// The base background color of the card.
  final Color? baseColor;

  /// How long the hover shadow/tint takes to fade in and out. Defaults to
  /// 160ms. Set to [Duration.zero] to snap, which is what the drawer does when
  /// the platform asks for reduced motion.
  final Duration hoverAnimationDuration;

  /// The curve of the hover fade. Defaults to [Curves.easeOut].
  final Curve hoverAnimationCurve;

  /// The cursor shown while the card is interactive, i.e. [onTap] is non-null.
  /// Defaults to [SystemMouseCursors.click].
  final MouseCursor clickableCursor;

  /// The cursor shown while the card is inert, i.e. [onTap] is `null`. Defaults
  /// to [SystemMouseCursors.basic], so the pointer reverts instead of keeping
  /// the click cursor from a neighbouring item.
  final MouseCursor inertCursor;

  /// How long the press micro-scale takes. Defaults to 140ms; [Duration.zero]
  /// alongside a [pressedScale] of `1` is how the card goes completely still.
  final Duration pressAnimationDuration;

  @override
  State<AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<AnimatedPressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;
  bool _hovered = false;

  /// Whether the press is worth animating at all. A scale of `1` means the card
  /// was asked to stay still — under reduced motion, typically — so the ticker
  /// is left alone entirely rather than driven through a no-op tween.
  bool get _scales => widget.pressedScale != 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pressAnimationDuration,
    );
    _scale = _buildScale();
  }

  Animation<double> _buildScale() =>
      Tween<double>(begin: 1, end: widget.pressedScale).animate(
        CurvedAnimation(
          parent: _controller,
          // Press in crisply, release with a slight overshoot so the item
          // springs back to size instead of easing flatly into it.
          curve: Curves.easeOut,
          reverseCurve: Curves.easeOutBack,
        ),
      );

  @override
  void didUpdateWidget(AnimatedPressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The tween used to be built once in initState, so a theme change — a
    // different pressedScale, or reduced motion switching on — went unnoticed
    // for the lifetime of the card.
    if (widget.pressAnimationDuration != oldWidget.pressAnimationDuration) {
      _controller.duration = widget.pressAnimationDuration;
    }
    if (widget.pressedScale != oldWidget.pressedScale) {
      _scale = _buildScale();
      if (!_scales) _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null && _scales) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null && _scales) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null && _scales) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null;
    final scheme = Theme.of(context).colorScheme;
    final base = widget.baseColor ?? Colors.transparent;
    final lifted =
        active && _hovered && widget.hoverEffect == DrawerHoverEffect.shadow;

    // A shadow needs something opaque to sit under, or it bleeds through the
    // (usually transparent) child as a colored haze. An already-opaque base —
    // the selected pill — is that surface, so keep it and it no longer loses
    // its color the moment the pointer arrives.
    final BoxDecoration decoration = BoxDecoration(
      borderRadius: widget.borderRadius,
      color:
          lifted && base.a < 1 ? (widget.surfaceColor ?? scheme.surface) : base,
      boxShadow: lifted
          ? [
              BoxShadow(
                color: widget.hoverShadowColor ??
                    scheme.primary.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: AnimatedContainer(
          duration: widget.hoverAnimationDuration,
          curve: widget.hoverAnimationCurve,
          decoration: decoration,
          child: Material(
            type: MaterialType.transparency,
            borderRadius: widget.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              // Stated rather than inherited, so the pointer is guaranteed to
              // become a hand over anything tappable and to revert over
              // anything that is not.
              mouseCursor: active ? widget.clickableCursor : widget.inertCursor,
              onHover: (isHovering) {
                if (_hovered == isHovering) return;
                setState(() => _hovered = isHovering);
              },
              hoverColor:
                  (active && widget.hoverEffect == DrawerHoverEffect.highlight)
                      ? (widget.hoverHighlightColor ??
                          scheme.primary.withValues(alpha: 0.08))
                      : Colors.transparent,
              splashColor: scheme.primary.withValues(alpha: 0.12),
              highlightColor: scheme.primary.withValues(alpha: 0.05),
              child: child,
            ),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
