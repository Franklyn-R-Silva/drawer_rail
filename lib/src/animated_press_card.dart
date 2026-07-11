import 'package:flutter/material.dart';

/// An interactive container that gives springy, tactile feedback: it scales
/// down slightly on press and lifts with a soft shadow on hover.
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
  });

  /// The content of the card.
  final Widget child;

  /// Called when the card is tapped. When `null`, press/hover effects are off.
  final VoidCallback? onTap;

  /// The rounding used for the hover shadow.
  final BorderRadius borderRadius;

  /// The scale factor applied while the card is pressed. Defaults to `0.97`.
  final double pressedScale;

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
    return MouseRegion(
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                boxShadow: _hovered && widget.onTap != null
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
