import 'package:orbite/features/solar_system/data/datasources/planet_remote_data_source.dart';
import 'package:orbite/features/solar_system/domain/entities/interior_layer.dart';
import 'package:orbite/features/solar_system/domain/entities/planet_detail.dart';
import 'package:orbite/features/solar_system/domain/entities/planet_summary.dart';
import 'package:orbite/features/solar_system/domain/repositories/planet_repository.dart';

class PlanetRepositoryImpl implements PlanetRepository {
  const PlanetRepositoryImpl(this._remoteDataSource);

  final PlanetRemoteDataSource _remoteDataSource;

  @override
  Future<List<PlanetSummary>> getPlanets() => _remoteDataSource.getPlanets();

  @override
  Future<PlanetDetail> getPlanet(String id) => _remoteDataSource.getPlanet(id);

  @override
  Future<List<InteriorLayer>> getInteriorLayers(String planetId) =>
      _remoteDataSource.getInteriorLayers(planetId);
}
