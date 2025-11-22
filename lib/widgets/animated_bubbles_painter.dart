import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBubblesPainter extends CustomPainter {
  final Animation<double> animation;
  
  AnimatedBubblesPainter(this.animation) : super(repaint: animation);

  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(0);
    
    // Draw multiple semi-transparent circles (bubbles)
    for (int i = 0; i < 20; i++) {
      final x = size.width * (random.nextDouble());
      final y = size.height * (random.nextDouble());
      final radius = 20 + 80 * random.nextDouble();
      final color = Colors.white.withOpacity(0.05 + 0.05 * random.nextDouble());
      final offset = Offset(x, y);
      
      paint.color = color;
      
      // Animate the radius and position for a floating effect
      final animatedRadius = radius * (1 + 0.5 * math.sin(animation.value * 2 * math.pi + i));
      final animatedOffset = offset + Offset(
        10 * math.sin(animation.value * math.pi + i),
        10 * math.cos(animation.value * math.pi + i),
      );
      
      canvas.drawCircle(animatedOffset, animatedRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
