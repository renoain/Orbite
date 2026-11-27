import 'package:equatable/equatable.dart';

class PlanetDetail extends Equatable {
  const PlanetDetail({
    required this.id,
    required this.name,
    required this.nameId,
    required this.description,
    required this.atmosphere,
    required this.surfaceTemp,
    required this.funFact,
    required this.imageUrl,
    required this.textureUrl,
    this.distance,
    this.diameterKm,
    this.dayLengthHours,
    this.orbitalPeriodDays,
    this.moons,
    this.gravity,
  });

  final String id;
  final String name;
  final String nameId;
  final String description;
  final String atmosphere;
  final String surfaceTemp;
  final String funFact;
  final String imageUrl;
  final String textureUrl;
  final double? distance;
  final int? diameterKm;
  final double? dayLengthHours;
  final int? orbitalPeriodDays;
  final int? moons;
  final double? gravity;

  String get displayName => nameId.isNotEmpty ? nameId : name;

  @override
  List<Object?> get props => [
        id,
        name,
        nameId,
        description,
        atmosphere,
        surfaceTemp,
        funFact,
        imageUrl,
        textureUrl,
        distance,
        diameterKm,
        dayLengthHours,
        orbitalPeriodDays,
        moons,
        gravity,
      ];
}
