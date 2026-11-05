import 'package:flutter/material.dart';
import 'package:orbite/core/constants/nasa_images.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

class InteriorPage extends StatefulWidget {
  final String planetName;

  const InteriorPage({super.key, required this.planetName});

  @override
  State<InteriorPage> createState() => _InteriorPageState();
}

class _InteriorPageState extends State<InteriorPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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

  List<_LayerInfo> get _layers {
    if (_planetId == 'mars') {
      return const [
        _LayerInfo(
          'Kerak',
          '0-50 km',
          '-60 °C',
          'Basalt dan regolith',
          'Lapisan tipis berbatu di permukaan Mars.',
          0.15,
          0.35,
        ),
        _LayerInfo(
          'Mantel',
          '50-1500 km',
          '1300 °C',
          'Silikat',
          'Mantel padat dengan konveksi lambat.',
          0.35,
          0.55,
        ),
        _LayerInfo(
          'Inti Luar',
          '1500-1800 km',
          '1500 °C',
          'Besi cair',
          'Inti luar cair yang menghasilkan medan magnet lemah.',
          0.55,
          0.65,
        ),
        _LayerInfo(
          'Inti Dalam',
          '1800-3390 km',
          '2000 °C',
          'Besi padat',
          'Inti dalam padat di pusat Mars.',
          0.65,
          0.50,
        ),
      ];
    }
    return const [
      _LayerInfo(
        'Kerak',
        '0-70 km',
        '15 °C',
        'Silikat',
        'Lapisan tipis tempat kita hidup.',
        0.12,
        0.30,
      ),
      _LayerInfo(
        'Mantel',
        '70-2900 km',
        '1000-3700 °C',
        'Silikat panas',
        'Mantel tebal dengan arus konveksi.',
        0.32,
        0.50,
      ),
      _LayerInfo(
        'Inti Luar',
        '2900-5150 km',
        '4000-5000 °C',
        'Besi-nikel cair',
        'Inti luar cair menghasilkan medan magnet.',
        0.55,
        0.62,
      ),
      _LayerInfo(
        'Inti Dalam',
        '5150-6371 km',
        '5000-6000 °C',
        'Besi-nikel padat',
        'Inti dalam padat di pusat Bumi.',
        0.72,
        0.50,
      ),
    ];
  }

  void _showLayer(_LayerInfo layer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              layer.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _row('Kedalaman', layer.depth),
            _row('Suhu', layer.temp),
            _row('Komposisi', layer.composition),
            const SizedBox(height: 8),
            Text(
              layer.description,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url =
        NasaImages.crossSection[_planetId] ??
        NasaImages.planet[_planetId] ??
        NasaImages.planet['earth']!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Interior ${widget.planetName}')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: NasaImage(
                  url: url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              ..._layers.map((layer) {
                return Positioned(
                  left: constraints.maxWidth * layer.x - 16,
                  top: constraints.maxHeight * layer.y - 16,
                  child: Semantics(
                    button: true,
                    label: 'Lapisan ${layer.name}',
                    child: GestureDetector(
                      onTap: () => _showLayer(layer),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 1.0 + (_pulseController.value * 0.15);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary
                                .withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 6),
                            ],
                          ),
                          child: const Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _LayerInfo {
  final String name;
  final String depth;
  final String temp;
  final String composition;
  final String description;
  final double x;
  final double y;

  const _LayerInfo(
    this.name,
    this.depth,
    this.temp,
    this.composition,
    this.description,
    this.x,
    this.y,
  );
}
