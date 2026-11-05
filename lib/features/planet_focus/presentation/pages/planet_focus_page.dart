import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

class PlanetFocusPage extends StatefulWidget {
  final String planetName;

  const PlanetFocusPage({super.key, required this.planetName});

  @override
  State<PlanetFocusPage> createState() => _PlanetFocusPageState();
}

class _PlanetFocusPageState extends State<PlanetFocusPage> {
  static const _planetIds = [
    'mercury',
    'venus',
    'earth',
    'mars',
    'jupiter',
    'saturn',
    'uranus',
    'neptune',
  ];

  static const _planetNames = {
    'mercury': 'Merkurius',
    'venus': 'Venus',
    'earth': 'Bumi',
    'mars': 'Mars',
    'jupiter': 'Jupiter',
    'saturn': 'Saturnus',
    'uranus': 'Uranus',
    'neptune': 'Neptunus',
  };

  late int _planetIndex;
  late final PageController _pageController;
  int _currentLayer = 0;
  bool _isSwitching = false;
  bool _isScrolling = false;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _layers = [];

  @override
  void initState() {
    super.initState();
    _planetIndex = _planetIds.indexOf(_idFromName(widget.planetName));
    if (_planetIndex < 0) _planetIndex = 2;
    _pageController = PageController();
    _pageController.addListener(_onScroll);
    _loadLayers();
  }

  String _idFromName(String name) {
    final lower = name.toLowerCase();
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

  Future<void> _loadLayers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jsonString = await rootBundle.loadString('assets/mock/layers.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final planetData =
          data[_planetIds[_planetIndex]] as Map<String, dynamic>?;
      final layers = (planetData?['layers'] as List<dynamic>?) ?? [];
      setState(() {
        _layers = layers.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (!_isScrolling) {
      setState(() => _isScrolling = true);
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isScrolling = false);
    });
  }

  String get _planetId => _planetIds[_planetIndex];
  String get _planetName => _planetNames[_planetId] ?? _planetId;

  int get _layerCount => _layers.isEmpty ? 1 : _layers.length;

  void _goToLayer(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _switchPlanet(int delta) async {
    final newIndex = _planetIndex + delta;
    if (newIndex < 0 || newIndex >= _planetIds.length) return;
    setState(() => _isSwitching = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _planetIndex = newIndex;
      _isSwitching = false;
      _currentLayer = 0;
    });
    await _loadLayers();
    if (_currentLayer >= _layerCount) {
      _goToLayer(_layerCount - 1);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: Text(_planetName)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadLayers,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_planetName),
        actions: [
          IconButton(
            tooltip: 'Planet sebelumnya',
            onPressed: _planetIndex > 0 ? () => _switchPlanet(-1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Planet berikutnya',
            onPressed: _planetIndex < _planetIds.length - 1
                ? () => _switchPlanet(1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _layerCount,
            onPageChanged: (i) => setState(() => _currentLayer = i),
            itemBuilder: (context, index) {
              final layer = index < _layers.length
                  ? _layers[index]
                  : <String, dynamic>{};
              final title = layer['name'] as String? ?? 'Layer';
              final desc = layer['description'] as String? ?? '';
              final url = layer['image_url'] as String? ?? '';
              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < -200) {
                    _switchPlanet(1);
                  } else if (details.primaryVelocity! > 200) {
                    _switchPlanet(-1);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (url.isNotEmpty)
                      NasaImage(
                        url: url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else
                      Container(color: Colors.grey[800]),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 80,
                      bottom: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            desc,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Swipe kiri/kanan untuk ganti planet',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            right: 12,
            top: 80,
            bottom: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_layerCount, (i) {
                final isActive = i == _currentLayer;
                return Semantics(
                  button: true,
                  label: 'Lapisan ${i + 1}',
                  selected: isActive,
                  child: GestureDetector(
                    onTap: () => _goToLayer(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white24,
                        border: Border.all(
                          color: isActive
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.white38,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rocket_launch, color: Colors.white, size: 32),
                AnimatedOpacity(
                  opacity: _isScrolling ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 8,
                    height: 16,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.orange, Colors.red],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSwitching)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                alignment: Alignment.center,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.2),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: const Text(
                        'Warp...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
