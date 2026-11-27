import 'package:orbite/features/solar_system/domain/entities/planet_detail.dart';

class PlanetDetailModel extends PlanetDetail {
  const PlanetDetailModel({
    required super.id,
    required super.name,
    required super.description,
    required super.atmosphere,
    required super.surfaceTemp,
    required super.funFact,
    super.imageUrl,
  });

  factory PlanetDetailModel.fromJson(Map<String, dynamic> json) {
    return PlanetDetailModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      atmosphere: json['atmosphere'] as String? ?? '',
      surfaceTemp: json['surface_temp'] as String? ?? '',
      funFact: json['fun_fact'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'atmosphere': atmosphere,
        'surface_temp': surfaceTemp,
        'fun_fact': funFact,
        'image_url': imageUrl,
      };
}
