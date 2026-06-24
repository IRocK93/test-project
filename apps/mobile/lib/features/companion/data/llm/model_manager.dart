import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

@immutable
class ModelRegistryEntry {
  final String version;
  final String filePath;
  final String? sha256;
  final int sizeBytes;
  final DateTime installedAt;

  const ModelRegistryEntry({required this.version, required this.filePath, this.sha256, required this.sizeBytes, required this.installedAt});

  Map<String, dynamic> toJson() => {'version': version, 'filePath': filePath, if (sha256 != null) 'sha256': sha256, 'sizeBytes': sizeBytes, 'installedAt': installedAt.toIso8601String()};

  factory ModelRegistryEntry.fromJson(Map<String, dynamic> json) {
    return ModelRegistryEntry(version: json['version'] as String, filePath: json['filePath'] as String, sha256: json['sha256'] as String?, sizeBytes: json['sizeBytes'] as int, installedAt: DateTime.parse(json['installedAt'] as String));
  }
}

class ModelManager {
  static const String _registryFileName = 'registry.json';
  static const String _defaultModelsSubDir = 'models';

  final String baseDirectory;
  final String _registryPath;

  ModelManager({required this.baseDirectory}) : _registryPath = '$baseDirectory/$_registryFileName';

  static Future<ModelManager> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final baseDir = '${docsDir.path}/$_defaultModelsSubDir';
    final dir = Directory(baseDir);
    if (!await dir.exists()) await dir.create(recursive: true);
    return ModelManager(baseDirectory: baseDir);
  }

  Future<bool> modelFileExists(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return false;
    try { return await file.length() > 0; } catch (_) { return false; }
  }

  Future<bool> validateModelFile(String filePath) async => modelFileExists(filePath);

  Future<Map<String, dynamic>> _readRegistry() async {
    final file = File(_registryPath);
    if (!await file.exists()) return <String, dynamic>{'activeVersion': null, 'fallbackVersion': null, 'installedVersions': <Map<String, dynamic>>[]};
    try {
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) throw const FormatException('Empty');
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{'activeVersion': null, 'fallbackVersion': null, 'installedVersions': <Map<String, dynamic>>[]};
    }
  }

  Future<void> _writeRegistry(Map<String, dynamic> data) async {
    final file = File(_registryPath);
    final dir = file.parent;
    if (!await dir.exists()) await dir.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<String?> getActiveModelPath() async {
    final registry = await _readRegistry();
    final activeVersion = registry['activeVersion'] as String?;
    if (activeVersion == null) return null;
    final installed = await getInstalledVersions();
    for (final entry in installed) {
      if (entry.version == activeVersion) {
        if (await modelFileExists(entry.filePath)) return entry.filePath;
        return null;
      }
    }
    return null;
  }

  Future<void> setActiveVersion(String? version) async {
    final registry = await _readRegistry();
    if (version != null) {
      final installed = registry['installedVersions'] as List<dynamic>? ?? [];
      final found = installed.any((entry) => entry is Map && entry['version'] == version);
      if (!found) throw ArgumentError('Version "$version" is not installed. Call addInstalledVersion() first.');
    }
    registry['activeVersion'] = version;
    await _writeRegistry(registry);
  }

  Future<String?> getFallbackModelPath() async {
    final registry = await _readRegistry();
    final fallbackVersion = registry['fallbackVersion'] as String?;
    if (fallbackVersion == null) return null;
    final installed = await getInstalledVersions();
    for (final entry in installed) {
      if (entry.version == fallbackVersion && await modelFileExists(entry.filePath)) return entry.filePath;
    }
    return null;
  }

  Future<void> setFallbackVersion(String version) async {
    final registry = await _readRegistry();
    final installed = registry['installedVersions'] as List<dynamic>? ?? [];
    final found = installed.any((entry) => entry is Map && entry['version'] == version);
    if (!found) throw ArgumentError('Version "$version" is not installed.');
    registry['fallbackVersion'] = version;
    await _writeRegistry(registry);
  }

  Future<List<ModelRegistryEntry>> getInstalledVersions() async {
    final registry = await _readRegistry();
    final rawList = registry['installedVersions'] as List<dynamic>? ?? <dynamic>[];
    return rawList.whereType<Map>().map((json) => ModelRegistryEntry.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<void> addInstalledVersion({required String version, required String filePath, String? sha256, required int sizeBytes}) async {
    final registry = await _readRegistry();
    final installed = registry['installedVersions'] as List<dynamic>? ?? <dynamic>[];
    installed.removeWhere((entry) => entry is Map && entry['version'] == version);
    installed.add(ModelRegistryEntry(version: version, filePath: filePath, sha256: sha256, sizeBytes: sizeBytes, installedAt: DateTime.now()).toJson());
    registry['installedVersions'] = installed;
    if (installed.length == 1) registry['activeVersion'] = version;
    await _writeRegistry(registry);
  }

  Future<void> removeVersion(String version) async {
    final registry = await _readRegistry();
    final installed = registry['installedVersions'] as List<dynamic>? ?? <dynamic>[];
    Map<String, dynamic>? targetEntry;
    for (final entry in installed) {
      if (entry is Map && entry['version'] == version) { targetEntry = Map<String, dynamic>.from(entry); break; }
    }
    installed.removeWhere((entry) => entry is Map && entry['version'] == version);
    registry['installedVersions'] = installed;
    if (registry['activeVersion'] == version) registry['activeVersion'] = null;
    if (registry['fallbackVersion'] == version) registry['fallbackVersion'] = null;
    await _writeRegistry(registry);
    if (targetEntry != null) {
      final filePath = targetEntry['filePath'] as String?;
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) await file.delete();
        final partialFile = File('$filePath.partial');
        if (await partialFile.exists()) await partialFile.delete();
      }
    }
  }

  // ─── Model Update Checking ─────────────────────────────────────

  /// Checks whether a newer model version is available compared to the
  /// currently active installed version.
  ///
  /// Returns null if no update is needed, or the [manifestVersion] if it
  /// is newer than the installed version.
  Future<String?> checkForUpdate(String manifestVersion) async {
    final activeVersion = await getActiveVersion();
    if (activeVersion == null) return null; // No model installed — first download, not an update
    if (activeVersion == manifestVersion) return null; // Same version
    // Future: implement semver comparison. For now, simple string inequality
    // signals an update (versions are monotonically increasing tags).
    return manifestVersion;
  }

  /// Gets the currently active version string, or null if no model is installed.
  Future<String?> getActiveVersion() async {
    final registry = await _readRegistry();
    return registry['activeVersion'] as String?;
  }

  /// Stores the last seen manifest version so we can detect when a newer
  /// model is available without fetching the manifest on every launch.
  Future<String?> getLastKnownManifestVersion() async {
    final registry = await _readRegistry();
    return registry['lastKnownManifestVersion'] as String?;
  }

  Future<void> setLastKnownManifestVersion(String version) async {
    final registry = await _readRegistry();
    registry['lastKnownManifestVersion'] = version;
    await _writeRegistry(registry);
  }
}
