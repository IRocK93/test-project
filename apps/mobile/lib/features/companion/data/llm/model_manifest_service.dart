import 'package:dio/dio.dart';

class ModelManifest {
  final String version;
  final String name;
  final int sizeBytes;
  final String sha256;
  final String url;
  final int minRamGB;
  final String changelog;
  final String? minimumRequired;
  final String? rollbackAdvised;

  const ModelManifest({
    required this.version,
    required this.name,
    required this.sizeBytes,
    required this.sha256,
    required this.url,
    required this.minRamGB,
    required this.changelog,
    this.minimumRequired,
    this.rollbackAdvised,
  });

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    final latest = json['latest'] as Map<String, dynamic>;
    return ModelManifest(
      version: latest['version'] as String,
      name: latest['name'] as String,
      sizeBytes: latest['sizeBytes'] as int,
      sha256: latest['sha256'] as String,
      url: latest['url'] as String,
      minRamGB: latest['minRamGB'] as int,
      changelog: latest['changelog'] as String,
      minimumRequired: json['minimumRequired'] as String?,
      rollbackAdvised: json['rollbackAdvised'] as String?,
    );
  }
}

class ModelManifestService {
  final Dio _dio;

  ModelManifestService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<ModelManifest> fetchManifest(String apiBaseUrl) async {
    final response = await _dio.get<Map<String, dynamic>>('$apiBaseUrl/models/companion-llm/manifest');
    return ModelManifest.fromJson(response.data as Map<String, dynamic>);
  }
}
