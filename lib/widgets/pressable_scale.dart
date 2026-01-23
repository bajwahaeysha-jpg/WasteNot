import 'package:flutter/material.dart';

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  double _scale = 1;

  void _down(_) => setState(() => _scale = 0.97);
  void _up(_) => setState(() => _scale = 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: () => _scale = 1,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
