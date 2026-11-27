import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

const _hairline = Color(0x1FFFFFFF);
const _muted = Color(0xB3FFFFFF);
const _subtle = Color(0x8AFFFFFF);

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
      final jsonString = await rootBundle.loadString(
        'assets/mock/planets.json',
      );
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
      return const _HomeSkeleton();
    }
    if (_error != null) {
      return _HomeMessage(
        title: 'Planet tidak bisa dimuat',
        message: _error!,
        actionLabel: 'Muat ulang',
        onAction: _load,
      );
    }
    final featured = _featuredPlanet;
    if (featured == null) {
      return _HomeMessage(
        title: 'Belum ada planet',
        message: 'Data planet masih kosong. Muat ulang untuk mencoba lagi.',
        actionLabel: 'Muat ulang',
        onAction: _load,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final heroHeight = (constraints.maxWidth * (wide ? 0.52 : 1.18)).clamp(
          wide ? 320.0 : 372.0,
          460.0,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 104,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroPlanet(
                planet: featured,
                height: heroHeight,
                onOpen: () => _openFocus(featured['name'] as String? ?? ''),
              ),
              const _ExploreRail(),
              const _DailyFact(),
              _Passport(
                planets: _planets,
                visited: _visited.toSet(),
                onOpen: _openFocus,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitMark extends StatelessWidget {
  const _OrbitMark({this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _OrbitMarkPainter(AppColors.secondary)),
    );
  }
}

class _OrbitMarkPainter extends CustomPainter {
  const _OrbitMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final ring = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final orbit = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 1.15,
    );
    canvas.drawOval(orbit, ring);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.86, center.dy - radius * 0.3),
      2.2,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_OrbitMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _HeroPlanet extends StatelessWidget {
  const _HeroPlanet({
    required this.planet,
    required this.height,
    required this.onOpen,
  });

  final Map<String, dynamic> planet;
  final double height;
  final VoidCallback onOpen;

  String get _imagePath {
    final texture = planet['texture'] as String? ?? '';
    if (texture.isNotEmpty) return texture;
    return planet['image_url'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = planet['name'] as String? ?? 'Planet';
    final description = planet['description'] as String? ?? '';
    final distance = (planet['distance'] as num?)?.toDouble();
    final diameter = (planet['diameter'] as num?)?.toInt();
    final safeTop = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFF0E1116),
            child: _imagePath.isEmpty
                ? const SizedBox.shrink()
                : NasaImage(url: _imagePath, fit: BoxFit.cover),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC000000),
                  Color(0x33000000),
                  Color(0x00000000),
                  Color(0xE6000000),
                ],
                stops: [0, 0.22, 0.48, 1],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: const Alignment(0.9, -0.42),
                child: SizedBox(
                  width: widthForOrbit(context),
                  height: height * 0.55,
                  child: const CustomPaint(painter: _HeroOrbitPainter()),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, safeTop + 12, 20, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Row(
                  children: [
                    const _OrbitMark(size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Orbite',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Jelajah 3D',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Planet hari ini',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 18,
                      runSpacing: 6,
                      children: [
                        if (distance != null)
                          _HeroStat(
                            value: _formatDistance(distance),
                            label: 'dari Matahari',
                          ),
                        if (diameter != null)
                          _HeroStat(
                            value: '${_groupDigits(diameter)} km',
                            label: 'diameter',
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Buka $name',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double widthForOrbit(BuildContext context) =>
    MediaQuery.sizeOf(context).width * 0.9;

String _formatDistance(double value) {
  final parts = value.toStringAsFixed(1).split('.');
  return '${_groupDigits(int.parse(parts[0]))},${parts[1]} jt km';
}

String _groupDigits(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
}

class _HeroOrbitPainter extends CustomPainter {
  const _HeroOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width * 0.55, size.height * 0.42);
    for (final scale in [1.0, 0.72]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * 0.92 * scale,
          height: size.height * 0.86 * scale,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeroOrbitPainter oldDelegate) => false;
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: _subtle),
        ),
      ],
    );
  }
}

class _ExploreRail extends StatelessWidget {
  const _ExploreRail();

  static const _destinations = [
    (
      title: 'Solar System',
      note: 'Model 3D interaktif',
      image: 'assets/textures/sun.jpg',
      route: '/solar-system',
    ),
    (
      title: 'Fase Bulan',
      note: 'Siklus satu bulan',
      image: 'assets/images/surface/moon_surface.jpg',
      route: '/moon-phases',
    ),
    (
      title: 'Musim Bumi',
      note: 'Kemiringan & musim',
      image: 'assets/images/surface/earth_surface.jpg',
      route: '/seasons',
    ),
    (
      title: 'Gerhana 3D',
      note: 'Matahari, Bumi, Bulan',
      image: 'assets/images/surface/moon_surface.jpg',
      route: '/eclipse',
    ),
    (
      title: 'Konstelasi',
      note: 'Peta langit malam',
      image: 'assets/textures/stars.jpg',
      route: '/constellations',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Jelajahi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _destinations.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final dest = _destinations[index];
                    return _DestinationCard(
                      title: dest.title,
                      note: dest.note,
                      image: dest.image,
                      onTap: () => Navigator.pushNamed(context, dest.route),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.title,
    this.note = '',
    required this.image,
    required this.onTap,
  });

  final String title;
  final String? note;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '$title. ${note ?? ''}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 152,
          child: Material(
            color: const Color(0xFF141517),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NasaImage(url: image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x66000000),
                          Color(0xF2000000),
                        ],
                        stops: [0.35, 0.62, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          note ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyFact extends StatefulWidget {
  const _DailyFact();

  @override
  State<_DailyFact> createState() => _DailyFactState();
}

class _DailyFactState extends State<_DailyFact> {
  String _fact = '';
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadFact();
  }

  Future<void> _loadFact() async {
    try {
      final raw = await rootBundle.loadString('assets/mock/daily_facts.json');
      final facts = (json.decode(raw) as List<dynamic>).cast<String>();
      if (!mounted) return;
      if (facts.isEmpty) {
        setState(() => _failed = true);
        return;
      }
      final index = DateTime.now().day % facts.length;
      setState(() {
        _fact = facts[index];
        _failed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Container(
            padding: const EdgeInsets.only(top: 18, bottom: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: _hairline),
                bottom: BorderSide(color: _hairline),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _OrbitMark(size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Fakta hari ini',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_failed)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Fakta hari ini belum bisa dimuat.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _subtle,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadFact,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          minimumSize: const Size(48, 44),
                        ),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  )
                else
                  Text(
                    _fact.isEmpty ? 'Memuat fakta...' : _fact,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _fact.isEmpty
                          ? _subtle
                          : Colors.white.withValues(alpha: 0.86),
                      height: 1.55,
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

class _Passport extends StatelessWidget {
  const _Passport({
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Paspor Planet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Text(
                    '$count/$total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                count == 0
                    ? 'Buka satu planet untuk mulai mengisi paspor.'
                    : '$count dari $total planet sudah kamu buka.',
                style: theme.textTheme.bodySmall?.copyWith(color: _subtle),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Progres paspor',
                value: '$count dari $total planet',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: _hairline,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: planets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final planet = planets[index];
                    final name = planet['name'] as String? ?? '';
                    return _PassportPlanet(
                      name: name,
                      texture: planet['texture'] as String? ?? '',
                      visited: visited.contains(name),
                      onTap: () => onOpen(name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassportPlanet extends StatelessWidget {
  const _PassportPlanet({
    required this.name,
    required this.texture,
    required this.visited,
    required this.onTap,
  });

  final String name;
  final String texture;
  final bool visited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: visited ? '$name, sudah dikunjungi' : '$name, belum dikunjungi',
      child: SizedBox(
        width: 62,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(31),
            child: Column(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Opacity(
                        opacity: visited ? 1 : 0.32,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: visited
                                  ? AppColors.secondary
                                  : Colors.white24,
                              width: visited ? 2 : 1,
                            ),
                            image: texture.isEmpty
                                ? null
                                : DecorationImage(
                                    image: AssetImage(texture),
                                    fit: BoxFit.cover,
                                  ),
                            color: const Color(0xFF1A1B1E),
                          ),
                        ),
                      ),
                      if (visited)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: visited ? Colors.white : _subtle,
                    fontWeight: visited ? FontWeight.w600 : FontWeight.w400,
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

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat planet',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 372, color: const Color(0xFF141517)),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBar(width: 120, height: 20),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SkeletonBar(
                          width: double.infinity,
                          height: 196,
                          radius: 18,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _SkeletonBar(
                          width: double.infinity,
                          height: 196,
                          radius: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  _SkeletonBar(width: double.infinity, height: 14),
                  SizedBox(height: 10),
                  _SkeletonBar(width: 220, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E22),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _OrbitMark(size: 32),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _subtle,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
