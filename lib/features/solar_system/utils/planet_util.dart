import 'dart:math' as math;

import 'package:orbite/features/solar_system/domain/entities/base_mesh.dart';
import 'package:orbite/features/solar_system/domain/entities/planet.dart';
import 'package:orbite/features/solar_system/params/create_planet_params.dart';
import 'package:orbite/features/solar_system/params/planet_ring_params.dart';
import 'package:orbite/features/solar_system/res/assets/textures.dart';
import 'package:three_dart/three_dart.dart' as three;

const int _sphereSegments = 30;
const int _ringSegments = 32;
const double _ringRotation = -0.5 * math.pi;
const double _sunSpin = 0.1;

class PlanetUtil {
  factory PlanetUtil() {
    return _instance;
  }
  PlanetUtil._();

  static final PlanetUtil _instance = PlanetUtil._();
  static PlanetUtil get instance => _instance;
  Future<Planet> initializePlanet(three.Scene scene) async {
    return Planet(
      mecury: await _createPlanet(
        CreatePlanetParams(size: 3.2, texture: textureMecury, position: 28),
        scene,
      ),
      venus: await _createPlanet(
        CreatePlanetParams(size: 5.8, texture: textureVenus, position: 44),
        scene,
      ),
      saturn: await _createPlanet(
        CreatePlanetParams(
          size: 10,
          texture: textureSaturn,
          position: 138,
          planetRingParams: const PlanetRingParams(
            innerRadius: 10,
            outerRadius: 20,
            texture: textureSaturnRing,
          ),
        ),
        scene,
      ),
      earth: await _createPlanet(
        CreatePlanetParams(size: 6, texture: textureEarth, position: 62),
        scene,
      ),
      jupiter: await _createPlanet(
        CreatePlanetParams(size: 12, texture: textureJupiter, position: 100),
        scene,
      ),
      mars: await _createPlanet(
        CreatePlanetParams(size: 4, texture: textureMars, position: 78),
        scene,
      ),
      uranus: await _createPlanet(
        CreatePlanetParams(
          size: 7,
          texture: textureUranus,
          position: 176,
          planetRingParams: const PlanetRingParams(
            innerRadius: 7,
            outerRadius: 12,
            texture: textureUranus,
          ),
        ),
        scene,
      ),
      neptune: await _createPlanet(
        CreatePlanetParams(size: 7, texture: textureNeptune, position: 200),
        scene,
      ),
      pluto: await _createPlanet(
        CreatePlanetParams(size: 2.8, texture: texturePluto, position: 216),
        scene,
      ),
    );
  }

  Future<BaseMesh> _createPlanet(
    CreatePlanetParams createPlanetParams,
    three.Scene scene,
  ) async {
    final geo = three.SphereGeometry(
      createPlanetParams.size,
      _sphereSegments,
      _sphereSegments,
    );
    final mecuryTextureLoader = three.TextureLoader(null);
    final mat = three.MeshStandardMaterial({
      'map': await mecuryTextureLoader.loadAsync(createPlanetParams.texture),
    });
    final mesh = three.Mesh(geo, mat);
    final object3d = three.Object3D()..add(mesh);
    if (createPlanetParams.planetRingParams != null) {
      final ring = createPlanetParams.planetRingParams;
      final ringGeo = three.RingGeometry(
        ring!.innerRadius,
        ring.outerRadius,
        _ringSegments,
      );
      final ringTextureLoader = three.TextureLoader(null);
      final ringMat = three.MeshBasicMaterial({
        'map': await ringTextureLoader.loadAsync(ring.texture),
        'side': three.DoubleSide,
      });
      final ringMesh = three.Mesh(ringGeo, ringMat);
      object3d.add(ringMesh);
      ringMesh.position.x = createPlanetParams.position;
      ringMesh.rotation.x = _ringRotation;
    }
    scene.add(object3d);
    mesh.position.x = createPlanetParams.position;
    return BaseMesh(mesh: mesh, object3d: object3d);
  }

  void step({
    required Planet planet,
    required three.Mesh sun,
    required double deltaSeconds,
  }) {
    sun.rotateY(_sunSpin * deltaSeconds);
    planet.mecury?.rotateMesh(0.1 * deltaSeconds);
    planet.venus?.rotateMesh(0.05 * deltaSeconds);
    planet.earth?.rotateMesh(0.5 * deltaSeconds);
    planet.mars?.rotateMesh(0.45 * deltaSeconds);
    planet.jupiter?.rotateMesh(1.0 * deltaSeconds);
    planet.saturn?.rotateMesh(0.95 * deltaSeconds);
    planet.uranus?.rotateMesh(0.75 * deltaSeconds);
    planet.neptune?.rotateMesh(0.8 * deltaSeconds);
    planet.pluto?.rotateMesh(0.2 * deltaSeconds);

    ///
    planet.mecury?.rotateObject3D(1.0 * deltaSeconds);
    planet.venus?.rotateObject3D(0.375 * deltaSeconds);
    planet.earth?.rotateObject3D(0.25 * deltaSeconds);
    planet.mars?.rotateObject3D(0.2 * deltaSeconds);
    planet.jupiter?.rotateObject3D(0.05 * deltaSeconds);
    planet.saturn?.rotateObject3D(0.0225 * deltaSeconds);
    planet.uranus?.rotateObject3D(0.01 * deltaSeconds);
    planet.neptune?.rotateObject3D(0.0025 * deltaSeconds);
    planet.pluto?.rotateObject3D(0.00175 * deltaSeconds);
  }
}
