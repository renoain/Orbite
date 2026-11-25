import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:orbite/features/solar_system/domain/entities/config_options.dart';
import 'package:three_dart/three_dart.dart' as three;

class RotatingPlanet3D extends StatefulWidget {
  const RotatingPlanet3D({
    super.key,
    required this.texturePath,
    this.size = 150,
  });

  final String texturePath;
  final double size;

  @override
  State<RotatingPlanet3D> createState() => _RotatingPlanet3DState();
}

class _RotatingPlanet3DState extends State<RotatingPlanet3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  FlutterGlPlugin? _gl;
  three.WebGLRenderer? _renderer;
  three.Scene? _scene;
  three.PerspectiveCamera? _camera;
  three.Mesh? _mesh;

  bool _is3DReady = false;
  bool _initStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _controller.addListener(_onTick);
    _startInit();
  }

  Future<void> _startInit() async {
    if (_initStarted) return;
    _initStarted = true;
    try {
      await _init3D();
    } catch (_) {
      if (mounted) {
        setState(() {
          _is3DReady = false;
        });
      }
    }
  }

  Future<void> _init3D() async {
    final size = widget.size;
    if (size <= 0) return;

    final gl = FlutterGlPlugin();
    final options = ConfigOptions(
      antialias: true,
      alpha: true,
      width: size.toInt(),
      height: size.toInt(),
      dpr: 1.0,
    );
    await gl.initialize(options: options.toMap());
    if (!mounted) return;

    await gl.prepareContext();
    if (!mounted) return;

    _gl = gl;

    final renderOptions = ConfigOptions(
      antialias: true,
      alpha: true,
      width: size.toInt(),
      height: size.toInt(),
      dpr: 1.0,
      gl: gl.gl,
    );
    final renderer = three.WebGLRenderer(renderOptions.toMap());
    renderer.setPixelRatio(1.0);
    renderer.setSize(size, size);
    _renderer = renderer;

    final scene = three.Scene();
    final camera = three.PerspectiveCamera(45, 1, 0.1, 100);
    camera.position.set(0, 0, 3);
    scene.add(three.AmbientLight(0xffffff, 0.6));
    final dir = three.DirectionalLight(0xffffff, 0.8);
    dir.position.set(5, 5, 5);
    scene.add(dir);

    three.Mesh? mesh;
    if (widget.texturePath.isNotEmpty) {
      try {
        final tex = await three.TextureLoader(null).loadAsync(widget.texturePath);
        final mat = three.MeshPhongMaterial({'map': tex});
        mesh = three.Mesh(three.SphereGeometry(1, 16, 16), mat);
      } catch (_) {
        mesh = three.Mesh(
          three.SphereGeometry(1, 16, 16),
          three.MeshPhongMaterial({'color': 0x8888ff}),
        );
      }
    } else {
      mesh = three.Mesh(
        three.SphereGeometry(1, 16, 16),
        three.MeshPhongMaterial({'color': 0x8888ff}),
      );
    }
    scene.add(mesh);

    _scene = scene;
    _camera = camera;
    _mesh = mesh;

    if (!mounted) return;
    setState(() {
      _is3DReady = true;
    });

    try {
      renderer.render(scene, camera);
    } catch (_) {}
  }

  void _onTick() {
    if (!mounted) return;
    if (_is3DReady &&
        _mesh != null &&
        _renderer != null &&
        _scene != null &&
        _camera != null) {
      _mesh!.rotateY(0.015);
      try {
        _renderer!.render(_scene!, _camera!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    final gl = _gl;
    if (gl != null && gl.textureId != null) {
      try {
        gl.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    if (_is3DReady && _gl != null && _gl!.isInitialized) {
      Widget view;
      if (kIsWeb) {
        view = HtmlElementView(viewType: _gl!.textureId!.toString());
      } else {
        view = Texture(textureId: _gl!.textureId!);
      }
      return SizedBox(width: size, height: size, child: view);
    }

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: ClipOval(
          child: widget.texturePath.isNotEmpty
              ? Image.asset(
                  widget.texturePath,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[800]),
                )
              : Container(color: Colors.grey[800]),
        ),
      ),
    );
  }
}