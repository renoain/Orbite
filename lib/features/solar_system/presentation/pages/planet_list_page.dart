import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

class PlanetListPage extends StatefulWidget {
  const PlanetListPage({super.key});

  @override
  State<PlanetListPage> createState() => _PlanetListPageState();
}

class _PlanetListPageState extends State<PlanetListPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final jsonString = await rootBundle.loadString('assets/mock/planets.json');
    final list = json.decode(jsonString) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  int _crossAxisCount(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
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
          final planets = snapshot.data;
          if (planets == null || planets.isEmpty) {
            return _StateMessage(
              icon: Icons.public_off,
              title: 'Tidak ada data planet',
              actionLabel: 'Muat Ulang',
              onAction: _retry,
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount(constraints.maxWidth),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: planets.length,
                itemBuilder: (context, index) {
                  final planet = planets[index];
                  final name = planet['name'] as String? ?? '';
                  final desc = planet['description'] as String? ?? '';
                  final url = planet['image_url'] as String? ?? '';
                  return _PlanetCard(
                    name: name,
                    description: desc,
                    imageUrl: url,
                    onTap: () =>
                        Navigator.pushNamed(context, '/focus', arguments: name),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PlanetCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;

  const _PlanetCard({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Planet $name',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: imageUrl.isNotEmpty
                    ? NasaImage(url: imageUrl, fit: BoxFit.cover)
                    : Container(color: Colors.grey[800]),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.white54),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
