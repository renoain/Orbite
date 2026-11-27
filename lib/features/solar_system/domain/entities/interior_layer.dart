import 'package:equatable/equatable.dart';

class InteriorLayer extends Equatable {
  const InteriorLayer({
    required this.layerName,
    required this.depthKm,
    required this.temperatureC,
    required this.composition,
    required this.description,
    required this.imageUrl,
    required this.funFact,
  });

  final String layerName;
  final String depthKm;
  final String temperatureC;
  final String composition;
  final String description;
  final String imageUrl;
  final String funFact;

  @override
  List<Object?> get props => [
        layerName,
        depthKm,
        temperatureC,
        composition,
        description,
        imageUrl,
        funFact,
      ];
}
