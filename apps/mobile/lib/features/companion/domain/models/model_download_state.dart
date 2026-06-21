import 'package:flutter/foundation.dart';

sealed class ModelDownloadState { const ModelDownloadState(); }

class ModelDownloadNotStarted extends ModelDownloadState { const ModelDownloadNotStarted(); }

@immutable
class ModelDownloadInProgress extends ModelDownloadState {
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  const ModelDownloadInProgress({required this.progress, required this.downloadedBytes, required this.totalBytes});
}

class ModelDownloadVerifying extends ModelDownloadState { const ModelDownloadVerifying(); }

@immutable
class ModelDownloadComplete extends ModelDownloadState {
  final String filePath;
  final String version;
  const ModelDownloadComplete({required this.filePath, required this.version});
}

@immutable
class ModelDownloadError extends ModelDownloadState {
  final String message;
  const ModelDownloadError({required this.message});
}
