import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orbite/core/constants/nasa_images.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaQuestion {
  const _TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class _TriviaPageState extends State<TriviaPage> {
  static const _questions = <_TriviaQuestion>[
    _TriviaQuestion(
      question: 'Planet terbesar di tata surya adalah?',
      options: ['Mars', 'Jupiter', 'Saturnus', 'Neptunus'],
      correctIndex: 1,
      explanation:
          'Jupiter adalah planet terbesar dengan diameter sekitar 143.000 km.',
    ),
    _TriviaQuestion(
      question: 'Planet merah dikenal sebagai?',
      options: ['Venus', 'Mars', 'Merkurius', 'Jupiter'],
      correctIndex: 1,
      explanation:
          'Mars disebut planet merah karena oksida besi di permukaannya.',
    ),
    _TriviaQuestion(
      question: 'Planet dengan cincin paling terkenal?',
      options: ['Uranus', 'Neptunus', 'Saturnus', 'Jupiter'],
      correctIndex: 2,
      explanation: 'Saturnus memiliki cincin paling mencolok dan terang.',
    ),
    _TriviaQuestion(
      question: 'Planet terdekat dengan Matahari?',
      options: ['Venus', 'Merkurius', 'Bumi', 'Mars'],
      correctIndex: 1,
      explanation: 'Merkurius adalah planet terdekat dengan Matahari.',
    ),
    _TriviaQuestion(
      question: 'Planet dengan angin tercepat?',
      options: ['Jupiter', 'Saturnus', 'Uranus', 'Neptunus'],
      correctIndex: 3,
      explanation: 'Neptunus memiliki angin hingga 2.100 km/jam.',
    ),
    _TriviaQuestion(
      question: 'Planet yang rotasinya paling miring?',
      options: ['Bumi', 'Mars', 'Uranus', 'Venus'],
      correctIndex: 2,
      explanation: 'Uranus berotasi dengan kemiringan sekitar 98 derajat.',
    ),
  ];

  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _score = 0;
  bool _finished = false;

  _TriviaQuestion get _question => _questions[_index];

  bool get _isLast => _index == _questions.length - 1;

  double get _progress => (_index + (_answered ? 1 : 0)) / _questions.length;

  void _answer(int index) {
    if (_answered) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selected = index;
      _answered = true;
      if (index == _question.correctIndex) _score++;
    });
  }

  void _next() {
    if (_isLast) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _selected = null;
      _answered = false;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _TopBar(score: _score, total: _questions.length),
                Expanded(
                  child: _finished
                      ? _ResultView(
                          score: _score,
                          total: _questions.length,
                          onRestart: _restart,
                        )
                      : _QuestionView(
                          question: _question,
                          index: _index,
                          total: _questions.length,
                          selected: _selected,
                          answered: _answered,
                          progress: _progress,
                          onAnswer: _answer,
                          onNext: _next,
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Text(
            'Trivia',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Text(
              'Skor: $score/$total',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.answered,
    required this.progress,
    required this.onAnswer,
    required this.onNext,
  });

  final _TriviaQuestion question;
  final int index;
  final int total;
  final int? selected;
  final bool answered;
  final double progress;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 104),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              NasaImage(
                url: NasaImages.triviaHeader,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Text(
                  'Uji pengetahuan tata surya',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Pertanyaan ${index + 1} dari $total',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white12,
            color: accent,
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question.question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < question.options.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == question.options.length - 1 ? 0 : 10,
                    ),
                    child: _ChoiceTile(
                      letter: String.fromCharCode(65 + i),
                      text: question.options[i],
                      selected: selected == i,
                      correct: i == question.correctIndex,
                      answered: answered,
                      onTap: answered ? null : () => onAnswer(i),
                    ),
                  ),
                if (answered) ...[
                  const SizedBox(height: 16),
                  _FeedbackPanel(
                    correct: selected == question.correctIndex,
                    explanation: question.explanation,
                    actionLabel: index + 1 == total ? 'Lihat Skor' : 'Lanjut',
                    onAction: onNext,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.correct,
    required this.answered,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final bool correct;
  final bool answered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = answered && correct;
    final isWrong = answered && selected && !correct;
    final dimmed = answered && !isCorrect && !isWrong;

    final Color background;
    final Color border;
    final Color letterColor;
    if (isCorrect) {
      background = Colors.green.withValues(alpha: 0.18);
      border = Colors.greenAccent.withValues(alpha: 0.8);
      letterColor = Colors.greenAccent;
    } else if (isWrong) {
      background = Colors.red.withValues(alpha: 0.16);
      border = Colors.redAccent.withValues(alpha: 0.8);
      letterColor = Colors.redAccent;
    } else if (dimmed) {
      background = Colors.white.withValues(alpha: 0.03);
      border = Colors.white12;
      letterColor = Colors.white38;
    } else {
      background = const Color(0xFF202124);
      border = Colors.white24;
      letterColor = theme.colorScheme.secondary;
    }

    return Semantics(
      button: true,
      enabled: !answered,
      selected: selected,
      label: '$letter. $text',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: letterColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: letterColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: dimmed ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isCorrect)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 20,
                  ),
                if (isWrong)
                  const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.correct,
    required this.explanation,
    required this.actionLabel,
    required this.onAction,
  });

  final bool correct;
  final String explanation;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = correct ? Colors.greenAccent : Colors.redAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.info,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              correct ? 'Benar!' : 'Belum tepat',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          explanation,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: onAction,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.score,
    required this.total,
    required this.onRestart,
  });

  final int score;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final pct = total == 0 ? 0 : (score / total * 100).round();
    final message = pct >= 80
        ? 'Luar biasa, penguasaanmu tinggi.'
        : pct >= 50
        ? 'Bagus, terus asah rasa penasaranmu.'
        : 'Belum apa-apa, coba lagi sebentar lagi.';
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 104),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events, color: accent, size: 48),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Trivia selesai',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Text(
                'Skor akhir',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$score / $total',
                style: TextStyle(
                  color: accent,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$pct% benar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh),
          label: const Text('Main Lagi'),
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/planets'),
          icon: const Icon(Icons.public),
          label: const Text('Jelajahi Planet'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: Colors.white24),
          ),
        ),
      ],
    );
  }
}
