import 'package:orbite/features/solar_system/domain/entities/planet_summary.dart';

class PlanetSummaryModel extends PlanetSummary {
  const PlanetSummaryModel({
    required super.id,
    required super.name,
    required super.order,
    required super.description,
    required super.funFact,
    required super.imageUrl,
  });

  factory PlanetSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlanetSummaryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      funFact: json['fun_fact'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order': order,
        'description': description,
        'fun_fact': funFact,
        'image_url': imageUrl,
      };
}
