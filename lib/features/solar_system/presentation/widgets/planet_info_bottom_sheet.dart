import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbite/core/constants/nasa_images.dart';
import 'package:orbite/core/widgets/nasa_image.dart';

class PlanetInfo {
  final String id;
  final String name;
  final String description;
  final String texture;
  final double distance;
  final int diameter;
  final double dayLength;
  final int orbitalPeriod;
  final int moons;
  final String funFact;

  PlanetInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.texture,
    required this.distance,
    required this.diameter,
    required this.dayLength,
    required this.orbitalPeriod,
    required this.moons,
    required this.funFact,
  });

  factory PlanetInfo.fromJson(Map<String, dynamic> json) {
    return PlanetInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      texture: json['texture'],
      distance: json['distance'].toDouble(),
      diameter: json['diameter'],
      dayLength: json['dayLength'].toDouble(),
      orbitalPeriod: json['orbitalPeriod'] ?? 0,
      moons: json['moons'] ?? 0,
      funFact: json['funFact'] ?? '',
    );
  }
}

class PlanetInfoBottomSheet extends StatefulWidget {
  final String planetId;
  final VoidCallback? onViewDetail;

  const PlanetInfoBottomSheet({
    super.key,
    required this.planetId,
    this.onViewDetail,
  });

  @override
  State<PlanetInfoBottomSheet> createState() => _PlanetInfoBottomSheetState();
}

class _PlanetInfoBottomSheetState extends State<PlanetInfoBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static Future<PlanetInfo?> loadPlanetInfo(String planetId) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/mock/planets.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final planetJson = jsonList.firstWhere(
        (p) => p['id'] == planetId,
        orElse: () => null,
      );
      if (planetJson != null) {
        return PlanetInfo.fromJson(planetJson);
      }
    } catch (e) {
      debugPrint('Error loading planet info: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlanetInfo?>(
      future: loadPlanetInfo(widget.planetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          );
        }

        final planet = snapshot.data;
        if (planet == null) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: const Text(
              'Planet tidak ditemukan',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: NasaImage(
                              url:
                                  NasaImages.planet[widget.planetId] ??
                                  NasaImages.planet['earth']!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  planet.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${planet.distance} juta km dari Matahari',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        planet.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _InfoChip(
                            icon: Icons.straighten,
                            label: '${planet.diameter} km',
                          ),
                          _InfoChip(
                            icon: Icons.access_time,
                            label: '${planet.dayLength} jam',
                          ),
                          _InfoChip(
                            icon: Icons.public,
                            label: '${planet.orbitalPeriod} hari',
                          ),
                          _InfoChip(
                            icon: Icons.brightness_3,
                            label: '${planet.moons} bulan',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (planet.funFact.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  planet.funFact,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: widget.onViewDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.open_in_new, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
