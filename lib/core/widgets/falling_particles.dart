import 'dart:math' as math;

import 'package:flutter/material.dart';

enum FallingParticleMode { star, leaf }

class FallingParticles extends StatefulWidget {
  const FallingParticles({
    super.key,
    this.mode = FallingParticleMode.star,
    this.count = 40,
    this.speed = 1.0,
    this.colors = const [Colors.white, Colors.amber, Colors.lightBlueAccent],
    this.enabled = true,
  });

  final FallingParticleMode mode;
  final int count;
  final double speed;
  final List<Color> colors;
  final bool enabled;

  @override
  State<FallingParticles> createState() => _FallingParticlesState();
}

class _FallingParticlesState extends State<FallingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final math.Random _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) => _spawn(initial: true));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    final reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.reduceMotion;
    if (widget.enabled && !reduceMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FallingParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _Particle _spawn({bool initial = false}) {
    final size = 2 + _rng.nextDouble() * 4;
    return _Particle(
      x: _rng.nextDouble(),
      y: initial ? _rng.nextDouble() : -0.05,
      size: size,
      speed: (0.05 + _rng.nextDouble() * 0.15) * widget.speed,
      drift: (_rng.nextDouble() - 0.5) * 0.02,
      rotation: _rng.nextDouble() * math.pi * 2,
      rotationSpeed: (_rng.nextDouble() - 0.5) * 0.05,
      opacity: 0.4 + _rng.nextDouble() * 0.6,
      color: widget.colors[_rng.nextInt(widget.colors.length)],
    );
  }

  void _tick() {
    for (final p in _particles) {
      p.y += p.speed * 0.016;
      p.x += p.drift * 0.016;
      p.rotation += p.rotationSpeed;
      if (p.y > 1.05 || p.x < -0.05 || p.x > 1.05) {
        final np = _spawn();
        p.x = np.x;
        p.y = np.y;
        p.size = np.size;
        p.speed = np.speed;
        p.drift = np.drift;
        p.rotation = np.rotation;
        p.rotationSpeed = np.rotationSpeed;
        p.opacity = np.opacity;
        p.color = np.color;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).accessibleNavigation;
    if (!widget.enabled || reduceMotion) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          _tick();
          return CustomPaint(
            painter: _FallingPainter(
              particles: _particles,
              mode: widget.mode,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.color,
  });

  double x;
  double y;
  double size;
  double speed;
  double drift;
  double rotation;
  double rotationSpeed;
  double opacity;
  Color color;
}

class _FallingPainter extends CustomPainter {
  _FallingPainter({required this.particles, required this.mode});

  final List<_Particle> particles;
  final FallingParticleMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x * size.width;
      final dy = p.y * size.height;
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.rotation);
      if (mode == FallingParticleMode.star) {
        _drawStar(canvas, p.size, paint);
      } else {
        _drawLeaf(canvas, p.size, paint);
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double r, Paint paint) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points - math.pi / 2;
      final radius = i.isEven ? r : r * 0.4;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLeaf(Canvas canvas, double s, Paint paint) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: s * 1.6,
      height: s * 0.8,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _FallingPainter oldDelegate) => true;
}