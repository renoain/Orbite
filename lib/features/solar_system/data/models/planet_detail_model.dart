import 'package:orbite/features/solar_system/domain/entities/planet_detail.dart';

class PlanetDetailModel extends PlanetDetail {
  const PlanetDetailModel({
    required super.id,
    required super.name,
    required super.nameId,
    required super.description,
    required super.atmosphere,
    required super.surfaceTemp,
    required super.funFact,
    required super.imageUrl,
    required super.textureUrl,
    super.distance,
    super.diameterKm,
    super.dayLengthHours,
    super.orbitalPeriodDays,
    super.moons,
    super.gravity,
  });

  factory PlanetDetailModel.fromJson(Map<String, dynamic> json) {
    return PlanetDetailModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameId: json['name_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      atmosphere: json['atmosphere'] as String? ?? '',
      surfaceTemp: json['surface_temp'] as String? ?? '',
      funFact: json['fun_fact'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      textureUrl: json['texture_url'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble(),
      diameterKm: (json['diameter_km'] as num?)?.toInt(),
      dayLengthHours: (json['day_length_hours'] as num?)?.toDouble(),
      orbitalPeriodDays: (json['orbital_period_days'] as num?)?.toInt(),
      moons: (json['moons'] as num?)?.toInt(),
      gravity: (json['gravity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_id': nameId,
        'description': description,
        'atmosphere': atmosphere,
        'surface_temp': surfaceTemp,
        'fun_fact': funFact,
        'image_url': imageUrl,
        'texture_url': textureUrl,
        'distance': distance,
        'diameter_km': diameterKm,
        'day_length_hours': dayLengthHours,
        'orbital_period_days': orbitalPeriodDays,
        'moons': moons,
        'gravity': gravity,
      };
}
