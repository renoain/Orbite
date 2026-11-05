import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbite/core/constants/nasa_images.dart';
import 'package:orbite/core/widgets/floating_nav_bar.dart';
import 'package:orbite/core/widgets/nasa_image.dart';
import 'package:orbite/features/solar_system/presentation/widgets/home_scene.dart';
import 'package:orbite/features/solar_system/presentation/widgets/planet_info_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isPlaying = true;
  bool _isFullscreen = false;

  void _showPlanetInfo(String planetId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlanetInfoBottomSheet(
        planetId: planetId,
        onViewDetail: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/focus',
            arguments: _getPlanetName(planetId),
          );
        },
      ),
    );
  }

  String _getPlanetName(String planetId) {
    final names = {
      'mercury': 'Merkurius',
      'venus': 'Venus',
      'earth': 'Bumi',
      'mars': 'Mars',
      'jupiter': 'Jupiter',
      'saturn': 'Saturnus',
      'uranus': 'Uranus',
      'neptune': 'Neptunus',
      'pluto': 'Pluto',
      'sun': 'Matahari',
    };
    return names[planetId] ?? 'Planet';
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    SystemChrome.setEnabledSystemUIMode(
      _isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildExplore(),
              const LearnPage(),
              const TriviaPage(),
              const SettingsPage(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplore() {
    return Stack(
      children: [
        HomeScene(isPlaying: _isPlaying, onPlanetTap: _showPlanetInfo),
        Positioned(
          bottom: 96,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'fullscreen',
                tooltip: _isFullscreen ? 'Keluar layar penuh' : 'Layar penuh',
                onPressed: _toggleFullscreen,
                child: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'playPause',
                tooltip: _isPlaying ? 'Jeda animasi' : 'Putar animasi',
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        color: Colors.grey[900],
        child: const Center(
          child: Text(
            'Tata Surya 3D',
            style: TextStyle(color: Colors.white54, fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Pelajari Planet')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Pelajari setiap planet',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Buka daftar planet untuk melihat detail dan lapisan interior.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/planets'),
                icon: const Icon(Icons.list),
                label: const Text('Lihat Daftar Planet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  static const _questions = [
    _TriviaQuestion(
      question: 'Planet terbesar di tata surya adalah?',
      options: ['Mars', 'Jupiter', 'Saturnus', 'Neptunus'],
      correctIndex: 1,
      explanation:
          'Jupiter adalah planet terbesar dengan diameter ~143.000 km.',
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
      explanation: 'Neptunus memiliki angin hingga 2100 km/jam.',
    ),
  ];

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _score = 0;

  void _answer(int index) {
    if (_answered) return;
    final q = _questions[_currentIndex];
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (index == q.correctIndex) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFinished = _answered && _currentIndex == _questions.length - 1;
    final q = _questions[_currentIndex];
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Trivia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NasaImage(
            url: NasaImages.triviaHeader,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              'Skor: $_score/${_questions.length}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentIndex + (isFinished ? 1 : 0)) / _questions.length,
            backgroundColor: Colors.white12,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pertanyaan ${_currentIndex + 1}/${_questions.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.question,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (i) {
                    final selected = _selectedIndex == i;
                    final correct = q.correctIndex == i;
                    Color? bg;
                    if (_answered) {
                      if (correct) {
                        bg = Colors.green.withValues(alpha: 0.3);
                      } else if (selected) {
                        bg = Colors.red.withValues(alpha: 0.3);
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _answered ? null : () => _answer(i),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: bg,
                            side: BorderSide(
                              color: _answered && correct
                                  ? Colors.green
                                  : Colors.white24,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          child: Text(
                            q.options[i],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_answered) ...[
                    const SizedBox(height: 8),
                    Text(
                      _selectedIndex == q.correctIndex ? 'Benar!' : 'Salah.',
                      style: TextStyle(
                        color: _selectedIndex == q.correctIndex
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.explanation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!isFinished)
                      ElevatedButton(
                        onPressed: _next,
                        child: const Text('Lanjut'),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skor akhir: $_score/${_questions.length}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _restart,
                            child: const Text('Main Lagi'),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _soundOn = true;
  bool _isIndonesian = true;

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Orbite',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Gambar dan data dari NASA (science.nasa.gov). Digunakan untuk tujuan edukasi.',
      children: const [
        SizedBox(height: 8),
        Text('Kredit: NASA, ESA, dan komunitas open source.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Suara'),
            subtitle: const Text('Efek suara aplikasi'),
            value: _soundOn,
            onChanged: (v) => setState(() => _soundOn = v),
            secondary: Icon(
              _soundOn ? Icons.volume_up : Icons.volume_off,
              color: Colors.white54,
            ),
          ),
          SwitchListTile(
            title: const Text('Bahasa'),
            subtitle: Text(_isIndonesian ? 'Indonesia' : 'English'),
            value: _isIndonesian,
            onChanged: (v) => setState(() => _isIndonesian = v),
            secondary: const Icon(Icons.language, color: Colors.white54),
          ),
          ListTile(
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Versi, kredit, lisensi'),
            trailing: const Icon(Icons.info, color: Colors.white54),
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }
}
