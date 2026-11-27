import 'package:orbite/features/solar_system/domain/entities/interior_layer.dart';
import 'package:orbite/features/solar_system/domain/repositories/planet_repository.dart';

class GetInteriorLayers {
  const GetInteriorLayers(this._repository);

  final PlanetRepository _repository;

  Future<List<InteriorLayer>> call(String planetId) =>
      _repository.getInteriorLayers(planetId);
}
