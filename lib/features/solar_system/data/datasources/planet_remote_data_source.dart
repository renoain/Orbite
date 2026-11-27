import 'package:orbite/core/api/api_client.dart';
import 'package:orbite/core/error/app_failure.dart';
import 'package:orbite/features/solar_system/data/models/interior_layer_model.dart';
import 'package:orbite/features/solar_system/data/models/planet_detail_model.dart';
import 'package:orbite/features/solar_system/data/models/planet_summary_model.dart';

class PlanetRemoteDataSource {
  const PlanetRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<PlanetSummaryModel>> getPlanets() async {
    final response = await _client.get('/planets');
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PlanetSummaryModel.fromJson)
        .toList();
  }

  Future<PlanetDetailModel> getPlanet(String id) async {
    final response = await _client.get('/planets/$id');
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const AppFailure(
        'Detail planet tidak ditemukan.',
        kind: FailureKind.notFound,
      );
    }
    return PlanetDetailModel.fromJson(data);
  }

  Future<List<InteriorLayerModel>> getInteriorLayers(String planetId) async {
    final response = await _client.get('/planets/$planetId/layers');
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(InteriorLayerModel.fromJson)
        .toList();
  }
}
