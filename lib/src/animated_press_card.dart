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
  });

  /// The content of the card.
  final Widget child;

  /// Called when the card is tapped. When `null`, press/hover effects are off.
  final VoidCallback? onTap;

  /// The rounding used for the hover shadow/highlight.
  final BorderRadius borderRadius;

  /// The scale factor applied while the card is pressed. Defaults to `0.97`.
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

  @override
  State<AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<AnimatedPressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1, end: widget.pressedScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null;
    final scheme = Theme.of(context).colorScheme;

    BoxDecoration decoration;
    if (active && _hovered && widget.hoverEffect == DrawerHoverEffect.shadow) {
      decoration = BoxDecoration(
        borderRadius: widget.borderRadius,
        color: widget.surfaceColor ?? scheme.surface,
        boxShadow: [
          BoxShadow(
            color: widget.hoverShadowColor ??
                scheme.primary.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: widget.borderRadius,
        color: widget.baseColor ?? Colors.transparent,
      );
    }

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: Container(
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
              onHover: (isHovering) {
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
