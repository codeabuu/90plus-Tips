import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedDots extends StatefulWidget {
  final Color color;
  final double size;
  
  const AnimatedDots({
    super.key,
    this.color = Colors.grey,
    this.size = 11.0,
  });

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        '...',
        style: TextStyle(fontSize: widget.size, color: widget.color, letterSpacing: -1),
      ),
    );
  }
}