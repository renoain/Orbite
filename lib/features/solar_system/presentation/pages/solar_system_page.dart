import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/features/solar_system/presentation/widgets/home_scene.dart';

String _formatSpeed(double value) {
  final text = value.toStringAsFixed(2);
  return '${text.replaceFirst(RegExp(r'\.?0+$'), '')}x';
}

class SolarSystemPage extends StatefulWidget {
  const SolarSystemPage({super.key});

  @override
  State<SolarSystemPage> createState() => _SolarSystemPageState();
}

class _SolarSystemPageState extends State<SolarSystemPage> {
  bool _isPlaying = true;
  bool _isFullscreen = false;
  bool _showHint = true;
  double _speed = 1.0;

  String get _speedLabel => _formatSpeed(_speed);

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

  void _setSpeed(double value) {
    if (!mounted) return;
    setState(() {
      _speed = value;
    });
  }

  Future<void> _showSpeedSheet() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final accent = AppColors.secondary;

            void update(double value) {
              _setSpeed(value);
              setSheetState(() {});
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kecepatan simulasi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perlambat atau percepat rotasi dan orbit planet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          _speedLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _speed == 1 ? null : () => update(1),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    Slider(
                      value: _speed,
                      min: 0.25,
                      max: 4,
                      divisions: 15,
                      label: _speedLabel,
                      activeColor: accent,
                      onChanged: update,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in const [0.5, 1.0, 2.0, 4.0])
                          ChoiceChip(
                            label: Text(_formatSpeed(preset)),
                            selected: (_speed - preset).abs() < 0.001,
                            onSelected: (_) => update(preset),
                            selectedColor: accent,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: (_speed - preset).abs() < 0.001
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            side: const BorderSide(color: Colors.white24),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: HomeScene(isPlaying: _isPlaying, speed: _speed),
          ),
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
                  heroTag: 'speed',
                  onPressed: _showSpeedSheet,
                  tooltip: 'Atur kecepatan',
                  child: Text(
                    _speedLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
