import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:orbite/core/widgets/shimmer_loading.dart';
import 'package:orbite/features/solar_system/domain/entities/config_options.dart';
import 'package:orbite/features/solar_system/domain/entities/planet.dart';
import 'package:orbite/features/solar_system/res/assets/textures.dart';
import 'package:orbite/features/solar_system/utils/planet_util.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

enum SceneState { loading, loaded, error }

class HomeScene extends StatefulWidget {
  const HomeScene({super.key, this.isPlaying = true, this.onPlanetTap});

  final bool isPlaying;
  final void Function(String planetId)? onPlanetTap;

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene> with TickerProviderStateMixin {
  late final GlobalKey<three_jsm.DomLikeListenableState> _domLikeKey;

  three.WebGLRenderer? renderer;
  three.WebGLRenderTarget? renderTarget;
  three_jsm.OrbitControls? _orbit;
  Ticker? _ticker;
  late final AnimationController _focusController;
  three.Vector3 _focusStartCam = three.Vector3();
  three.Vector3 _focusEndCam = three.Vector3();
  three.Vector3 _focusStartTarget = three.Vector3();
  three.Vector3 _focusEndTarget = three.Vector3();
  Duration _lastElapsed = Duration.zero;
  SceneState _sceneState = SceneState.loading;
  String? _errorMessage;

  FlutterGlPlugin? three3dRender;

  double? width;
  double? height;
  late three.Scene _scene;
  late three.Camera _camera;
  Size? screenSize;
  double dpr = 1;
  int? sourceTexture;

  final List<three.AnimationAction> _actions = [];
  Planet? _planet;
  three.Mesh? _sun;
  final three.Raycaster _raycaster = three.Raycaster();
  final three.Vector2 _mouse = three.Vector2();
  Map<String, three.Object3D> _planetObjects = {};

  @override
  void initState() {
    super.initState();
    _domLikeKey = GlobalKey();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(_onFocusTick);
  }

  @override
  void didUpdateWidget(covariant HomeScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _ticker?.start();
        for (final action in _actions) {
          action.paused = false;
        }
      } else {
        _ticker?.stop();
        for (final action in _actions) {
          action.paused = true;
        }
      }
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
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black,
                    child: Listener(
                      onPointerDown: _onPointerDown,
                      child: Builder(
                        builder: (BuildContext context) {
                          if (_sceneState == SceneState.loading) {
                            return Center(
                              child: ShimmerLoading(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Memuat tata surya...',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          if (_sceneState == SceneState.error) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage ?? 'Gagal memuat model',
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _retryLoad,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Coba Lagi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (three3dRender != null &&
                              three3dRender!.isInitialized) {
                            if (kIsWeb) {
                              return HtmlElementView(
                                viewType: three3dRender!.textureId!.toString(),
                              );
                            }
                            return Texture(
                              textureId: three3dRender!.textureId!,
                            );
                          }
                          return const SizedBox.expand();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_sceneState != SceneState.loaded ||
        _planetObjects.isEmpty ||
        width == null ||
        height == null) {
      return;
    }

    final x = (event.localPosition.dx / width!) * 2 - 1;
    final y = -(event.localPosition.dy / height!) * 2 + 1;

    _mouse.set(x, y);
    _raycaster.setFromCamera(_mouse, _camera);

    final meshes = <three.Object3D>[..._planetObjects.values, ?_sun];
    final intersects = _raycaster.intersectObjects(meshes, true);

    if (intersects.isNotEmpty) {
      final tapped = intersects.first;
      var tappedObject = tapped.object;
      while (tappedObject.parent != null && tappedObject.parent != _scene) {
        tappedObject = tappedObject.parent!;
      }
      final planetId = _findPlanetId(tappedObject);
      if (planetId != null) {
        _focusOnPlanet(planetId);
        widget.onPlanetTap?.call(planetId);
      }
    }
  }

  String? _findPlanetId(three.Object3D object) {
    if (_sun != null && (object == _sun || _isDescendant(object, _sun!))) {
      return 'sun';
    }
    for (final entry in _planetObjects.entries) {
      if (entry.value == object || _isDescendant(object, entry.value)) {
        return entry.key;
      }
    }
    return null;
  }

  bool _isDescendant(three.Object3D child, three.Object3D parent) {
    if (child.parent == parent) return true;
    if (child.parent == null || child.parent == _scene) return false;
    return _isDescendant(child.parent!, parent);
  }

  void _focusOnPlanet(String planetId) {
    three.Object3D? obj;
    if (planetId == 'sun') {
      obj = _sun;
    } else {
      obj = _planetObjects[planetId];
    }
    if (obj == null || _camera is! three.PerspectiveCamera) return;

    final target = three.Vector3();
    obj.getWorldPosition(target);

    final startCam = three.Vector3(
      _camera.position.x,
      _camera.position.y,
      _camera.position.z,
    );
    final startTarget = three.Vector3(
      _orbit!.target.x,
      _orbit!.target.y,
      _orbit!.target.z,
    );

    final dir = three.Vector3(
      startCam.x - startTarget.x,
      startCam.y - startTarget.y,
      startCam.z - startTarget.z,
    );
    final len = math.sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z);
    if (len == 0) {
      dir.set(0, 0, 1);
    } else {
      final inv = 1 / len;
      dir.x *= inv;
      dir.y *= inv;
      dir.z *= inv;
    }
    final distance = planetId == 'sun' ? 60.0 : 25.0;
    final endCam = three.Vector3(
      target.x + dir.x * distance,
      target.y + dir.y * distance,
      target.z + dir.z * distance,
    );
    final endTarget = target;

    _focusStartCam = startCam;
    _focusEndCam = endCam;
    _focusStartTarget = startTarget;
    _focusEndTarget = endTarget;

    _focusController.forward(from: 0);
  }

  void _onFocusTick() {
    final t = Curves.easeOutCubic.transform(_focusController.value);
    _camera.position.set(
      _focusStartCam.x + (_focusEndCam.x - _focusStartCam.x) * t,
      _focusStartCam.y + (_focusEndCam.y - _focusStartCam.y) * t,
      _focusStartCam.z + (_focusEndCam.z - _focusStartCam.z) * t,
    );
    if (_orbit != null) {
      _orbit!.target.set(
        _focusStartTarget.x + (_focusEndTarget.x - _focusStartTarget.x) * t,
        _focusStartTarget.y + (_focusEndTarget.y - _focusStartTarget.y) * t,
        _focusStartTarget.z + (_focusEndTarget.z - _focusStartTarget.z) * t,
      );
      _orbit!.update();
    }
  }

  void _initSize(Size size) {
    if (screenSize != null || !size.isFinite || size.isEmpty) {
      return;
    }

    screenSize = size;
    dpr = MediaQuery.of(context).devicePixelRatio;

    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    if (screenSize == null) {
      debugPrint('ERROR: screenSize is null in _initPlatformState');
      setState(() {
        _sceneState = SceneState.error;
        _errorMessage = 'Screen size not available';
      });
      return;
    }

    width = screenSize!.width;
    height = screenSize!.height;

    debugPrint('Platform state init: ${width}x$height, DPR: $dpr');

    try {
      three3dRender = FlutterGlPlugin();

      final options = ConfigOptions(
        antialias: true,
        alpha: true,
        width: width!.toInt(),
        height: height!.toInt(),
        dpr: dpr,
      );

      debugPrint('Initializing FlutterGlPlugin...');
      await three3dRender!.initialize(options: options.toMap());
      debugPrint('FlutterGlPlugin initialized');

      if (kIsWeb) {
        final element = three3dRender!.element;
        if (element != null) {
          (element as dynamic).style
            ..width = '100%'
            ..height = '100%'
            ..display = 'block';
          debugPrint('Web element style configured');
        } else {
          debugPrint('WARNING: three3dRender.element is null on web');
        }
      }

      setState(() {});

      Future.delayed(const Duration(milliseconds: 100), () async {
        debugPrint('Preparing context...');
        await three3dRender!.prepareContext();
        debugPrint('Context prepared');

        await _initScene();
      });
    } catch (e, stackTrace) {
      debugPrint('ERROR in _initPlatformState: $e');
      debugPrint('StackTrace: $stackTrace');
      setState(() {
        _sceneState = SceneState.error;
        _errorMessage = 'Failed to initialize 3D context: $e';
      });
    }
  }

  Future<void> _initScene() async {
    try {
      debugPrint('=== SCENE INIT START ===');
      debugPrint('Screen size: ${screenSize?.width}x${screenSize?.height}');

      if (width == null || height == null) {
        throw Exception(
          'Width or height is null: width=$width, height=$height',
        );
      }

      setState(() {
        _sceneState = SceneState.loading;
        _errorMessage = null;
      });

      debugPrint('Initializing renderer...');
      await _initRenderer();
      debugPrint('Renderer initialized: ${renderer != null}');

      debugPrint('Creating scene...');
      _scene = three.Scene();

      debugPrint('Creating camera...');
      _camera = three.PerspectiveCamera(45, width! / height!, 0.1, 1000);

      debugPrint('Setting up OrbitControls...');
      debugPrint('DomLikeListenable currentState: ${_domLikeKey.currentState}');

      if (_domLikeKey.currentState == null) {
        debugPrint(
          'WARNING: DomLikeListenable currentState is null, waiting...',
        );
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint('After wait: ${_domLikeKey.currentState}');
      }

      final orbit = three_jsm.OrbitControls(_camera, _domLikeKey)
        ..enableDamping = true
        ..dampingFactor = 0.075
        ..rotateSpeed = 0.55
        ..zoomSpeed = 0.6
        ..panSpeed = 0.6
        ..minDistance = 5
        ..maxDistance = 1000;
      _orbit = orbit;

      _camera.position.set(0, 0, 50);
      orbit.update();
      debugPrint('Camera position set to (0, 0, 50)');

      debugPrint('Adding lights...');
      final ambientLight = three.AmbientLight(0xffffff, 1.0);
      _scene.add(ambientLight);

      final pointLight = three.PointLight(0xffffff, 2, 500);
      pointLight.position.set(0, 100, 100);
      _scene.add(pointLight);

      final directionalLight = three.DirectionalLight(0xffffff, 1.0);
      directionalLight.position.set(50, 50, 50);
      _scene.add(directionalLight);

      debugPrint('Creating sun...');
      final sunTextureLoader = three.TextureLoader(null);
      final sunGeometry = three.SphereGeometry(15, 30, 30);
      final sunMaterial = three.MeshBasicMaterial({
        'map': await sunTextureLoader.loadAsync(textureSun),
      });
      final sunMesh = three.Mesh(sunGeometry, sunMaterial);
      _scene.add(sunMesh);
      _sun = sunMesh;

      // Glow around sun
      final glowGeometry = three.SphereGeometry(22, 30, 30);
      final glowMaterial = three.MeshBasicMaterial({
        'color': 0xffaa33,
        'transparent': true,
        'opacity': 0.18,
      });
      final glowMesh = three.Mesh(glowGeometry, glowMaterial);
      glowMesh.position.copy(sunMesh.position);
      _scene.add(glowMesh);

      // Starfield background
      final starCount = 1500;
      final positions = <double>[];
      final rng = math.Random(42);
      for (var i = 0; i < starCount; i++) {
        positions.add((rng.nextDouble() - 0.5) * 800);
        positions.add((rng.nextDouble() - 0.5) * 800);
        positions.add((rng.nextDouble() - 0.5) * 800);
      }
      final starGeometry = three.BufferGeometry();
      starGeometry.setAttribute(
        'position',
        three.Float32BufferAttribute(Float32Array.from(positions), 3, false),
      );
      final starMaterial = three.PointsMaterial({
        'color': 0xffffff,
        'size': 1.2,
      });
      final stars = three.Points(starGeometry, starMaterial);
      _scene.add(stars);

      debugPrint('Initializing planets from textures...');
      final planet = await PlanetUtil.instance.initializePlanet(_scene);
      _planet = planet;

      _planetObjects = {
        'mercury': planet.mecury!.object3d,
        'venus': planet.venus!.object3d,
        'earth': planet.earth!.object3d,
        'mars': planet.mars!.object3d,
        'jupiter': planet.jupiter!.object3d,
        'saturn': planet.saturn!.object3d,
        'uranus': planet.uranus!.object3d,
        'neptune': planet.neptune!.object3d,
        'pluto': planet.pluto!.object3d,
      };

      debugPrint('Centering camera on solar system...');
      final box = three.Box3().setFromObject(_scene);
      final center = three.Vector3();
      box.getCenter(center);
      final size = three.Vector3();
      box.getSize(size);
      debugPrint('Solar system bounding box: center=$center, size=$size');

      final maxDim = [size.x, size.y, size.z].reduce((a, b) => a > b ? a : b);
      final distance = maxDim * 1.5;
      _camera.position.set(
        center.x,
        center.y,
        center.z + (distance == 0 ? 300.0 : distance),
      );
      _camera.lookAt(center);
      _orbit?.target.copy(center);
      _orbit?.update();
      debugPrint('Camera repositioned to view solar system');

      debugPrint('Scene setup complete, setting state to loaded');
      setState(() {
        _sceneState = SceneState.loaded;
      });

      _ticker ??= createTicker(_onTick);
      if (widget.isPlaying) {
        _ticker?.start();
        debugPrint('Ticker started');
      } else {
        for (final action in _actions) {
          action.paused = true;
        }
      }

      debugPrint('=== SCENE INIT COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('=== SCENE INIT FAILED ===');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      setState(() {
        _sceneState = SceneState.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    final renderer = this.renderer;
    if (renderer == null) {
      return;
    }

    final deltaSeconds = delta.clamp(0.0, 0.05);

    _orbit?.update();

    if (_sceneState == SceneState.loaded && _planet != null && _sun != null) {
      PlanetUtil.instance.step(
        planet: _planet!,
        sun: _sun!,
        deltaSeconds: deltaSeconds,
      );
    }

    try {
      renderer.render(_scene, _camera);
    } catch (e) {
      debugPrint('Render error: $e');
    }
  }

  void _retryLoad() {
    _initScene();
  }

  @override
  void dispose() {
    _focusController.dispose();
    _ticker?.dispose();
    _orbit?.dispose();
    super.dispose();
  }

  Future<void> _initRenderer() async {
    if (width == null || height == null || three3dRender == null) {
      throw Exception(
        'Cannot init renderer: width=$width, height=$height, three3dRender=$three3dRender',
      );
    }

    debugPrint('three3dRender.gl type: ${three3dRender!.gl.runtimeType}');
    debugPrint('three3dRender.gl: ${three3dRender!.gl}');
    debugPrint('three3dRender.textureId: ${three3dRender!.textureId}');

    final options = ConfigOptions(
      antialias: true,
      alpha: true,
      width: width!,
      height: height!,
      gl: three3dRender!.gl,
    );

    debugPrint('Creating WebGLRenderer...');
    renderer = three.WebGLRenderer(options.toMap());
    debugPrint('WebGLRenderer created: ${renderer != null}');

    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width!, height!);
    renderer!.shadowMap.enabled = true;
    debugPrint('Renderer configured');

    if (!kIsWeb) {
      final pars = three.WebGLRenderTargetOptions({'format': three.RGBAFormat});
      renderTarget = three.WebGLRenderTarget(
        (width! * dpr).toInt(),
        (height! * dpr).toInt(),
        pars,
      );
      renderTarget!.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget!);
    } else {
      renderTarget = null;
    }
    debugPrint('Renderer init complete');
  }
}
