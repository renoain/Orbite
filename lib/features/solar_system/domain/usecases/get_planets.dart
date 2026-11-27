import 'package:orbite/features/solar_system/domain/entities/planet_summary.dart';
import 'package:orbite/features/solar_system/domain/repositories/planet_repository.dart';

class GetPlanets {
  const GetPlanets(this._repository);

  final PlanetRepository _repository;

  Future<List<PlanetSummary>> call() => _repository.getPlanets();
}
