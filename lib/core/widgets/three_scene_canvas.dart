import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

enum _CanvasState { loading, loaded, error }

class ThreeSceneContext {
  ThreeSceneContext({
    required this.scene,
    required this.camera,
    required this.renderer,
    required this.orbit,
    required this.width,
    required this.height,
  });

  final three.Scene scene;
  final three.PerspectiveCamera camera;
  final three.WebGLRenderer renderer;
  final three_jsm.OrbitControls orbit;
  final double width;
  final double height;

  void render() {
    renderer.render(scene, camera);
  }
}

class ThreeSceneController {
  ThreeSceneContext? _context;

  ThreeSceneContext? get context => _context;

  bool get isReady => _context != null;

  void _attach(ThreeSceneContext context) {
    _context = context;
  }

  void _detach() {
    _context = null;
  }

  void renderOnce() {
    final context = _context;
    if (context == null) return;
    try {
      context.render();
    } catch (_) {}
  }

  void setCamera(
    double x,
    double y,
    double z, {
    double targetX = 0,
    double targetY = 0,
    double targetZ = 0,
  }) {
    final context = _context;
    if (context == null) return;
    context.camera.position.set(x, y, z);
    context.orbit.target.set(targetX, targetY, targetZ);
    try {
      context.orbit.update();
      context.render();
    } catch (_) {}
  }
}

class ThreeSceneCanvas extends StatefulWidget {
  const ThreeSceneCanvas({
    super.key,
    required this.controller,
    required this.setup,
    this.onTick,
    this.initialCamera = const [0, 0, 50],
    this.target = const [0, 0, 0],
    this.minDistance = 5,
    this.maxDistance = 500,
    this.backgroundColor = Colors.black,
  });

  final ThreeSceneController controller;
  final Future<void> Function(ThreeSceneContext context) setup;
  final void Function(ThreeSceneContext context, double dt)? onTick;
  final List<double> initialCamera;
  final List<double> target;
  final double minDistance;
  final double maxDistance;
  final Color backgroundColor;

  @override
  State<ThreeSceneCanvas> createState() => _ThreeSceneCanvasState();
}

class _ThreeSceneCanvasState extends State<ThreeSceneCanvas>
    with TickerProviderStateMixin {
  final GlobalKey<three_jsm.DomLikeListenableState> _domLikeKey = GlobalKey();

  FlutterGlPlugin? _gl;
  three_jsm.OrbitControls? _orbit;
  ThreeSceneContext? _context;
  Ticker? _ticker;

  double? _width;
  double? _height;
  double _dpr = 1.0;
  bool _initStarted = false;

  _CanvasState _state = _CanvasState.loading;
  String? _error;
  Duration _lastElapsed = Duration.zero;

  @override
  void dispose() {
    widget.controller._detach();
    _ticker?.dispose();
    _orbit?.dispose();
    final gl = _gl;
    if (gl != null && gl.textureId != null) {
      try {
        gl.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  void _initSize(Size size) {
    if (_initStarted || !size.isFinite || size.isEmpty) return;
    _initStarted = true;
    _width = size.width;
    _height = size.height;
    _dpr = MediaQuery.of(context).devicePixelRatio;
    _initPlatform();
  }

  Future<void> _initPlatform() async {
    if (_width == null || _height == null) {
      _fail('Ukuran layar tidak tersedia');
      return;
    }
    try {
      _gl = FlutterGlPlugin();
      await _gl!.initialize(
        options: {
          'antialias': true,
          'alpha': true,
          'width': _width!.toInt(),
          'height': _height!.toInt(),
          'dpr': _dpr,
        },
      );
      if (!mounted) return;
      setState(() {});
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted || _gl == null) return;
      await _gl!.prepareContext();
      if (!mounted) return;
      await _initScene();
    } catch (error) {
      _fail('Gagal init 3D: $error');
    }
  }

  Future<void> _initScene() async {
    if (_width == null || _height == null || _gl == null) return;
    if (!mounted) return;

    _ticker?.stop();
    _context = null;
    widget.controller._detach();

    setState(() {
      _state = _CanvasState.loading;
      _error = null;
    });

    try {
      final renderer = three.WebGLRenderer({
        'antialias': true,
        'alpha': true,
        'width': _width!.toInt(),
        'height': _height!.toInt(),
        'dpr': _dpr,
        'gl': _gl!.gl,
      });
      renderer.setPixelRatio(_dpr);
      renderer.setSize(_width!, _height!);

      final scene = three.Scene();
      final camera = three.PerspectiveCamera(45, _width! / _height!, 0.1, 1000);

      if (_domLikeKey.currentState == null) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (!mounted) return;

      final orbit = three_jsm.OrbitControls(camera, _domLikeKey)
        ..enableDamping = true
        ..dampingFactor = 0.08
        ..rotateSpeed = 0.6
        ..zoomSpeed = 0.8
        ..minDistance = widget.minDistance
        ..maxDistance = widget.maxDistance;

      camera.position.set(
        widget.initialCamera[0],
        widget.initialCamera[1],
        widget.initialCamera[2],
      );
      orbit.target.set(widget.target[0], widget.target[1], widget.target[2]);
      orbit.update();

      final context = ThreeSceneContext(
        scene: scene,
        camera: camera,
        renderer: renderer,
        orbit: orbit,
        width: _width!,
        height: _height!,
      );

      await widget.setup(context);
      if (!mounted) return;

      _orbit = orbit;
      _context = context;
      widget.controller._attach(context);

      setState(() {
        _state = _CanvasState.loaded;
      });

      context.render();

      _lastElapsed = Duration.zero;
      _ticker ??= createTicker(_onTick);
      _ticker!.start();
    } catch (error) {
      _fail('Gagal memuat scene 3D: $error');
    }
  }

  void _onTick(Duration elapsed) {
    final context = _context;
    if (context == null) return;
    final delta = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    final dt = delta.clamp(0.0, 0.05);
    try {
      context.orbit.update();
    } catch (_) {}
    try {
      widget.onTick?.call(context, dt);
    } catch (_) {}
    try {
      context.render();
    } catch (_) {}
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _state = _CanvasState.error;
      _error = message;
    });
  }

  void _retry() {
    if (_gl == null || !_gl!.isInitialized) {
      _initPlatform();
    } else {
      _initScene();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initSize(constraints.biggest);
        return three_jsm.DomLikeListenable(
          key: _domLikeKey,
          builder: (context) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: widget.backgroundColor),
                if (_state == _CanvasState.loading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  )
                else if (_state == _CanvasState.error)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 44,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error ?? 'Gagal memuat scene 3D',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_gl != null && _gl!.isInitialized)
                  if (kIsWeb)
                    HtmlElementView(viewType: _gl!.textureId!.toString())
                  else
                    Texture(textureId: _gl!.textureId!),
              ],
            );
          },
        );
      },
    );
  }
}
