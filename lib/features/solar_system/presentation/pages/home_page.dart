import 'package:flutter/material.dart';
import 'package:orbite/core/widgets/floating_nav_bar.dart';
import 'package:orbite/features/home/presentation/pages/cosmic_explore.dart';
import 'package:orbite/features/learn/presentation/pages/learn_page.dart';
import 'package:orbite/features/trivia/presentation/pages/trivia_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const CosmicExplore(),
              LearnPage(isActive: _currentIndex == 1),
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
