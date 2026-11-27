import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbite/core/widgets/nasa_image.dart';

class LearnPlanet {
  const LearnPlanet({
    required this.name,
    required this.description,
    required this.texture,
  });

  final String name;
  final String description;
  final String texture;
}

class LearnPage extends StatefulWidget {
  const LearnPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  List<LearnPlanet> _planets = const [];
  Set<String> _visited = const <String>{};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LearnPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshProgress();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jsonString = await rootBundle.loadString(
        'assets/mock/planets.json',
      );
      final list = json.decode(jsonString) as List<dynamic>;
      final planets = <LearnPlanet>[
        for (final item in list.cast<Map<String, dynamic>>())
          if (item['id'] != 'sun')
            LearnPlanet(
              name: item['name'] as String? ?? '',
              description: item['description'] as String? ?? '',
              texture: item['texture'] as String? ?? '',
            ),
      ];
      final prefs = await SharedPreferences.getInstance();
      final visited =
          prefs.getStringList('visited_planets') ?? const <String>[];
      if (!mounted) return;
      setState(() {
        _planets = planets;
        _visited = visited.toSet();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Data planet tidak bisa dimuat.';
      });
    }
  }

  Future<void> _refreshProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _visited = (prefs.getStringList('visited_planets') ?? const <String>[])
            .toSet();
      });
    } catch (_) {
      return;
    }
  }

  LearnPlanet? get _featuredPlanet {
    if (_planets.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return _planets[dayOfYear % _planets.length];
  }

  void _openPlanet(String name) {
    Navigator.pushNamed(context, '/focus', arguments: name).then((_) {
      if (mounted) _refreshProgress();
    });
  }

  void _openRoute(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const _LearnLoading();
    }
    if (_error != null) {
      return SafeArea(
        child: _ErrorState(
          title: 'Planet tidak bisa dimuat',
          message: _error!,
          onRetry: _load,
        ),
      );
    }
    if (_planets.isEmpty) {
      return const SafeArea(child: _EmptyState());
    }

    final theme = Theme.of(context);
    final featured = _featuredPlanet!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: EdgeInsets.only(bottom: bottomInset + 104),
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Pelajari Planet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _Section(
              title: 'Planet Hari Ini',
              child: _FeaturedPlanetCard(
                planet: featured,
                onTap: () => _openPlanet(featured.name),
              ),
            ),
            _Section(
              title: 'Menu Cepat',
              child: _QuickMenu(
                onOpenRoute: _openRoute,
                onOpenFocus: () => _openPlanet(featured.name),
              ),
            ),
            _Section(
              title: 'Paspor Planet',
              child: _PassportChips(
                planets: _planets,
                visited: _visited,
                onOpen: _openPlanet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FeaturedPlanetCard extends StatelessWidget {
  const _FeaturedPlanetCard({required this.planet, required this.onTap});

  final LearnPlanet planet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Planet hari ini, ${planet.name}',
      child: Material(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 120,
                    child: planet.texture.isEmpty
                        ? const ColoredBox(color: Color(0xFF262626))
                        : NasaImage(url: planet.texture, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  planet.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  planet.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu({required this.onOpenRoute, required this.onOpenFocus});

  final ValueChanged<String> onOpenRoute;
  final VoidCallback onOpenFocus;

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Daftar Planet', onTap: () => onOpenRoute('/planets')),
      (label: 'Bandingkan', onTap: () => onOpenRoute('/compare')),
      (label: 'Musim Bumi', onTap: () => onOpenRoute('/seasons')),
      (label: 'Gerhana 3D', onTap: () => onOpenRoute('/eclipse')),
      (label: 'Trivia', onTap: () => onOpenRoute('/trivia')),
      (label: 'Focus', onTap: onOpenFocus),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        for (final item in items)
          _QuickMenuCard(label: item.label, onTap: item.onTap),
      ],
    );
  }
}

class _QuickMenuCard extends StatelessWidget {
  const _QuickMenuCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PassportChips extends StatelessWidget {
  const _PassportChips({
    required this.planets,
    required this.visited,
    required this.onOpen,
  });

  final List<LearnPlanet> planets;
  final Set<String> visited;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final planet in planets)
          ActionChip(
            avatar: visited.contains(planet.name)
                ? Icon(Icons.check, size: 16, color: accent)
                : null,
            label: Text(planet.name),
            onPressed: () => onOpen(planet.name),
            backgroundColor: const Color(0xFF1A1A1A),
            side: const BorderSide(color: Color(0xFF2A2A2A)),
            labelStyle: TextStyle(
              color: visited.contains(planet.name)
                  ? Colors.white
                  : Colors.white70,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

class _LearnLoading extends StatelessWidget {
  const _LearnLoading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat halaman belajar',
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data planet',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Data planet akan muncul setelah muat.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
