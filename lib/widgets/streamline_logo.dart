import 'package:flutter/material.dart';

/// Custom logo widget untuk Streamline
/// Mereplikasi logo "S" dengan desain curved yang stylish
class StreamlineLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const StreamlineLogo({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StreamlineLogoPainter(
        color: color ?? Colors.white,
      ),
    );
  }
}

class _StreamlineLogoPainter extends CustomPainter {
  final Color color;

  _StreamlineLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Ukuran relatif
    final width = size.width;
    final height = size.height;

    // Upper curve (seperti huruf C terbalik)
    final upperCurveRect = Rect.fromLTWH(
      width * 0.15,
      height * 0.05,
      width * 0.7,
      height * 0.45,
    );

    path.addArc(
      upperCurveRect,
      -0.3, // Start angle (radian)
      3.8,  // Sweep angle (hampir full circle tapi terbuka di kiri)
    );

    // Lower curve (seperti huruf C normal)
    final lowerCurveRect = Rect.fromLTWH(
      width * 0.15,
      height * 0.5,
      width * 0.7,
      height * 0.45,
    );

    path.addArc(
      lowerCurveRect,
      3.4,  // Start angle
      -3.8, // Sweep angle (berlawanan arah)
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated version of Streamline Logo
class AnimatedStreamlineLogo extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const AnimatedStreamlineLogo({
    super.key,
    this.size = 32,
    this.color,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<AnimatedStreamlineLogo> createState() => _AnimatedStreamlineLogoState();
}

class _AnimatedStreamlineLogoState extends State<AnimatedStreamlineLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _AnimatedStreamlineLogoPainter(
            color: widget.color ?? Colors.white,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class _AnimatedStreamlineLogoPainter extends CustomPainter {
  final Color color;
  final double progress;

  _AnimatedStreamlineLogoPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final width = size.width;
    final height = size.height;

    // Upper curve dengan animasi
    final upperCurveRect = Rect.fromLTWH(
      width * 0.15,
      height * 0.05,
      width * 0.7,
      height * 0.45,
    );

    // Hanya draw sebagian path berdasarkan progress
    if (progress < 0.5) {
      final sweepAngle = 3.8 * (progress * 2);
      path.addArc(upperCurveRect, -0.3, sweepAngle);
    } else {
      path.addArc(upperCurveRect, -0.3, 3.8);
      
      // Lower curve
      final lowerCurveRect = Rect.fromLTWH(
        width * 0.15,
        height * 0.5,
        width * 0.7,
        height * 0.45,
      );
      
      final lowerProgress = (progress - 0.5) * 2;
      final sweepAngle = -3.8 * lowerProgress;
      path.addArc(lowerCurveRect, 3.4, sweepAngle);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AnimatedStreamlineLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
