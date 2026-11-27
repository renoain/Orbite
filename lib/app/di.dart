import 'package:orbite/core/api/api_client.dart';
import 'package:orbite/features/solar_system/data/datasources/planet_remote_data_source.dart';
import 'package:orbite/features/solar_system/data/repositories/planet_repository_impl.dart';
import 'package:orbite/features/solar_system/domain/repositories/planet_repository.dart';
import 'package:orbite/features/solar_system/domain/usecases/get_interior_layers.dart';
import 'package:orbite/features/solar_system/domain/usecases/get_planet.dart';
import 'package:orbite/features/solar_system/domain/usecases/get_planets.dart';

class AppDependencies {
  const AppDependencies._();

  static final ApiClient apiClient = ApiClient();

  static final PlanetRepository planetRepository =
      PlanetRepositoryImpl(PlanetRemoteDataSource(apiClient));

  static final GetPlanets getPlanets = GetPlanets(planetRepository);
  static final GetPlanet getPlanet = GetPlanet(planetRepository);
  static final GetInteriorLayers getInteriorLayers =
      GetInteriorLayers(planetRepository);
}
