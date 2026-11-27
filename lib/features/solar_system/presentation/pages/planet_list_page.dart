import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:orbite/app/di.dart';
import 'package:orbite/features/solar_system/domain/entities/planet_summary.dart';
import 'package:orbite/features/solar_system/presentation/widgets/rotating_planet_3d.dart';

class PlanetListPage extends StatefulWidget {
  const PlanetListPage({super.key, this.loadPlanets});

  final Future<List<PlanetSummary>> Function()? loadPlanets;

  @override
  State<PlanetListPage> createState() => _PlanetListPageState();
}

class _PlanetListPageState extends State<PlanetListPage> {
  late Future<List<PlanetSummary>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<PlanetSummary>> _load() {
    final loader = widget.loadPlanets ?? () => AppDependencies.getPlanets();
    return loader().then(
      (planets) => planets
          .where((planet) => planet.id != 'sun' && planet.displayName != 'Matahari')
          .toList(),
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  int _crossAxisCount(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  List<PlanetSummary> _filter(List<PlanetSummary> planets) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return planets;
    return planets.where((planet) {
      final name = planet.displayName.toLowerCase();
      final desc = planet.description.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Daftar Planet')),
      body: FutureBuilder<List<PlanetSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.cloud_off,
              title: 'Gagal memuat data',
              actionLabel: 'Coba Lagi',
              onAction: _retry,
            );
          }
          final allPlanets = snapshot.data;
          if (allPlanets == null || allPlanets.isEmpty) {
            return _StateMessage(
              icon: Icons.public_off,
              title: 'Tidak ada data planet',
              actionLabel: 'Muat Ulang',
              onAction: _retry,
            );
          }
          final planets = _filter(allPlanets);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari planet...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                tooltip: 'Hapus pencarian',
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${planets.length} planet',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        if (_query.isNotEmpty && planets.isNotEmpty)
                          TextButton(
                            onPressed: _clearSearch,
                            child: const Text('Hapus pencarian'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: planets.isEmpty
                    ? _StateMessage(
                        icon: Icons.search_off,
                        title: 'Tidak ada planet untuk "$_query"',
                        actionLabel: 'Hapus pencarian',
                        onAction: _clearSearch,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _crossAxisCount(
                                constraints.maxWidth,
                              ),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: planets.length,
                            itemBuilder: (context, index) {
                              final planet = planets[index];
                              final texture = planet.textureUrl.isNotEmpty
                                  ? planet.textureUrl
                                  : planet.imageUrl;
                              return _PlanetCard(
                                texture: texture,
                                name: planet.displayName,
                                desc: planet.description,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/focus',
                                  arguments: planet.displayName,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanetCard extends StatelessWidget {
  final String texture;
  final String name;
  final String desc;
  final VoidCallback onTap;

  const _PlanetCard({
    required this.texture,
    required this.name,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
          constraints.maxWidth,
          constraints.maxHeight * 0.78,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotatingPlanet3D(texturePath: texture, size: size),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
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
