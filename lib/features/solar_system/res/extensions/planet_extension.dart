import 'package:orbite/features/solar_system/domain/entities/planet.dart';
import 'package:orbite/features/solar_system/utils/planet_util.dart';
import 'package:three_dart/three_dart.dart' as three;

extension PlanetExtension on Planet {
  Future<Planet> initializePlanets(three.Scene scene) async =>
      PlanetUtil.instance.initializePlanet(scene);
  void step({
    required Planet planet,
    required three.Mesh sun,
    required double deltaSeconds,
  }) => PlanetUtil.instance.step(
    planet: planet,
    sun: sun,
    deltaSeconds: deltaSeconds,
  );
}
