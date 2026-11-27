import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/core/widgets/three_scene_canvas.dart';
import 'package:orbite/features/solar_system/res/assets/textures.dart';
import 'package:three_dart/three_dart.dart' as three;

const double _axialTilt = 23.44 * math.pi / 180;
const double _orbitRadius = 40.0;
const double _earthRadius = 2.2;
const double _daysPerSecond = 24.0;
const double _yearDays = 365.25;
const double _juneSolsticeDay = 172.0;

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const List<int> _monthLengths = [
  31,
  28,
  31,
  30,
  31,
  30,
  31,
  31,
  30,
  31,
  30,
  31,
];

class SeasonsPage extends StatefulWidget {
  const SeasonsPage({super.key});

  @override
  State<SeasonsPage> createState() => _SeasonsPageState();
}

class _SeasonsPageState extends State<SeasonsPage> {
  final ThreeSceneController _controller = ThreeSceneController();
  final ValueNotifier<double> _dayNotifier = ValueNotifier<double>(172);
  final ValueNotifier<_SeasonInfo> _seasonNotifier = ValueNotifier<_SeasonInfo>(
    _seasonInfoFor(172),
  );

  three.Group? _earthTilt;
  three.Mesh? _earth;
  three.Mesh? _subsolarMarker;

  double _simDay = 172;
  double _lastNotifiedDay = 172;
  double _speed = 1.0;
  bool _playing = true;
  bool _showExplanation = false;

  @override
  void dispose() {
    _dayNotifier.dispose();
    _seasonNotifier.dispose();
    super.dispose();
  }

  Future<void> _setupScene(ThreeSceneContext context) async {
    final scene = context.scene;

    scene.add(three.AmbientLight(0xffffff, 0.18));
    final sunLight = three.PointLight(0xffffff, 2.4, 600);
    sunLight.position.set(0, 0, 0);
    scene.add(sunLight);

    final sunTexture = await three.TextureLoader(null).loadAsync(textureSun);
    final sun = three.Mesh(
      three.SphereGeometry(6, 32, 32),
      three.MeshBasicMaterial({'map': sunTexture}),
    );
    scene.add(sun);

    final glow = three.Mesh(
      three.SphereGeometry(9, 32, 32),
      three.MeshBasicMaterial({
        'color': 0xffaa33,
        'transparent': true,
        'opacity': 0.15,
      }),
    );
    scene.add(glow);

    final orbitRing = three.Mesh(
      three.RingGeometry(_orbitRadius - 0.08, _orbitRadius + 0.08, 128),
      three.MeshBasicMaterial({
        'color': 0xffffff,
        'transparent': true,
        'opacity': 0.14,
        'side': three.DoubleSide,
      }),
    );
    orbitRing.rotation.x = -math.pi / 2;
    scene.add(orbitRing);

    final earthTilt = three.Group();
    earthTilt.rotation.z = -_axialTilt;
    scene.add(earthTilt);

    final earthTexture = await three.TextureLoader(null)
        .loadAsync(textureEarth);
    final earth = three.Mesh(
      three.SphereGeometry(_earthRadius, 48, 32),
      three.MeshPhongMaterial({'map': earthTexture}),
    );
    earthTilt.add(earth);

    final axis = three.Mesh(
      three.CylinderGeometry(0.025, 0.025, 6.4, 8),
      three.MeshBasicMaterial({
        'color': 0xF5A623,
        'transparent': true,
        'opacity': 0.55,
      }),
    );
    earthTilt.add(axis);

    final subsolarMarker = three.Mesh(
      three.SphereGeometry(0.13, 12, 12),
      three.MeshBasicMaterial({'color': 0xFFF2B0}),
    );
    earthTilt.add(subsolarMarker);

    final positions = <double>[];
    final random = math.Random(11);
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

    _earthTilt = earthTilt;
    _earth = earth;
    _subsolarMarker = subsolarMarker;
    _updateScene(0);
  }

  void _onTick(ThreeSceneContext context, double dt) {
    if (!mounted || !_playing) return;

    _simDay = (_simDay + dt * _daysPerSecond * _speed) % _yearDays;
    _updateScene(dt);

    final wrapped = _simDay < _lastNotifiedDay;
    if (wrapped || (_simDay - _lastNotifiedDay).abs() > 0.2) {
      _lastNotifiedDay = _simDay;
      _dayNotifier.value = _simDay;
      _seasonNotifier.value = _seasonInfoFor(_simDay);
    }
  }

  void _updateScene(double dt) {
    final earthTilt = _earthTilt;
    final earth = _earth;
    final marker = _subsolarMarker;
    if (earthTilt == null || earth == null || marker == null) return;

    final theta =
        math.pi + 2 * math.pi * (_simDay - _juneSolsticeDay) / _yearDays;
    final x = _orbitRadius * math.cos(theta);
    final z = _orbitRadius * math.sin(theta);
    earthTilt.position.set(x, 0, z);

    final sunDirX = -x / _orbitRadius;
    final sunDirZ = -z / _orbitRadius;
    final cosTilt = math.cos(_axialTilt);
    final sinTilt = math.sin(_axialTilt);
    final localX = sunDirX * cosTilt;
    final localY = sunDirX * sinTilt;
    final localZ = sunDirZ;
    final markerRadius = _earthRadius + 0.06;
    marker.position.set(
      localX * markerRadius,
      localY * markerRadius,
      localZ * markerRadius,
    );

    if (dt > 0) {
      earth.rotateY(0.18 * dt);
    }
  }

  void _setDay(double value) {
    _simDay = value.clamp(0.0, _yearDays - 0.01);
    _lastNotifiedDay = _simDay;
    _dayNotifier.value = _simDay;
    _seasonNotifier.value = _seasonInfoFor(_simDay);
    _updateScene(0);
    _controller.renderOnce();
  }

  void _togglePlay() {
    setState(() {
      _playing = !_playing;
    });
  }

  void _resetCamera() {
    _controller.setCamera(0, 35, 75);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Musim & Kemiringan Bumi'),
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
          final panelMax = (constraints.maxHeight * 0.45)
              .clamp(250.0, 390.0)
              .toDouble();
          return Column(
            children: [
              Expanded(
                child: ThreeSceneCanvas(
                  controller: _controller,
                  setup: _setupScene,
                  onTick: _onTick,
                  initialCamera: const [0, 35, 75],
                  minDistance: 20,
                  maxDistance: 200,
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
                        _SeasonHeader(
                          dayNotifier: _dayNotifier,
                          seasonNotifier: _seasonNotifier,
                        ),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<double>(
                          valueListenable: _dayNotifier,
                          builder: (context, day, _) {
                            return Slider(
                              value: day,
                              min: 0,
                              max: _yearDays - 0.01,
                              label: _formatDay(day),
                              activeColor: AppColors.secondary,
                              onChanged: _setDay,
                            );
                          },
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DayPreset(
                              label: '21 Mar',
                              onSelected: () => _setDay(80),
                            ),
                            _DayPreset(
                              label: '21 Jun',
                              onSelected: () => _setDay(172),
                            ),
                            _DayPreset(
                              label: '23 Sep',
                              onSelected: () => _setDay(266),
                            ),
                            _DayPreset(
                              label: '21 Des',
                              onSelected: () => _setDay(355),
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
                              'Sumbu Bumi miring 23,4° dan tetap mengarah ke '
                              'arah yang sama sepanjang orbit. Bagian yang '
                              'lebih condong ke Matahari menerima cahaya lebih '
                              'langsung dan mengalami musim panas. Titik kuning '
                              'menandai lokasi Matahari tepat di atas permukaan.',
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

class _SeasonHeader extends StatelessWidget {
  const _SeasonHeader({
    required this.dayNotifier,
    required this.seasonNotifier,
  });

  final ValueNotifier<double> dayNotifier;
  final ValueNotifier<_SeasonInfo> seasonNotifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<double>(
      valueListenable: dayNotifier,
      builder: (context, day, _) {
        return ValueListenableBuilder<_SeasonInfo>(
          valueListenable: seasonNotifier,
          builder: (context, season, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            season.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Belahan utara',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDay(day),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  season.note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                Text(
                  'Belahan selatan: ${season.opposite}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DayPreset extends StatelessWidget {
  const _DayPreset({required this.label, required this.onSelected});

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

class _SeasonInfo {
  const _SeasonInfo({
    required this.name,
    required this.opposite,
    required this.note,
  });

  final String name;
  final String opposite;
  final String note;
}

_SeasonInfo _seasonInfoFor(double day) {
  final normalized = day % _yearDays;
  final declination =
      23.44 * math.sin(2 * math.pi * (normalized - 80) / _yearDays);

  final String name;
  final String opposite;
  if (normalized >= 79 && normalized < 172) {
    name = 'Musim Semi';
    opposite = 'Musim Gugur';
  } else if (normalized >= 172 && normalized < 266) {
    name = 'Musim Panas';
    opposite = 'Musim Dingin';
  } else if (normalized >= 266 && normalized < 355) {
    name = 'Musim Gugur';
    opposite = 'Musim Semi';
  } else {
    name = 'Musim Dingin';
    opposite = 'Musim Panas';
  }

  final note = declination.abs() < 0.5
      ? 'Matahari tepat di atas ekuator.'
      : 'Matahari tepat di atas ${declination.abs().toStringAsFixed(1)}° '
            '${declination > 0 ? 'LU' : 'LS'}.';

  return _SeasonInfo(name: name, opposite: opposite, note: note);
}

String _formatDay(double day) {
  var remaining = day.floor().clamp(0, 364);
  var month = 0;
  while (month < _monthLengths.length && remaining >= _monthLengths[month]) {
    remaining -= _monthLengths[month];
    month++;
  }
  if (month >= _monthNames.length) {
    month = _monthNames.length - 1;
    remaining = 30;
  }
  return '${remaining + 1} ${_monthNames[month]}';
}
