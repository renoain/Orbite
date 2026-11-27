import 'package:equatable/equatable.dart';

class PlanetSummary extends Equatable {
  const PlanetSummary({
    required this.id,
    required this.name,
    required this.nameId,
    required this.order,
    required this.description,
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
  final int order;
  final String description;
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
        order,
        description,
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
