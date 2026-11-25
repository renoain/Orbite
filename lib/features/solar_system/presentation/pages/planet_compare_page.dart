import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orbite/core/constants/nasa_images.dart';
import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

class PlanetComparePage extends StatefulWidget {
  const PlanetComparePage({super.key});

  @override
  State<PlanetComparePage> createState() => _PlanetComparePageState();
}

class _PlanetComparePageState extends State<PlanetComparePage> {
  static const Color _colorA = AppColors.secondary;
  static const Color _colorB = Color(0xFFB0BEC5);

  static const List<_Metric> _metrics = [
    _Metric(key: 'diameter', label: 'Diameter', unit: 'km'),
    _Metric(key: 'distance', label: 'Jarak dari Matahari', unit: 'juta km'),
    _Metric(key: 'dayLength', label: 'Lama hari', unit: 'jam'),
    _Metric(key: 'orbitalPeriod', label: 'Periode orbit', unit: 'hari'),
    _Metric(key: 'moons', label: 'Jumlah bulan', unit: 'bulan'),
    _Metric(key: 'gravity', label: 'Gravitasi', unit: 'x Bumi'),
  ];

  List<Map<String, dynamic>> _planets = <Map<String, dynamic>>[];
  bool _loading = true;
  String? _error;
  String? _a;
  String? _b;

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
      final jsonStr = await rootBundle.loadString('assets/mock/planets.json');
      final list = json.decode(jsonStr) as List<dynamic>;
      final planets = list
          .cast<Map<String, dynamic>>()
          .where((planet) => planet['id'] != 'sun')
          .toList();
      if (!mounted) return;
      setState(() {
        _planets = planets;
        _a = planets.isNotEmpty ? planets.first['name'] as String? : null;
        _b = planets.length > 1 ? planets[1]['name'] as String? : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Data planet tidak bisa dibaca. Coba muat ulang.';
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? _find(String? name) {
    if (name == null) return null;
    for (final planet in _planets) {
      if (planet['name'] == name) return planet;
    }
    return null;
  }

  double _val(Map<String, dynamic>? planet, String key) {
    if (planet == null) return 0;
    final value = planet[key];
    if (value is num) return value.toDouble();
    return 0;
  }

  void _swap() {
    setState(() {
      final temporary = _a;
      _a = _b;
      _b = temporary;
    });
  }

  String _conclusion(Map<String, dynamic> a, Map<String, dynamic> b) {
    final diameterA = _val(a, 'diameter');
    final diameterB = _val(b, 'diameter');
    if (diameterA == 0 || diameterB == 0 || diameterA == diameterB) return '';
    final bigger = diameterA > diameterB ? a['name'] : b['name'];
    final smaller = diameterA > diameterB ? b['name'] : a['name'];
    final factor = diameterA > diameterB
        ? diameterA / diameterB
        : diameterB / diameterA;
    return '$bigger ${_formatNumber(factor)} kali lebih besar dari $smaller '
        'berdasarkan diameter.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Bandingkan Planet')),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat data perbandingan',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return _StateMessage(
        icon: Icons.cloud_off,
        title: 'Gagal memuat data',
        message: _error!,
        actionLabel: 'Coba lagi',
        onAction: _load,
      );
    }
    if (_planets.length < 2) {
      return _StateMessage(
        icon: Icons.public_off,
        title: 'Belum cukup planet',
        message: 'Perbandingan membutuhkan minimal dua planet.',
        actionLabel: 'Muat ulang',
        onAction: _load,
      );
    }
    final planetA = _find(_a);
    final planetB = _find(_b);
    if (planetA == null || planetB == null) {
      return _StateMessage(
        icon: Icons.error_outline,
        title: 'Planet tidak ditemukan',
        message: 'Pilih ulang planet yang ingin dibandingkan.',
        actionLabel: 'Muat ulang',
        onAction: _load,
      );
    }
    final conclusion = _conclusion(planetA, planetB);
    return ListView(
      addAutomaticKeepAlives: false,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Pilih dua planet',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bar A dan B mengikuti nilai terbesar pada setiap baris.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        _SelectorCard(
          label: 'Planet A',
          value: _a,
          planets: _planets,
          exclude: _b,
          color: _colorA,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _a = value);
          },
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: _swap,
            icon: const Icon(Icons.swap_vert, size: 18),
            label: const Text('Tukar A dan B'),
          ),
        ),
        const SizedBox(height: 8),
        _SelectorCard(
          label: 'Planet B',
          value: _b,
          planets: _planets,
          exclude: _a,
          color: _colorB,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _b = value);
          },
        ),
        const SizedBox(height: 20),
        _LegendRow(
          nameA: planetA['name'] as String? ?? '',
          nameB: planetB['name'] as String? ?? '',
          colorA: _colorA,
          colorB: _colorB,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (var index = 0; index < _metrics.length; index++) ...[
                  if (index > 0)
                    const Divider(height: 1, color: Colors.white12),
                  _MetricRow(
                    metric: _metrics[index],
                    valueA: _val(planetA, _metrics[index].key),
                    valueB: _val(planetB, _metrics[index].key),
                    colorA: _colorA,
                    colorB: _colorB,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (conclusion.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ConclusionCard(text: conclusion),
        ],
      ],
    );
  }
}

class _SelectorCard extends StatelessWidget {
  const _SelectorCard({
    required this.label,
    required this.value,
    required this.planets,
    required this.exclude,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<Map<String, dynamic>> planets;
  final String? exclude;
  final Color color;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _findPlanet(planets, value);
    final image = selected == null
        ? ''
        : (NasaImages.planet[selected['id'] as String? ?? ''] ??
              selected['image_url'] as String? ??
              '');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.7)),
            ),
            child: ClipOval(
              child: NasaImage(
                url: image,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(Icons.expand_more, color: Colors.white70),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    items: planets
                        .where((planet) => planet['name'] != exclude)
                        .map((planet) {
                          final name = planet['name'] as String? ?? '';
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        })
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.nameA,
    required this.nameB,
    required this.colorA,
    required this.colorB,
  });

  final String nameA;
  final String nameB;
  final Color colorA;
  final Color colorB;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _Legend(
            name: nameA,
            color: colorA,
            textAlign: TextAlign.left,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _Legend(
            name: nameB,
            color: colorB,
            textAlign: TextAlign.right,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.name,
    required this.color,
    required this.textAlign,
    required this.style,
  });

  final String name;
  final Color color;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.metric,
    required this.valueA,
    required this.valueB,
    required this.colorA,
    required this.colorB,
  });

  final _Metric metric;
  final double valueA;
  final double valueB;
  final Color colorA;
  final Color colorB;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = math.max(valueA, valueB);
    final ratioA = maxValue > 0 ? (valueA / maxValue).clamp(0.0, 1.0) : 0.0;
    final ratioB = maxValue > 0 ? (valueB / maxValue).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            metric.label,
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricValue(
                  value: _formatValue(valueA, metric.unit),
                  ratio: ratioA,
                  color: colorA,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricValue(
                  value: _formatValue(valueB, metric.unit),
                  ratio: ratioB,
                  color: colorB,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({
    required this.value,
    required this.ratio,
    required this.color,
  });

  final String value;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 6,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConclusionCard extends StatelessWidget {
  const _ConclusionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.straighten, color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
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

class _Metric {
  const _Metric({required this.key, required this.label, required this.unit});

  final String key;
  final String label;
  final String unit;
}

Map<String, dynamic>? _findPlanet(
  List<Map<String, dynamic>> planets,
  String? name,
) {
  if (name == null) return null;
  for (final planet in planets) {
    if (planet['name'] == name) return planet;
  }
  return null;
}

String _formatValue(double value, String unit) {
  final number = _formatNumber(value);
  return unit.isEmpty ? number : '$number $unit';
}

String _formatNumber(double value) {
  final isWhole = value == value.roundToDouble();
  final decimals = isWhole ? 0 : (value.abs() < 10 ? 2 : 1);
  final fixed = value.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final whole = _groupThousands(parts[0]);
  if (parts.length == 1) return whole;
  return '$whole,${parts[1]}';
}

String _groupThousands(String digits) {
  var text = digits;
  var sign = '';
  if (text.startsWith('-')) {
    sign = '-';
    text = text.substring(1);
  }
  final buffer = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) buffer.write('.');
    buffer.write(text[index]);
  }
  return '$sign$buffer';
}
