import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizPage extends StatefulWidget {
  final String planetName;

  const QuizPage({super.key, required this.planetName});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const _planetIds = {
    'merkurius': 'mercury',
    'mercury': 'mercury',
    'venus': 'venus',
    'bumi': 'earth',
    'earth': 'earth',
    'mars': 'mars',
    'jupiter': 'jupiter',
    'saturnus': 'saturn',
    'saturn': 'saturn',
    'uranus': 'uranus',
    'neptunus': 'neptune',
    'neptune': 'neptune',
    'matahari': 'sun',
    'sun': 'sun',
  };

  String get _planetId {
    final lower = widget.planetName.toLowerCase();
    for (final entry in _planetIds.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'earth';
  }

  String get _planetName {
    const names = {
      'mercury': 'Merkurius',
      'venus': 'Venus',
      'earth': 'Bumi',
      'mars': 'Mars',
      'jupiter': 'Jupiter',
      'saturn': 'Saturnus',
      'uranus': 'Uranus',
      'neptune': 'Neptunus',
      'sun': 'Matahari',
    };
    return names[_planetId] ?? widget.planetName;
  }

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _questions = [];
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

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
      final jsonStr = await rootBundle.loadString('assets/mock/quiz.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data[_planetId] as List<dynamic>?) ?? [];
      if (!mounted) return;
      setState(() {
        _questions = list.cast<Map<String, dynamic>>();
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

  void _select(int i) {
    if (_answered) return;
    final correct = _questions[_index]['answer'] as int;
    setState(() {
      _selected = i;
      _answered = true;
      if (i == correct) _score++;
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Kuis $_planetName')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white54),
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
                ],
              ),
            )
          : _questions.isEmpty
          ? const Center(
              child: Text(
                'Belum ada kuis untuk planet ini.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : _finished
          ? _ResultView(
              score: _score,
              total: _questions.length,
              onRestart: _restart,
            )
          : _QuestionView(
              question: _questions[_index],
              index: _index,
              total: _questions.length,
              selected: _selected,
              answered: _answered,
              onSelect: _select,
              onNext: _next,
            ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final Map<String, dynamic> question;
  final int index;
  final int total;
  final int? selected;
  final bool answered;
  final void Function(int) onSelect;
  final VoidCallback onNext;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.answered,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final choices = (question['choices'] as List<dynamic>).cast<String>();
    final correct = question['answer'] as int;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pertanyaan ${index + 1} dari $total',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            question['q'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            Color bg = Colors.grey[800]!;
            Color border = Colors.white24;
            if (answered) {
              if (i == correct) {
                bg = Colors.green.withValues(alpha: 0.25);
                border = Colors.green;
              } else if (i == selected) {
                bg = Colors.red.withValues(alpha: 0.25);
                border = Colors.red;
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    choices[i],
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          if (answered)
            ElevatedButton(
              onPressed: onNext,
              child: Text(
                index + 1 >= total ? 'Lihat Skor' : 'Lanjut',
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const _ResultView({
    required this.score,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (score / total * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
            const SizedBox(height: 12),
            Text(
              'Skor: $score / $total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$pct%',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Ulangi'),
            ),
          ],
        ),
      ),
    );
  }
}