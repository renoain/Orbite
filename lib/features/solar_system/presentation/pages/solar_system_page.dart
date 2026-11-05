import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbite/features/solar_system/presentation/widgets/home_scene.dart';

class SolarSystemPage extends StatefulWidget {
  const SolarSystemPage({super.key});

  @override
  State<SolarSystemPage> createState() => _SolarSystemPageState();
}

class _SolarSystemPageState extends State<SolarSystemPage> {
  bool _isPlaying = true;
  bool _isFullscreen = false;
  bool _showHint = true;

  late final Timer _hintTimer;

  @override
  void initState() {
    super.initState();
    _hintTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hintTimer.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: HomeScene(isPlaying: _isPlaying)),
          if (_showHint)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Drag untuk orbit',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ),
          Positioned(
            bottom: 32,
            right: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'fullscreen',
                  onPressed: _toggleFullscreen,
                  child: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'playPause',
                  onPressed: _togglePlayPause,
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
