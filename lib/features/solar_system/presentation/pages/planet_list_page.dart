import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbite/features/solar_system/presentation/widgets/rotating_planet_3d.dart';

class PlanetListPage extends StatefulWidget {
  const PlanetListPage({super.key});

  @override
  State<PlanetListPage> createState() => _PlanetListPageState();
}

class _PlanetListPageState extends State<PlanetListPage> {
  late Future<List<Map<String, dynamic>>> _future;
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

  Future<List<Map<String, dynamic>>> _load() async {
    final jsonString = await rootBundle.loadString('assets/mock/planets.json');
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .where((planet) => planet['id'] != 'sun')
        .toList();
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

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> planets) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return planets;
    return planets.where((planet) {
      final name = (planet['name'] as String? ?? '').toLowerCase();
      final desc = (planet['description'] as String? ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Daftar Planet')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
                              final name = planet['name'] as String? ?? '';
                              final desc =
                                  planet['description'] as String? ?? '';
                              final texture = planet['texture'] as String? ?? '';
                              return _PlanetCard(texture: texture, name: name, desc: desc, onTap: () => Navigator.pushNamed(context, '/focus', arguments: name));
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