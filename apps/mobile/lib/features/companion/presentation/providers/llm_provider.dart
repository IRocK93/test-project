import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/llm/model_download_service.dart';
import '../../data/llm/model_manager.dart';
import '../../data/llm/device_capability_service.dart';
import '../../domain/models/model_download_state.dart';
import '../../../../core/providers.dart';

final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) {
  return ModelDownloadService(apiClient: ref.read(apiClientProvider));
});

final modelManagerProvider = FutureProvider<ModelManager>((ref) async => ModelManager.create());

final deviceCapabilityServiceProvider = Provider<DeviceCapabilityService>((ref) => DeviceCapabilityService());

/// Whether the current device is capable of running the on-device LLM.
final deviceCanRunLlmProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(deviceCapabilityServiceProvider);
  return service.canRunLLM();
});

class ModelDownloadNotifier extends StateNotifier<ModelDownloadState> {
  final ModelDownloadService _downloadService;
  final Ref _ref;
  StreamSubscription<ModelDownloadState>? _subscription;

  ModelDownloadNotifier({required ModelDownloadService downloadService, required Ref ref})
      : _downloadService = downloadService,
        _ref = ref,
        super(const ModelDownloadNotStarted());

  Future<void> startDownload({required String url, required String destinationPath, String? expectedSha256, required String version, bool registerOnComplete = true}) async {
    await cancelDownload();
    _subscription = _downloadService.download(url: url, destinationPath: destinationPath, expectedSha256: expectedSha256).listen((event) async {
      state = event;
      if (event is ModelDownloadComplete && registerOnComplete) {
        try {
          // Resolve ModelManager fresh — the FutureProvider is guaranteed
          // to have completed by the time a download finishes.
          final modelManager = await _ref.read(modelManagerProvider.future);
          final file = File(event.filePath);
          final sizeBytes = await file.exists() ? await file.length() : 0;
          await modelManager.addInstalledVersion(version: version, filePath: event.filePath, sha256: expectedSha256, sizeBytes: sizeBytes);
          debugPrint('[DOWNLOAD] Model registered: $version at ${event.filePath}');
        } catch (e) {
          debugPrint('[DOWNLOAD] Failed to register downloaded model: $e');
        }
      }
    }, onError: (Object error) {
      state = ModelDownloadError(message: error.toString());
      debugPrint('[DOWNLOAD] Error: $error');
    });
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
  return ModelDownloadNotifier(downloadService: downloadService, ref: ref);
});
