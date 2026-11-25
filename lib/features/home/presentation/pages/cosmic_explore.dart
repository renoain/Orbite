import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

class CosmicExplore extends StatefulWidget {
  const CosmicExplore({super.key});

  @override
  State<CosmicExplore> createState() => _CosmicExploreState();
}

class _CosmicExploreState extends State<CosmicExplore> {
  List<Map<String, dynamic>> _planets = <Map<String, dynamic>>[];
  List<String> _visited = <String>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jsonString = await rootBundle.loadString('assets/mock/planets.json');
      final list = json.decode(jsonString) as List<dynamic>;
      final planets = list
          .cast<Map<String, dynamic>>()
          .where((planet) => planet['id'] != 'sun')
          .toList();
      if (!mounted) return;
      setState(() {
        _planets = planets;
        _loading = false;
      });
      await _loadProgress();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Data planet tidak bisa dimuat. Coba lagi.';
      });
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _visited = prefs.getStringList('visited_planets') ?? <String>[];
    });
  }

  Map<String, dynamic>? get _featuredPlanet {
    if (_planets.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return _planets[dayOfYear % _planets.length];
  }

  void _openFocus(String name) {
    Navigator.pushNamed(context, '/focus', arguments: name).then((_) {
      if (mounted) _loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final featured = _featuredPlanet;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HomeHeader(),
          const SizedBox(height: 16),
          if (featured != null) ...[
            _HeroPlanetCard(
              planet: featured,
              onTap: () => _openFocus(featured['name'] as String? ?? ''),
            ),
            const SizedBox(height: 16),
          ],
          const _QuickAccessGrid(),
          const SizedBox(height: 16),
          const _DailyFactCard(),
          const SizedBox(height: 16),
          _PassportCard(
            planets: _planets,
            visited: _visited.toSet(),
            onOpen: _openFocus,
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orbite',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Jelajah 3D',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeroPlanetCard extends StatelessWidget {
  const _HeroPlanetCard({required this.planet, required this.onTap});

  final Map<String, dynamic> planet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = planet['name'] as String? ?? '';
    final description = planet['description'] as String? ?? '';
    final texture = planet['texture'] as String? ?? '';
    final imageUrl = planet['image_url'] as String? ?? texture;

    return SizedBox(
      height: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isNotEmpty)
                NasaImage(url: imageUrl, fit: BoxFit.cover)
              else
                Container(color: Colors.grey[900]),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.35, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Planet hari ini',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.rocket_launch, size: 18),
                        label: const Text('Lihat Detail'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(0, 44),
                        ),
                      ),
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

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  static const _items = [
    (
      title: 'Tata Surya 3D',
      subtitle: 'Eksplorasi',
      icon: Icons.public,
      route: '/solar-system',
      color: Color(0xFF0D2137),
      accent: Color(0xFF4FC3F7),
    ),
    (
      title: 'Fase Bulan',
      subtitle: 'Pantau fase',
      icon: Icons.nightlight_round,
      route: '/moon-phases',
      color: Color(0xFF1A0F2E),
      accent: Color(0xFFB388FF),
    ),
    (
      title: 'Konstelasi',
      subtitle: 'Pola bintang',
      icon: Icons.auto_awesome,
      route: '/constellations',
      color: Color(0xFF121212),
      accent: Color(0xFFFFD54F),
    ),
    (
      title: 'Trivia',
      subtitle: 'Uji pengetahuan',
      icon: Icons.quiz,
      route: '/trivia',
      color: Color(0xFF2E1A0A),
      accent: Color(0xFFFFB74D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Access',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                for (final item in _items)
                  _QuickAccessTile(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    route: item.route,
                    background: item.color,
                    accent: item.accent,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.background,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color background;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent, size: 28),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyFactCard extends StatefulWidget {
  const _DailyFactCard();

  @override
  State<_DailyFactCard> createState() => _DailyFactCardState();
}

class _DailyFactCardState extends State<_DailyFactCard> {
  String _fact = '';

  @override
  void initState() {
    super.initState();
    _loadFact();
  }

  Future<void> _loadFact() async {
    try {
      final raw = await rootBundle.loadString('assets/mock/daily_facts.json');
      final facts = (json.decode(raw) as List<dynamic>).cast<String>();
      if (facts.isEmpty || !mounted) return;
      final index = DateTime.now().day % facts.length;
      setState(() => _fact = facts[index]);
    } catch (_) {
      if (mounted) {
        setState(() => _fact = 'Mars memiliki gunung tertinggi di tata surya.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3E2C00),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fakta Harian',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fact.isEmpty ? 'Memuat fakta...' : _fact,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassportCard extends StatelessWidget {
  const _PassportCard({
    required this.planets,
    required this.visited,
    required this.onOpen,
  });

  final List<Map<String, dynamic>> planets;
  final Set<String> visited;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = planets.length;
    final count = planets
        .where((p) => visited.contains(p['name'] as String? ?? ''))
        .length;
    final progress = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Paspor Planet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$count/$total',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$count dari $total planet dikunjungi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: planets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final planet = planets[index];
                  final name = planet['name'] as String? ?? '';
                  final isVisited = visited.contains(name);
                  return ActionChip(
                    avatar: Icon(
                      isVisited ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: isVisited
                          ? AppColors.secondary
                          : Colors.white38,
                    ),
                    label: Text(name),
                    onPressed: () => onOpen(name),
                    backgroundColor: isVisited
                        ? const Color(0xFF2A2210)
                        : Colors.white10,
                    side: BorderSide(
                      color: isVisited
                          ? AppColors.secondary.withValues(alpha: 0.5)
                          : Colors.white24,
                    ),
                    labelStyle: TextStyle(
                      color: isVisited ? Colors.white : Colors.white70,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
