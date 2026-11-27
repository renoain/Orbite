import 'package:orbite/features/solar_system/domain/entities/interior_layer.dart';

class InteriorLayerModel extends InteriorLayer {
  const InteriorLayerModel({
    required super.layerName,
    required super.depthKm,
    required super.temperatureC,
    required super.composition,
    required super.description,
    required super.imageUrl,
    required super.funFact,
  });

  factory InteriorLayerModel.fromJson(Map<String, dynamic> json) {
    return InteriorLayerModel(
      layerName: json['layer_name'] as String? ?? '',
      depthKm: json['depth_km'] as String? ?? '',
      temperatureC: json['temperature_c'] as String? ?? '',
      composition: json['composition'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      funFact: json['fun_fact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'layer_name': layerName,
        'depth_km': depthKm,
        'temperature_c': temperatureC,
        'composition': composition,
        'description': description,
        'image_url': imageUrl,
        'fun_fact': funFact,
      };
}
