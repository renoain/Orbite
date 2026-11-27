import 'package:equatable/equatable.dart';

class PlanetSummary extends Equatable {
  const PlanetSummary({
    required this.id,
    required this.name,
    required this.order,
    required this.description,
    required this.funFact,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int order;
  final String description;
  final String funFact;
  final String imageUrl;

  @override
  List<Object?> get props => [id, name, order, description, funFact, imageUrl];
}
