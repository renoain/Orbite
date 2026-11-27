import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/core/widgets/three_scene_canvas.dart';
import 'package:orbite/features/solar_system/res/assets/textures.dart';
import 'package:three_dart/three_dart.dart' as three;

const double _planetRadius = 2.4;

const Map<String, String> _planetNames = {
  'mercury': 'Merkurius',
  'venus': 'Venus',
  'earth': 'Bumi',
  'mars': 'Mars',
  'jupiter': 'Jupiter',
  'saturn': 'Saturnus',
  'uranus': 'Uranus',
  'neptune': 'Neptunus',
};

const Map<String, String> _planetTextures = {
  'mercury': textureMecury,
  'venus': textureVenus,
  'earth': textureEarth,
  'mars': textureMars,
  'jupiter': textureJupiter,
  'saturn': textureSaturn,
  'uranus': textureUranus,
  'neptune': textureNeptune,
};

const Map<String, List<_LayerSpec>> _planetLayers = {
  'earth': [
    _LayerSpec(
      name: 'Inti Dalam',
      radius: 0.19,
      color: 0xFFF2B134,
      depth: '5150-6371 km',
      temp: '5000-6000 °C',
      composition: 'Besi-nikel padat',
      description: 'Bola logam padat di pusat Bumi.',
    ),
    _LayerSpec(
      name: 'Inti Luar',
      radius: 0.55,
      color: 0xFFFF8A3D,
      depth: '2900-5150 km',
      temp: '4000-5000 °C',
      composition: 'Besi-nikel cair',
      description: 'Logam cair yang mengalir dan menghasilkan medan magnet.',
    ),
    _LayerSpec(
      name: 'Mantel',
      radius: 0.95,
      color: 0xFF8E3B2E,
      depth: '70-2900 km',
      temp: '1000-3700 °C',
      composition: 'Silikat panas',
      description: 'Batuan panas yang mengalir sangat lambat.',
    ),
    _LayerSpec(
      name: 'Kerak',
      radius: 1.0,
      color: 0xFF6B5B4A,
      depth: '0-70 km',
      temp: '15 °C',
      composition: 'Silikat',
      description: 'Lapisan tipis tempat daratan dan lautan berada.',
    ),
  ],
  'mars': [
    _LayerSpec(
      name: 'Inti',
      radius: 0.54,
      color: 0xFFFF8A3D,
      depth: '1500-3390 km',
      temp: '1500-2000 °C',
      composition: 'Besi dan sulfur cair',
      description: 'Inti Mars sebagian cair dan lebih kecil dari Bumi.',
    ),
    _LayerSpec(
      name: 'Mantel',
      radius: 0.95,
      color: 0xFF8E3B2E,
      depth: '50-1500 km',
      temp: '1300 °C',
      composition: 'Silikat',
      description: 'Mantel batuan yang sebagian besar sudah tidak aktif.',
    ),
    _LayerSpec(
      name: 'Kerak',
      radius: 1.0,
      color: 0xFFB35A3A,
      depth: '0-50 km',
      temp: '-60 °C',
      composition: 'Basalt dan regolith',
      description: 'Kerak berdebu dengan kawah dan gunung berapi raksasa.',
    ),
  ],
  'mercury': [
    _LayerSpec(
      name: 'Inti',
      radius: 0.85,
      color: 0xFFFF8A3D,
      description: 'Inti besi sangat besar, sebagian cair.',
    ),
    _LayerSpec(
      name: 'Mantel',
      radius: 0.98,
      color: 0xFF8E3B2E,
      description: 'Mantel silikat yang relatif tipis.',
    ),
    _LayerSpec(
      name: 'Kerak',
      radius: 1.0,
      color: 0xFF7A6A5A,
      description: 'Kerak berbatu dengan banyak kawah.',
    ),
  ],
  'venus': [
    _LayerSpec(
      name: 'Inti',
      radius: 0.55,
      color: 0xFFFF8A3D,
      description: 'Inti besi sebagian cair.',
    ),
    _LayerSpec(
      name: 'Mantel',
      radius: 0.95,
      color: 0xFFB5522A,
      description: 'Mantel batuan panas.',
    ),
    _LayerSpec(
      name: 'Kerak',
      radius: 1.0,
      color: 0xFFC9A26B,
      description: 'Kerak basaltik di bawah atmosfer tebal.',
    ),
  ],
  'jupiter': [
    _LayerSpec(
      name: 'Inti',
      radius: 0.2,
      color: 0xFFB58B5A,
      description: 'Inti batuan dan es yang diperkirakan ada di pusat.',
    ),
    _LayerSpec(
      name: 'Hidrogen Metalik',
      radius: 0.85,
      color: 0xFF4A6FA5,
      description: 'Hidrogen terkompresi hingga bersifat seperti logam.',
    ),
    _LayerSpec(
      name: 'Atmosfer',
      radius: 1.0,
      color: 0xFFD9B38C,
      description: 'Lapisan gas dengan pita awan dan badai.',
    ),
  ],
  'saturn': [
    _LayerSpec(
      name: 'Inti',
      radius: 0.2,
      color: 0xFFB58B5A,
      description: 'Inti batuan dan es.',
    ),
    _LayerSpec(
      name: 'Hidrogen Metalik',
      radius: 0.8,
      color: 0xFF5A7FA5,
      description: 'Lapisan hidrogen metalik di bawah atmosfer.',
    ),
    _LayerSpec(
      name: 'Atmosfer',
      radius: 1.0,
      color: 0xFFE0C48A,
      description: 'Atmosfer gas dengan cincin es dan batuan.',
    ),
  ],
  'uranus': [
    _LayerSpec(
      name: 'Inti',
      radius: 0.3,
      color: 0xFFB58B5A,
      description: 'Inti batuan dan es.',
    ),
    _LayerSpec(
      name: 'Mantel Es',
      radius: 0.9,
      color: 0xFF5FAFB5,
      description: 'Campuran air, amonia, dan metana dalam kondisi panas.',
    ),
    _LayerSpec(
      name: 'Atmosfer',
      radius: 1.0,
      color: 0xFF9FE0E0,
      description: 'Atmosfer hidrogen, helium, dan metana.',
    ),
  ],
  'neptune': [
    _LayerSpec(
      name: 'Inti',
      radius: 0.3,
      color: 0xFFB58B5A,
      description: 'Inti batuan dan es.',
    ),
    _LayerSpec(
      name: 'Mantel Es',
      radius: 0.9,
      color: 0xFF3F6FB5,
      description: 'Lapisan es panas dan padat.',
    ),
    _LayerSpec(
      name: 'Atmosfer',
      radius: 1.0,
      color: 0xFF5A8FE0,
      description: 'Atmosfer biru dengan angin tercepat di tata surya.',
    ),
  ],
};

class InteriorPage extends StatefulWidget {
  const InteriorPage({super.key, required this.planetName});

  final String planetName;

  @override
  State<InteriorPage> createState() => _InteriorPageState();
}

class _InteriorPageState extends State<InteriorPage> {
  final ThreeSceneController _controller = ThreeSceneController();

  three.Mesh? _selectionRing;
  int _selectedIndex = 0;

  String get _planetId {
    final lower = widget.planetName.toLowerCase();
    if (lower.contains('merk')) return 'mercury';
    if (lower.contains('venus')) return 'venus';
    if (lower.contains('bumi') || lower.contains('earth')) return 'earth';
    if (lower.contains('mars')) return 'mars';
    if (lower.contains('jup')) return 'jupiter';
    if (lower.contains('sat')) return 'saturn';
    if (lower.contains('uran')) return 'uranus';
    if (lower.contains('nept')) return 'neptune';
    return 'earth';
  }

  List<_LayerSpec> get _layers =>
      _planetLayers[_planetId] ?? _planetLayers['earth']!;

  String get _displayName => _planetNames[_planetId] ?? 'Bumi';

  _LayerSpec get _selectedLayer {
    final index = _selectedIndex < _layers.length
        ? _selectedIndex
        : _layers.length - 1;
    return _layers[index];
  }

  Future<void> _setupScene(ThreeSceneContext context) async {
    final scene = context.scene;

    scene.add(three.AmbientLight(0xffffff, 0.55));
    final keyLight = three.DirectionalLight(0xffffff, 0.9);
    keyLight.position.set(5, 6, -6);
    scene.add(keyLight);
    final fillLight = three.PointLight(0xffffff, 0.5, 80);
    fillLight.position.set(4, 5, 6);
    scene.add(fillLight);

    final group = three.Group();
    scene.add(group);

    three.Texture? surfaceTexture;
    final texturePath = _planetTextures[_planetId];
    if (texturePath != null) {
      try {
        surfaceTexture = await three.TextureLoader(null).loadAsync(texturePath);
      } catch (_) {}
    }

    final layers = _layers;
    for (var i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final radius = layer.radius * _planetRadius;
      final isOuter = i == layers.length - 1;

      final shellMaterial = isOuter && surfaceTexture != null
          ? three.MeshPhongMaterial({'map': surfaceTexture})
          : three.MeshPhongMaterial({'color': layer.color, 'shininess': 12});
      final shell = three.Mesh(
        three.SphereGeometry(radius, 48, 32, 0, math.pi, 0, math.pi),
        shellMaterial,
      );
      group.add(shell);

      final discZ = -0.004 * (layers.length - 1 - i);
      final disc = three.Mesh(
        three.CircleGeometry(radius: radius, segments: 64),
        three.MeshBasicMaterial({
          'color': layer.color,
          'side': three.DoubleSide,
        }),
      );
      disc.position.set(0, 0, discZ);
      group.add(disc);

      final outline = three.Mesh(
        three.RingGeometry(radius * 0.985, radius, 64),
        three.MeshBasicMaterial({
          'color': 0xffffff,
          'transparent': true,
          'opacity': 0.16,
          'side': three.DoubleSide,
        }),
      );
      outline.position.set(0, 0, discZ - 0.001);
      group.add(outline);
    }

    final selectionRing = three.Mesh(
      three.RingGeometry(0.965, 1.0, 64),
      three.MeshBasicMaterial({'color': 0xF5A623, 'side': three.DoubleSide}),
    );
    selectionRing.position.set(0, 0, -0.02);
    group.add(selectionRing);

    final positions = <double>[];
    final random = math.Random(23);
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

    _selectionRing = selectionRing;
    _applySelection();
  }

  void _applySelection() {
    final ring = _selectionRing;
    if (ring == null) return;
    final radius = _selectedLayer.radius * _planetRadius;
    ring.scale.set(radius, radius, 1);
  }

  void _selectLayer(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _applySelection();
    _controller.renderOnce();
  }

  void _resetCamera() {
    _controller.setCamera(4.2, 3.0, -7.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layers = _layers;
    final selected = _selectedLayer;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Interior $_displayName 3D'),
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
          final panelMax = (constraints.maxHeight * 0.46)
              .clamp(260.0, 400.0)
              .toDouble();
          return Column(
            children: [
              Expanded(
                child: ThreeSceneCanvas(
                  controller: _controller,
                  setup: _setupScene,
                  initialCamera: const [4.2, 3.0, -7.0],
                  minDistance: 4,
                  maxDistance: 20,
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
                        Text(
                          'Struktur dalam $_displayName',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ketebalan lapisan disederhanakan untuk visualisasi.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < layers.length; i++)
                              _LayerChip(
                                layer: layers[i],
                                selected: i == _selectedIndex,
                                onSelected: () => _selectLayer(i),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          selected.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (selected.depth != null)
                          _InfoRow(label: 'Kedalaman', value: selected.depth!),
                        if (selected.temp != null)
                          _InfoRow(label: 'Suhu', value: selected.temp!),
                        if (selected.composition != null)
                          _InfoRow(
                            label: 'Komposisi',
                            value: selected.composition!,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          selected.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drag untuk memutar, scroll untuk zoom.',
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

class _LayerChip extends StatelessWidget {
  const _LayerChip({
    required this.layer,
    required this.selected,
    required this.onSelected,
  });

  final _LayerSpec layer;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Color(layer.color),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white70, width: 1),
        ),
      ),
      label: Text(layer.name),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.secondary,
      backgroundColor: const Color(0xFF1A1B1E),
      side: const BorderSide(color: Color(0xFF2A2C30)),
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white70,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerSpec {
  const _LayerSpec({
    required this.name,
    required this.radius,
    required this.color,
    required this.description,
    this.depth,
    this.temp,
    this.composition,
  });

  final String name;
  final double radius;
  final int color;
  final String description;
  final String? depth;
  final String? temp;
  final String? composition;
}
