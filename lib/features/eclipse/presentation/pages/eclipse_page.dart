import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/core/widgets/three_scene_canvas.dart';
import 'package:orbite/features/solar_system/res/assets/textures.dart';
import 'package:three_dart/three_dart.dart' as three;

const double _moonOrbitRadius = 9.0;
const double _degreesPerSecond = 15.0;

class EclipsePage extends StatefulWidget {
  const EclipsePage({super.key});

  @override
  State<EclipsePage> createState() => _EclipsePageState();
}

class _EclipsePageState extends State<EclipsePage> {
  final ThreeSceneController _controller = ThreeSceneController();
  final ValueNotifier<double> _angleNotifier = ValueNotifier<double>(0);
  final ValueNotifier<_EclipseStatus> _statusNotifier =
      ValueNotifier<_EclipseStatus>(_statusFor(0));

  three.Group? _shadowGroup;
  three.Mesh? _moon;
  three.Mesh? _moonUmbra;
  three.Mesh? _moonPenumbra;
  three.MeshPhongMaterial? _moonMaterial;

  double _angleDegrees = 0;
  double _lastNotifiedAngle = 0;
  double _speed = 1.0;
  bool _playing = true;
  bool _showShadows = true;
  bool _showExplanation = false;
  _EclipseStatus _lastStatus = _statusFor(0);

  @override
  void dispose() {
    _angleNotifier.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  Future<void> _setupScene(ThreeSceneContext context) async {
    final scene = context.scene;

    scene.add(three.AmbientLight(0xffffff, 0.2));
    final sunLight = three.PointLight(0xffffff, 2.6, 600);
    sunLight.position.set(-40, 0, 0);
    scene.add(sunLight);

    final sunTexture = await three.TextureLoader(null).loadAsync(textureSun);
    final sun = three.Mesh(
      three.SphereGeometry(6, 32, 32),
      three.MeshBasicMaterial({'map': sunTexture}),
    );
    sun.position.set(-40, 0, 0);
    scene.add(sun);

    final glow = three.Mesh(
      three.SphereGeometry(9, 32, 32),
      three.MeshBasicMaterial({
        'color': 0xffaa33,
        'transparent': true,
        'opacity': 0.15,
      }),
    );
    glow.position.set(-40, 0, 0);
    scene.add(glow);

    final earthTexture = await three.TextureLoader(null)
        .loadAsync(textureEarth);
    final earth = three.Mesh(
      three.SphereGeometry(2.2, 48, 32),
      three.MeshPhongMaterial({'map': earthTexture}),
    );
    scene.add(earth);

    final orbitRing = three.Mesh(
      three.RingGeometry(_moonOrbitRadius - 0.06, _moonOrbitRadius + 0.06, 96),
      three.MeshBasicMaterial({
        'color': 0xffffff,
        'transparent': true,
        'opacity': 0.14,
        'side': three.DoubleSide,
      }),
    );
    orbitRing.rotation.x = -math.pi / 2;
    scene.add(orbitRing);

    final moonTexture = await three.TextureLoader(null).loadAsync(textureMoon);
    final moonMaterial = three.MeshPhongMaterial({'map': moonTexture});
    final moon = three.Mesh(three.SphereGeometry(0.9, 32, 24), moonMaterial);
    scene.add(moon);

    final shadowGroup = three.Group();
    scene.add(shadowGroup);

    final umbraMaterial = three.MeshBasicMaterial({
      'color': 0x2a3a5a,
      'transparent': true,
      'opacity': 0.26,
      'side': three.DoubleSide,
      'depthWrite': false,
    });
    final penumbraMaterial = three.MeshBasicMaterial({
      'color': 0x2a3a5a,
      'transparent': true,
      'opacity': 0.08,
      'side': three.DoubleSide,
      'depthWrite': false,
    });

    final earthUmbra = three.Mesh(
      three.CylinderGeometry(0, 2.2, 40, 32, 1, true),
      umbraMaterial,
    );
    earthUmbra.rotation.z = -math.pi / 2;
    earthUmbra.position.set(20, 0, 0);
    shadowGroup.add(earthUmbra);

    final earthPenumbra = three.Mesh(
      three.CylinderGeometry(5.0, 2.2, 40, 32, 1, true),
      penumbraMaterial,
    );
    earthPenumbra.rotation.z = -math.pi / 2;
    earthPenumbra.position.set(20, 0, 0);
    shadowGroup.add(earthPenumbra);

    final moonUmbra = three.Mesh(
      three.CylinderGeometry(0, 0.9, _moonOrbitRadius, 24, 1, true),
      umbraMaterial,
    );
    moonUmbra.rotation.z = -math.pi / 2;
    shadowGroup.add(moonUmbra);

    final moonPenumbra = three.Mesh(
      three.CylinderGeometry(1.8, 0.9, _moonOrbitRadius, 24, 1, true),
      penumbraMaterial,
    );
    moonPenumbra.rotation.z = -math.pi / 2;
    shadowGroup.add(moonPenumbra);

    final positions = <double>[];
    final random = math.Random(17);
    for (var i = 0; i < 1200; i++) {
      positions.add((random.nextDouble() - 0.5) * 400);
      positions.add((random.nextDouble() - 0.5) * 400);
      positions.add((random.nextDouble() - 0.5) * 400);
    }
    final starGeometry = three.BufferGeometry();
    starGeometry.setAttribute(
      'position',
      three.Float32BufferAttribute(Float32Array.from(positions), 3, false),
    );
    scene.add(
      three.Points(
        starGeometry,
        three.PointsMaterial({'color': 0xffffff, 'size': 1.0}),
      ),
    );

    _shadowGroup = shadowGroup;
    _moon = moon;
    _moonUmbra = moonUmbra;
    _moonPenumbra = moonPenumbra;
    _moonMaterial = moonMaterial;
    _updateScene();
  }

  void _onTick(ThreeSceneContext context, double dt) {
    if (!mounted || !_playing) return;

    _angleDegrees = (_angleDegrees + dt * _degreesPerSecond * _speed) % 360;
    _updateScene();

    final wrapped = _angleDegrees < _lastNotifiedAngle;
    if (wrapped || (_angleDegrees - _lastNotifiedAngle).abs() > 0.2) {
      _lastNotifiedAngle = _angleDegrees;
      _angleNotifier.value = _angleDegrees;
    }

    _refreshStatus();
  }

  void _updateScene() {
    final angle = _angleDegrees * math.pi / 180;
    final moonX = -_moonOrbitRadius * math.cos(angle);
    final moonZ = _moonOrbitRadius * math.sin(angle);
    _moon?.position.set(moonX, 0, moonZ);
    _moonUmbra?.position.set(moonX + _moonOrbitRadius / 2, 0, moonZ);
    _moonPenumbra?.position.set(moonX + _moonOrbitRadius / 2, 0, moonZ);
    final shadowGroup = _shadowGroup;
    if (shadowGroup != null) {
      shadowGroup.visible = _showShadows;
    }
  }

  void _refreshStatus() {
    final status = _statusFor(_angleDegrees);
    if (status.kind == _lastStatus.kind && status.phase == _lastStatus.phase) {
      return;
    }
    _lastStatus = status;
    _statusNotifier.value = status;
    if (status.kind == _EclipseKind.lunar) {
      _moonMaterial?.color.setHex(0xff7a5a);
    } else {
      _moonMaterial?.color.setHex(0xffffff);
    }
  }

  void _setAngle(double value) {
    _angleDegrees = value.clamp(0.0, 359.99);
    _lastNotifiedAngle = _angleDegrees;
    _angleNotifier.value = _angleDegrees;
    _updateScene();
    _refreshStatus();
    _controller.renderOnce();
  }

  void _togglePlay() {
    setState(() {
      _playing = !_playing;
    });
  }

  void _resetCamera() {
    _controller.setCamera(0, 16, 42);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Gerhana 3D'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Atur ulang kamera',
            onPressed: _resetCamera,
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final panelMax = (constraints.maxHeight * 0.48)
              .clamp(270.0, 410.0)
              .toDouble();
          return Column(
            children: [
              Expanded(
                child: ThreeSceneCanvas(
                  controller: _controller,
                  setup: _setupScene,
                  onTick: _onTick,
                  initialCamera: const [0, 16, 42],
                  minDistance: 10,
                  maxDistance: 120,
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  constraints: BoxConstraints(maxHeight: panelMax),
                  color: Colors.black87,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<_EclipseStatus>(
                          valueListenable: _statusNotifier,
                          builder: (context, status, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: status.isEclipse
                                        ? AppColors.secondary
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  'Fase Bulan: ${status.phase}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  status.detail,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: _angleNotifier,
                          builder: (context, angle, _) {
                            return Slider(
                              value: angle,
                              min: 0,
                              max: 360,
                              label: '${angle.round()}°',
                              activeColor: AppColors.secondary,
                              onChanged: _setAngle,
                            );
                          },
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AnglePreset(
                              label: 'Bulan Baru',
                              onSelected: () => _setAngle(0),
                            ),
                            _AnglePreset(
                              label: 'Kuartal',
                              onSelected: () => _setAngle(90),
                            ),
                            _AnglePreset(
                              label: 'Purnama',
                              onSelected: () => _setAngle(180),
                            ),
                            _AnglePreset(
                              label: 'Kuartal Akhir',
                              onSelected: () => _setAngle(270),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              tooltip: _playing ? 'Jeda' : 'Mainkan',
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
                                max: 4,
                                divisions: 7,
                                label: '${_speed.toStringAsFixed(1)}x',
                                activeColor: AppColors.secondary,
                                onChanged: (value) {
                                  setState(() {
                                    _speed = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${_speed.toStringAsFixed(1)}x',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tampilkan bayangan',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            Switch(
                              value: _showShadows,
                              activeThumbColor: AppColors.secondary,
                              activeTrackColor: AppColors.secondary.withValues(
                                alpha: 0.35,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _showShadows = value;
                                });
                                _updateScene();
                              },
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              label: const Text('Tampak atas'),
                              onPressed: () {
                                _controller.setCamera(0.1, 48, 0.1);
                              },
                              backgroundColor: const Color(0xFF1A1B1E),
                              side: const BorderSide(color: Color(0xFF2A2C30)),
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            ActionChip(
                              label: const Text('Tampak samping'),
                              onPressed: () {
                                _controller.setCamera(0, 12, 48);
                              },
                              backgroundColor: const Color(0xFF1A1B1E),
                              side: const BorderSide(color: Color(0xFF2A2C30)),
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showExplanation = !_showExplanation;
                              });
                            },
                            child: Text(
                              _showExplanation
                                  ? 'Sembunyikan penjelasan'
                                  : 'Tampilkan penjelasan',
                            ),
                          ),
                        ),
                        if (_showExplanation)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'Model ideal: orbit Bulan dianggap sejajar '
                              'bidang ekliptika. Di alam nyata, gerhana hanya '
                              'terjadi saat Bulan berada dekat titik simpul '
                              'orbitnya. Gerhana Matahari terjadi saat Bulan '
                              'di antara Matahari dan Bumi; gerhana Bulan '
                              'terjadi saat Bumi di antara Matahari dan Bulan.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ),
                        Text(
                          'Drag untuk memutar kamera, scroll untuk zoom.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnglePreset extends StatelessWidget {
  const _AnglePreset({required this.label, required this.onSelected});

  final String label;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onSelected,
      backgroundColor: const Color(0xFF1A1B1E),
      side: const BorderSide(color: Color(0xFF2A2C30)),
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }
}

enum _EclipseKind { none, solar, lunar }

class _EclipseStatus {
  const _EclipseStatus(this.kind, this.phase);

  final _EclipseKind kind;
  final String phase;

  bool get isEclipse => kind != _EclipseKind.none;

  String get title {
    switch (kind) {
      case _EclipseKind.solar:
        return 'Gerhana Matahari';
      case _EclipseKind.lunar:
        return 'Gerhana Bulan';
      case _EclipseKind.none:
        return 'Tidak ada gerhana';
    }
  }

  String get detail {
    switch (kind) {
      case _EclipseKind.solar:
        return 'Bulan berada di antara Matahari dan Bumi. Bayangan Bulan '
            'jatuh ke Bumi.';
      case _EclipseKind.lunar:
        return 'Bumi berada di antara Matahari dan Bulan. Bulan masuk ke '
            'bayangan Bumi.';
      case _EclipseKind.none:
        return 'Bulan belum cukup sejajar dengan garis Matahari–Bumi.';
    }
  }
}

_EclipseStatus _statusFor(double degrees) {
  final angle = (degrees % 360) * math.pi / 180;
  final alignment = math.sin(angle).abs();
  final phase = _phaseName(degrees);

  if (alignment < 0.18) {
    if (math.cos(angle) > 0) {
      return _EclipseStatus(_EclipseKind.solar, phase);
    }
    return _EclipseStatus(_EclipseKind.lunar, phase);
  }
  return _EclipseStatus(_EclipseKind.none, phase);
}

String _phaseName(double degrees) {
  final normalized = degrees % 360;
  if (normalized < 22.5 || normalized >= 337.5) return 'Bulan Baru';
  if (normalized < 67.5) return 'Bulan Sabit Awal';
  if (normalized < 112.5) return 'Kuartal Pertama';
  if (normalized < 157.5) return 'Bulan Cembung Awal';
  if (normalized < 202.5) return 'Bulan Penuh';
  if (normalized < 247.5) return 'Bulan Cembung Akhir';
  if (normalized < 292.5) return 'Kuartal Terakhir';
  return 'Bulan Sabit Akhir';
}
