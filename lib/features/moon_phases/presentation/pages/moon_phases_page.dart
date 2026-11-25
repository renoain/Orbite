import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';import 'package:flutter_gl/flutter_gl.dart';
import 'package:orbite/features/solar_system/domain/entities/config_options.dart';
import 'package:orbite/features/solar_system/res/assets/textures.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

enum _SceneState { loading, loaded, error }

class MoonPhasesPage extends StatefulWidget {
  const MoonPhasesPage({super.key});

  @override
  State<MoonPhasesPage> createState() => _MoonPhasesPageState();
}

class _MoonPhasesPageState extends State<MoonPhasesPage>
    with TickerProviderStateMixin {
  late final GlobalKey<three_jsm.DomLikeListenableState> _domLikeKey;

  FlutterGlPlugin? _gl;
  three.WebGLRenderer? _renderer;
  three.Scene? _scene;
  three.PerspectiveCamera? _camera;
  three_jsm.OrbitControls? _orbit;
  Ticker? _ticker;

  double? _width;
  double? _height;
  Size? _screenSize;
  double _dpr = 1.0;

  _SceneState _sceneState = _SceneState.loading;
  String? _errorMessage;

  three.Mesh? _sun;
  three.Mesh? _earth;
  three.Mesh? _moon;

  double _earthAngle = 0.0;
  double _phaseT = 0.0;
  double _speed = 1.0;
  bool _playing = true;
  Duration _lastElapsed = Duration.zero;
  bool _showExplanation = false;

  String _phaseName = 'Bulan Baru';

  static const double _earthOrbit = 40.0;
  static const double _moonOrbit = 9.0;
  static const double _phaseSpeed = 2 * math.pi / 30.0;

  @override
  void initState() {
    super.initState();
    _domLikeKey = GlobalKey();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _orbit?.dispose();
    super.dispose();
  }

  void _initSize(Size size) {
    if (_screenSize != null || !size.isFinite || size.isEmpty) return;
    _screenSize = size;
    _dpr = MediaQuery.of(context).devicePixelRatio;
    _initPlatform();
  }

  Future<void> _initPlatform() async {
    if (_screenSize == null) {
      setState(() {
        _sceneState = _SceneState.error;
        _errorMessage = 'Ukuran layar tidak tersedia';
      });
      return;
    }
    _width = _screenSize!.width;
    _height = _screenSize!.height;

    try {
      _gl = FlutterGlPlugin();
      final options = ConfigOptions(
        antialias: true,
        alpha: true,
        width: _width!.toInt(),
        height: _height!.toInt(),
        dpr: _dpr,
      );
      await _gl!.initialize(options: options.toMap());
      if (!mounted) return;
      setState(() {});
      Future.delayed(const Duration(milliseconds: 100), () async {
        if (!mounted || _gl == null) return;
        await _gl!.prepareContext();
        if (!mounted) return;
        await _initScene();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _sceneState = _SceneState.error;
          _errorMessage = 'Gagal init 3D: $e';
        });
      }
    }
  }

  Future<void> _initScene() async {
    if (_width == null || _height == null || _gl == null) return;
    setState(() {
      _sceneState = _SceneState.loading;
      _errorMessage = null;
    });

    try {
      final renderOptions = ConfigOptions(
        antialias: true,
        alpha: true,
        width: _width!.toInt(),
        height: _height!.toInt(),
        dpr: _dpr,
        gl: _gl!.gl,
      );
      _renderer = three.WebGLRenderer(renderOptions.toMap());
      _renderer!.setPixelRatio(_dpr);
      _renderer!.setSize(_width!, _height!);

      _scene = three.Scene();

      _camera = three.PerspectiveCamera(45, _width! / _height!, 0.1, 1000);

      if (_domLikeKey.currentState == null) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final orbit = three_jsm.OrbitControls(_camera!, _domLikeKey)
        ..enableDamping = true
        ..dampingFactor = 0.08
        ..rotateSpeed = 0.6
        ..zoomSpeed = 0.8
        ..minDistance = 20
        ..maxDistance = 200;
      _orbit = orbit;

      _camera!.position.set(0, 40, 90);
      _camera!.lookAt(three.Vector3(0, 0, 0));
      orbit.update();

      // Lights
      _scene!.add(three.AmbientLight(0xffffff, 0.35));
      final pointLight = three.PointLight(0xffffff, 2.0, 500);
      pointLight.position.set(0, 0, 0);
      _scene!.add(pointLight);

      // Sun
      final sunTex = await three.TextureLoader(null).loadAsync(textureSun);
      final sunGeo = three.SphereGeometry(6, 32, 32);
      final sunMat = three.MeshBasicMaterial({'map': sunTex});
      _sun = three.Mesh(sunGeo, sunMat);
      _sun!.name = 'sun';
      _scene!.add(_sun!);

      // Sun glow
      final glowGeo = three.SphereGeometry(9, 32, 32);
      final glowMat = three.MeshBasicMaterial({
        'color': 0xffaa33,
        'transparent': true,
        'opacity': 0.15,
      });
      final glow = three.Mesh(glowGeo, glowMat);
      _scene!.add(glow);

      // Earth
      final earthTex = await three.TextureLoader(null).loadAsync(textureEarth);
      final earthGeo = three.SphereGeometry(2.2, 32, 32);
      final earthMat = three.MeshPhongMaterial({'map': earthTex});
      _earth = three.Mesh(earthGeo, earthMat);
      _earth!.name = 'earth';
      _scene!.add(_earth!);

      // Moon
      final moonTex = await three.TextureLoader(null).loadAsync(textureMoon);
      final moonGeo = three.SphereGeometry(0.9, 24, 24);
      final moonMat = three.MeshPhongMaterial({'map': moonTex});
      _moon = three.Mesh(moonGeo, moonMat);
      _moon!.name = 'moon';
      _scene!.add(_moon!);

      // Starfield
      final positions = <double>[];
      final rng = math.Random(7);
      for (var i = 0; i < 1200; i++) {
        positions.add((rng.nextDouble() - 0.5) * 400);
        positions.add((rng.nextDouble() - 0.5) * 400);
        positions.add((rng.nextDouble() - 0.5) * 400);
      }
      final starGeo = three.BufferGeometry();
      starGeo.setAttribute(
        'position',
        three.Float32BufferAttribute(Float32Array.from(positions), 3, false),
      );
      final starMat = three.PointsMaterial({'color': 0xffffff, 'size': 1.0});
      final stars = three.Points(starGeo, starMat);
      _scene!.add(stars);

      // Initial positions
      _updatePositions();

      if (!mounted) return;
      setState(() {
        _sceneState = _SceneState.loaded;
      });

      _ticker ??= createTicker(_onTick);
      if (_playing) _ticker!.start();
    } catch (e) {
      if (mounted) {
        setState(() {
          _sceneState = _SceneState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _updatePositions() {
    final earthX = _earthOrbit * math.cos(_earthAngle);
    final earthZ = _earthOrbit * math.sin(_earthAngle);
    if (_earth != null) {
      _earth!.position.set(earthX, 0, earthZ);
    }
    final moonDir = _earthAngle + math.pi - _phaseT;
    final moonX = earthX + _moonOrbit * math.cos(moonDir);
    final moonZ = earthZ + _moonOrbit * math.sin(moonDir);
    if (_moon != null) {
      _moon!.position.set(moonX, 0, moonZ);
    }
    if (_sun != null) {
      _sun!.position.set(0, 0, 0);
    }
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    final renderer = _renderer;
    if (renderer == null) return;
    final dt = delta.clamp(0.0, 0.05);

    _orbit?.update();

    if (_sceneState == _SceneState.loaded &&
        _playing &&
        _earth != null &&
        _moon != null) {
      _earthAngle += 0.1 * dt * _speed;
      _phaseT += _phaseSpeed * dt * _speed;
      if (_phaseT >= 2 * math.pi) _phaseT -= 2 * math.pi;
      _updatePositions();
      _earth!.rotateY(0.3 * dt);
      _moon!.rotateY(0.2 * dt);

      final newPhase = _computePhaseName(_phaseT);
      if (mounted && newPhase != _phaseName) {
        setState(() => _phaseName = newPhase);
      }
    }

    try {
      renderer.render(_scene!, _camera!);
    } catch (_) {}
  }

  static String _computePhaseName(double t) {
    // t: 0 new moon, pi/2 first quarter, pi full, 3pi/2 last quarter
    final deg = t * 180 / math.pi;
    if (deg < 22.5 || deg >= 337.5) return 'Bulan Baru';
    if (deg < 67.5) return 'Bulan Sabit Awal';
    if (deg < 112.5) return 'Kuartar Pertama';
    if (deg < 157.5) return 'Bulan Cembung Awal';
    if (deg < 202.5) return 'Bulan Penuh';
    if (deg < 247.5) return 'Bulan Cembung Akhir';
    if (deg < 292.5) return 'Kuartar Terakhir';
    return 'Bulan Sabit Akhir';
  }

  void _togglePlay() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _ticker?.start();
      } else {
        _ticker?.stop();
      }
    });
  }

  void _retry() {
    _initScene();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fase Bulan 3D'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _initSize(constraints.biggest);
                return three_jsm.DomLikeListenable(
                  key: _domLikeKey,
                  builder: (context) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black,
                            child: Builder(
                              builder: (_) {
                                if (_sceneState == _SceneState.loading) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white54,
                                    ),
                                  );
                                }
                                if (_sceneState == _SceneState.error) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: Colors.red, size: 48),
                                        const SizedBox(height: 12),
                                        Text(
                                          _errorMessage ?? 'Gagal memuat',
                                          style: const TextStyle(
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: _retry,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Coba Lagi'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                if (_gl != null && _gl!.isInitialized) {
                                  if (kIsWeb) {
                                    return HtmlElementView(
                                      viewType: _gl!.textureId!.toString(),
                                    );
                                  }
                                  return Texture(textureId: _gl!.textureId!);
                                }
                                return const SizedBox.expand();
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _MoonPhaseDiscPainter(phase: _phaseT),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _phaseName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tampilan dari Bumi',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Sudut fase: ${(_phaseT * 180 / math.pi).toStringAsFixed(0)}°',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _togglePlay,
                      icon: Icon(
                        _playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _speed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 3,
                        label: '${_speed}x',
                        onChanged: (v) => setState(() => _speed = v),
                      ),
                    ),
                    Text(
                      '${_speed}x',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _showExplanation = !_showExplanation),
                  child: Text(_showExplanation ? 'Sembunyikan penjelasan' : 'Tampilkan penjelasan'),
                ),
                if (_showExplanation)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Fase Bulan memengaruhi pasang surut dan pencahayaan malam. Bulan baru: gelap; purnama: terang; kuartar: pasang perbani.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Text(
                  'Drag untuk memutar kamera, scroll untuk zoom.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoonPhaseDiscPainter extends CustomPainter {
  _MoonPhaseDiscPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final darkPaint = Paint()..color = const Color(0xFF1A1A1A);
    final lightPaint = Paint()..color = const Color(0xFFD9D9D9);
    final rimPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    double drawPhase = phase;
    bool mirror = phase > math.pi;
    if (mirror) drawPhase = 2 * math.pi - phase;

    if (mirror) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(-1, 1);
      canvas.translate(-center.dx, -center.dy);
    }

    canvas.drawCircle(center, radius, darkPaint);

    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    const steps = 24;
    for (var i = 1; i <= steps; i++) {
      final y = -radius + (2 * radius * i / steps);
      final t = (y / radius).clamp(-1.0, 1.0);
      final x = radius * math.cos(drawPhase) * math.sqrt(1 - t * t);
      path.lineTo(center.dx + x, center.dy + y);
    }
    path.arcTo(rect, math.pi / 2, -math.pi, false);
    path.close();
    canvas.drawPath(path, lightPaint);

    if (mirror) {
      canvas.restore();
    }
    canvas.restore();

    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _MoonPhaseDiscPainter oldDelegate) =>
      oldDelegate.phase != phase;
}