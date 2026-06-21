import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/llm/model_download_service.dart';
import '../../data/llm/model_manager.dart';
import '../../data/llm/device_capability_service.dart';
import '../../domain/models/model_download_state.dart';

final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) => ModelDownloadService());

final modelManagerProvider = FutureProvider<ModelManager>((ref) async => ModelManager.create());

final deviceCapabilityServiceProvider = Provider<DeviceCapabilityService>((ref) => DeviceCapabilityService());

/// Whether the current device is capable of running the on-device LLM.
/// Falls back to `true` while the async check is in progress (optimistic).
final deviceCanRunLlmProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(deviceCapabilityServiceProvider);
  return service.canRunLLM();
});

class ModelDownloadNotifier extends StateNotifier<ModelDownloadState> {
  final ModelDownloadService _downloadService;
  final ModelManager? _modelManager;
  StreamSubscription<ModelDownloadState>? _subscription;

  ModelDownloadNotifier({required ModelDownloadService downloadService, required ModelManager? modelManager})
      : _downloadService = downloadService, _modelManager = modelManager, super(const ModelDownloadNotStarted());

  Future<void> startDownload({required String url, required String destinationPath, String? expectedSha256, required String version, bool registerOnComplete = true}) async {
    await cancelDownload();
    _subscription = _downloadService.download(url: url, destinationPath: destinationPath, expectedSha256: expectedSha256).listen((event) async {
      state = event;
      if (event is ModelDownloadComplete && registerOnComplete && _modelManager != null) {
        try {
          final file = File(event.filePath);
          final sizeBytes = await file.exists() ? await file.length() : 0;
          await _modelManager!.addInstalledVersion(version: version, filePath: event.filePath, sha256: expectedSha256, sizeBytes: sizeBytes);
        } catch (e) { debugPrint('Failed to register downloaded model: $e'); }
      }
    }, onError: (Object error) { state = ModelDownloadError(message: error.toString()); });
  }

  Future<void> cancelDownload() async {
    await _subscription?.cancel();
    _subscription = null;
    _downloadService.cancel();
  }

  void reset() => state = const ModelDownloadNotStarted();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final modelDownloadStateProvider = StateNotifierProvider<ModelDownloadNotifier, ModelDownloadState>((ref) {
  final downloadService = ref.watch(modelDownloadServiceProvider);
  final modelManagerAsync = ref.watch(modelManagerProvider);
  // ModelManager may not have resolved yet on first read — that's OK,
  // the notifier handles a null modelManager gracefully (version
  // registration is skipped until it becomes available).
  final modelManager = modelManagerAsync.valueOrNull;
  return ModelDownloadNotifier(downloadService: downloadService, modelManager: modelManager);
});
