import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConstellationPage extends StatefulWidget {
  const ConstellationPage({super.key});

  @override
  State<ConstellationPage> createState() => _ConstellationPageState();
}

class _ConstellationPageState extends State<ConstellationPage> {
  List<Map<String, dynamic>> _constellations = [];
  bool _loading = true;
  String? _error;
  int _selected = 0;
  String? _tappedStar;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/constellations.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _constellations = (data['constellations'] as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Peta Konstelasi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Peta Konstelasi')),
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.white70))),
      );
    }
    final c = _constellations.isNotEmpty ? _constellations[_selected] : null;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Peta Konstelasi')),
      body: Column(
        children: [
          if (_constellations.length > 1)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children: List.generate(_constellations.length, (i) {
                  final name = _constellations[i]['name'] as String? ?? '';
                  return ChoiceChip(
                    label: Text(name),
                    selected: i == _selected,
                    onSelected: (_) => setState(() {
                      _selected = i;
                      _tappedStar = null;
                    }),
                  );
                }),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _showDescription = !_showDescription),
                  child: Text(_showDescription ? 'Sembunyikan penjelasan' : 'Tampilkan penjelasan'),
                ),
              ],
            ),
          ),
          if (_showDescription && c != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                c['description'] as String? ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
                child: GestureDetector(
                  onTapDown: (details) {
                    if (c == null) return;
                    final stars = (c['stars'] as List<dynamic>).cast<Map<String, dynamic>>();
                    final local = details.localPosition;
                    // Need size; use a fixed reference. We'll compare using a MediaQuery size approximation.
                    final size = MediaQuery.of(context).size;
                    // Use the painter's coordinate space: map relative to full canvas.
                    // Since InteractiveViewer, local is in child space; approximate with size.
                    double bestDist = 24;
                    String? best;
                    for (final s in stars) {
                      final x = (s['x'] as num).toDouble() * size.width * 0.9;
                      final y = (s['y'] as num).toDouble() * size.height * 0.6;
                      final d = (Offset(x, y) - local).distance;
                      if (d < bestDist) {
                        bestDist = d;
                        best = s['name'] as String?;
                      }
                    }
                    setState(() => _tappedStar = best);
                  },
                  child: CustomPaint(
                  painter: _ConstellationPainter(
                    constellation: c,
                    tappedStar: _tappedStar,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          if (_tappedStar != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Bintang: $_tappedStar', style: const TextStyle(color: Colors.amber)),
            ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Geser untuk pan, pinch untuk zoom.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter({required this.constellation, this.tappedStar});

  final Map<String, dynamic>? constellation;
  final String? tappedStar;

  @override
  void paint(Canvas canvas, Size size) {
    if (constellation == null) return;
    final stars = (constellation!['stars'] as List<dynamic>).cast<Map<String, dynamic>>();
    final lines = (constellation!['lines'] as List<dynamic>).cast<List<dynamic>>();

    // background stars
    final rng = math.Random(42);
    final bgPaint = Paint()..color = Colors.white54;
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.8, bgPaint);
    }

    final positions = <Offset>[];
    for (final s in stars) {
      final x = (s['x'] as num).toDouble() * size.width;
      final y = (s['y'] as num).toDouble() * size.height;
      positions.add(Offset(x, y));
    }

    // lines
    final linePaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    for (final l in lines) {
      final a = l[0] as int;
      final b = l[1] as int;
      if (a < positions.length && b < positions.length) {
        canvas.drawLine(positions[a], positions[b], linePaint);
      }
    }

    // stars
    for (int i = 0; i < positions.length; i++) {
      final s = stars[i];
      final name = s['name'] as String? ?? '';
      final isTapped = name == tappedStar;
      final starPaint = Paint()..color = isTapped ? Colors.amber : Colors.white;
      canvas.drawCircle(positions[i], isTapped ? 5 : 3.5, starPaint);
      // glow
      canvas.drawCircle(
        positions[i],
        isTapped ? 9 : 7,
        Paint()..color = (isTapped ? Colors.amber : Colors.white).withValues(alpha: 0.2),
      );

      final tp = TextPainter(
        text: TextSpan(text: name, style: TextStyle(color: Colors.white70, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, positions[i] + const Offset(6, -6));
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) =>
      oldDelegate.constellation != constellation || oldDelegate.tappedStar != tappedStar;
}
