import 'package:orbite/features/solar_system/domain/entities/interior_layer.dart';
import 'package:orbite/features/solar_system/domain/entities/planet_detail.dart';
import 'package:orbite/features/solar_system/domain/entities/planet_summary.dart';

abstract class PlanetRepository {
  Future<List<PlanetSummary>> getPlanets();

  Future<PlanetDetail> getPlanet(String id);

  Future<List<InteriorLayer>> getInteriorLayers(String planetId);
}
