import 'package:orbite/features/solar_system/domain/entities/planet_detail.dart';
import 'package:orbite/features/solar_system/domain/repositories/planet_repository.dart';

class GetPlanet {
  const GetPlanet(this._repository);

  final PlanetRepository _repository;

  Future<PlanetDetail> call(String id) => _repository.getPlanet(id);
}
