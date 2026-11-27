import 'package:equatable/equatable.dart';

class PlanetDetail extends Equatable {
  const PlanetDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.atmosphere,
    required this.surfaceTemp,
    required this.funFact,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final String description;
  final String atmosphere;
  final String surfaceTemp;
  final String funFact;
  final String imageUrl;

  @override
  List<Object?> get props =>
      [id, name, description, atmosphere, surfaceTemp, funFact, imageUrl];
}
