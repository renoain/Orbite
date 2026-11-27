import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbite/app/di.dart';
import 'package:orbite/core/constants/nasa_images.dart';
import 'package:orbite/core/widgets/nasa_image.dart';
import 'package:orbite/features/solar_system/domain/entities/planet_detail.dart';
import 'package:orbite/features/solar_system/domain/entities/planet_summary.dart';

class PlanetDetailPage extends StatefulWidget {
  final String planetName;
  final Future<List<PlanetSummary>> Function()? loadPlanets;
  final Future<PlanetDetail> Function(String id)? loadPlanet;

  const PlanetDetailPage({
    super.key,
    required this.planetName,
    this.loadPlanets,
    this.loadPlanet,
  });

  @override
  State<PlanetDetailPage> createState() => _PlanetDetailPageState();
}

class _PlanetDetailPageState extends State<PlanetDetailPage> {
  late Future<PlanetDetail?> _future;
  bool _isFavorite = false;
  final TextEditingController _massController = TextEditingController(text: '70');
  double? _weightOnPlanet;
  late final PageController _imageController;
  late final ScrollController _scrollController;
  Timer? _imageTimer;
  List<String> _images = <String>[];

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _scrollController = ScrollController();
    _future = _load();
    _loadFavorite();
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _imageController.dispose();
    _scrollController.dispose();
    _massController.dispose();
    super.dispose();
  }

  Future<void> _saveLastViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_viewed_planet', widget.planetName);
    final visited = prefs.getStringList('visited_planets') ?? <String>[];
    if (!visited.contains(widget.planetName)) {
      visited.add(widget.planetName);
      await prefs.setStringList('visited_planets', visited);
    }
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_planets') ?? <String>[];
    if (!mounted) return;
    setState(() {
      _isFavorite = favorites.contains(widget.planetName);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_planets') ?? <String>[];
    if (_isFavorite) {
      favorites.remove(widget.planetName);
    } else {
      if (!favorites.contains(widget.planetName)) {
        favorites.add(widget.planetName);
      }
    }
    await prefs.setStringList('favorite_planets', favorites);
    if (!mounted) return;
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<PlanetDetail?> _load() async {
    try {
      final loadPlanets =
          widget.loadPlanets ?? () => AppDependencies.getPlanets();
      final loadPlanet =
          widget.loadPlanet ?? (id) => AppDependencies.getPlanet(id);

      final summaries = await loadPlanets();
      PlanetSummary? match;
      for (final summary in summaries) {
        if (summary.name == widget.planetName ||
            summary.nameId == widget.planetName) {
          match = summary;
          break;
        }
      }
      if (match == null) return null;

      final planet = await loadPlanet(match.id);
      _saveLastViewed();
      await _prepareImages(planet);
      return planet;
    } catch (_) {
      return null;
    }
  }

  Future<void> _prepareImages(PlanetDetail planet) async {
    final slug = planet.name.toLowerCase();
    final candidates = <String>[
      NasaImages.planet[slug] ?? '',
      planet.textureUrl,
      planet.imageUrl,
      'assets/textures/2k_$slug.jpg',
      'assets/textures/$slug.jpg',
    ];
    final seen = <String>{};
    final filtered = <String>[];
    for (final path in candidates) {
      if (path.isEmpty || !seen.add(path)) continue;
      if (path.startsWith('assets/')) {
        try {
          await rootBundle.load(path);
          filtered.add(path);
        } catch (_) {}
      } else {
        filtered.add(path);
      }
    }
    if (!mounted) return;
    setState(() {
      _images = filtered.isNotEmpty ? filtered : [planet.imageUrl];
    });
    if (filtered.length > 1) {
      _imageTimer?.cancel();
      _imageTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_imageController.hasClients) return;
        final next = (_imageController.page?.round() ?? 0) + 1;
        _imageController.animateToPage(
          next % filtered.length,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  static const Map<String, double> _surfaceGravity = {
    'Merkurius': 0.38,
    'Venus': 0.91,
    'Bumi': 1.0,
    'Mars': 0.38,
    'Jupiter': 2.34,
    'Saturnus': 1.06,
    'Uranus': 0.92,
    'Neptunus': 1.19,
    'Pluto': 0.06,
    'Matahari': 27.9,
  };

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.planetName),
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Hapus favorit' : 'Tambah favorit',
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white,
            ),
          ),
        ],
      ),
      body: FutureBuilder<PlanetDetail?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.cloud_off,
              title: 'Gagal memuat detail planet',
              actionLabel: 'Coba Lagi',
              onAction: _retry,
            );
          }
          final planet = snapshot.data;
          if (planet == null) {
            return _StateMessage(
              icon: Icons.public_off,
              title: 'Detail planet tidak ditemukan',
              actionLabel: 'Muat Ulang',
              onAction: _retry,
            );
          }
          final slug = planet.name.toLowerCase();
          final fallbackImage = planet.textureUrl.isNotEmpty
              ? planet.textureUrl
              : planet.imageUrl;
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _images.length > 1
                      ? SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _imageController,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return IgnorePointer(
                                child: NasaImage(
                                  url: _images[index],
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        )
                      : NasaImage(
                          url: _images.isNotEmpty
                              ? _images.first
                              : (NasaImages.planet[slug] ??
                                  (fallbackImage.isNotEmpty
                                      ? fallbackImage
                                      : 'assets/textures/2k_earth_daymap.jpg')),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  planet.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  planet.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoChip(
                      icon: Icons.straighten,
                      label: '${planet.diameterKm ?? 0} km',
                    ),
                    _InfoChip(
                      icon: Icons.access_time,
                      label: '${planet.dayLengthHours ?? 0} jam',
                    ),
                    _InfoChip(
                      icon: Icons.public,
                      label: '${planet.orbitalPeriodDays ?? 0} hari',
                    ),
                    _InfoChip(
                      icon: Icons.brightness_3,
                      label: '${planet.moons ?? 0} bulan',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (planet.funFact.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            planet.funFact,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Berat Badan di ${planet.displayName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masukkan berat badan di Bumi (kg).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _massController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Berat (kg)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                final mass =
                                    double.tryParse(
                                      _massController.text.trim(),
                                    ) ??
                                    0;
                                final factor = planet.gravity ??
                                    _surfaceGravity[planet.displayName] ??
                                    1.0;
                                setState(() {
                                  _weightOnPlanet = mass * factor;
                                });
                              },
                              child: const Text('Hitung'),
                            ),
                          ],
                        ),
                        if (_weightOnPlanet != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Di ${planet.displayName}: '
                            '${_weightOnPlanet!.toStringAsFixed(1)} kg',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (slug == 'earth' || slug == 'mars')
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/interior',
                      arguments: planet.displayName,
                    ),
                    icon: const Icon(Icons.layers),
                    label: const Text('Lihat Interior'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.layers),
                    label: const Text('Interior belum tersedia'),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/quiz',
                    arguments: planet.displayName,
                  ),
                  icon: const Icon(Icons.quiz),
                  label: const Text('Kuis Planet'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white,
                  ),
                  label: Text(_isFavorite ? 'Hapus Favorit' : 'Tambah Favorit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
