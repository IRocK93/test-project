import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../domain/models/model_download_state.dart';
import '../../../../core/utils/error_handler.dart';

class ModelDownloadService {
  final Dio _dio;
  CancelToken? _cancelToken;

  ModelDownloadService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(hours: 2),
          followRedirects: true,
          maxRedirects: 10,
        ));

  Stream<ModelDownloadState> download({
    required String url,
    required String destinationPath,
    String? expectedSha256,
  }) {
    _cancelToken = CancelToken();
    final controller = StreamController<ModelDownloadState>();
    _performDownload(
      url: url,
      destinationPath: destinationPath,
      expectedSha256: expectedSha256,
      controller: controller,
    );
    return controller.stream;
  }

  void cancel() => _cancelToken?.cancel();

  Future<void> _performDownload({
    required String url,
    required String destinationPath,
    required String? expectedSha256,
    required StreamController<ModelDownloadState> controller,
  }) async {
    try {
      final hasConnectivity = await _checkConnectivity(url);
      if (!hasConnectivity) {
        controller.add(const ModelDownloadError(message: 'Unable to reach the model server. Please check your internet connection and try again.'));
        await controller.close();
        return;
      }

      final file = File(destinationPath);
      final partialFile = File('$destinationPath.partial');
      final directory = file.parent;
      if (!await directory.exists()) await directory.create(recursive: true);

      final existingSize = partialFile.existsSync() ? await partialFile.length() : 0;
      final totalSize = await _getContentLength(url);
      if (totalSize == null || totalSize <= 0) {
        controller.add(const ModelDownloadError(message: 'Could not determine file size from server.'));
        await controller.close();
        return;
      }

      if (existingSize >= totalSize) {
        if (partialFile.existsSync() && !file.existsSync()) await partialFile.rename(destinationPath);
        controller.add(const ModelDownloadVerifying());
        final verified = await _verifySha256(file, expectedSha256);
        if (!verified) {
          await file.delete();
          controller.add(const ModelDownloadError(message: 'Downloaded file failed integrity verification. Please try downloading again.'));
        } else {
          controller.add(ModelDownloadComplete(filePath: destinationPath, version: _extractVersionFromUrl(url)));
        }
        await controller.close();
        return;
      }

      final headers = <String, String>{if (existingSize > 0) 'Range': 'bytes=$existingSize-'};
      final response = await _dio.get<ResponseBody>(url,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(hours: 2),
          sendTimeout: const Duration(seconds: 30),
        ),
        cancelToken: _cancelToken,
      );
      if (response.statusCode != 200 && response.statusCode != 206) {
        controller.add(ModelDownloadError(message: 'Server returned unexpected status: ${response.statusCode}.'));
        await controller.close();
        return;
      }

      final isResume = response.statusCode == 206;
      if (existingSize > 0 && !isResume) {
        if (partialFile.existsSync()) await partialFile.delete();
      }

      final responseBody = response.data;
      if (responseBody == null) {
        controller.add(const ModelDownloadError(message: 'Empty response body from server.'));
        await controller.close();
        return;
      }

      final contentLengthHeader = response.headers.value('content-length');
      final rangeContentLength = contentLengthHeader != null ? int.tryParse(contentLengthHeader) : null;
      final effectiveTotal = isResume && rangeContentLength != null ? existingSize + rangeContentLength : totalSize;

      final raf = await partialFile.open(mode: isResume ? FileMode.append : FileMode.write);
      int downloadedInSession = 0;
      final baseOffset = isResume ? existingSize : 0;

      try {
        final stream = responseBody.stream as Stream<List<int>>;
        await for (final chunk in stream) {
          if (_cancelToken != null && _cancelToken!.isCancelled) {
            await raf.close();
            controller.add(const ModelDownloadError(message: 'Download cancelled.'));
            await controller.close();
            return;
          }
          await raf.writeFrom(chunk);
          downloadedInSession += chunk.length;
          final absoluteDownloaded = baseOffset + downloadedInSession;
          final progress = effectiveTotal > 0 ? (absoluteDownloaded / effectiveTotal).clamp(0.0, 1.0) : 0.0;
          controller.add(ModelDownloadInProgress(progress: progress, downloadedBytes: absoluteDownloaded, totalBytes: effectiveTotal));
        }
      } finally {
        await raf.close();
      }

      if (file.existsSync()) await file.delete();
      await partialFile.rename(destinationPath);

      controller.add(const ModelDownloadVerifying());
      final verified = await _verifySha256(file, expectedSha256);
      if (!verified) {
        await file.delete();
        controller.add(const ModelDownloadError(message: 'Downloaded file failed integrity verification. Please try downloading again.'));
      } else {
        controller.add(ModelDownloadComplete(filePath: destinationPath, version: _extractVersionFromUrl(url)));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        controller.add(const ModelDownloadError(message: 'Download cancelled.'));
      } else {
        controller.add(ModelDownloadError(message: extractErrorMessage(e)));
      }
    } catch (e) {
      controller.add(ModelDownloadError(message: extractErrorMessage(e)));
    } finally {
      if (!controller.isClosed) await controller.close();
    }
  }

  Future<bool> _checkConnectivity(String url) async {
    try {
      final response = await _dio.head<Response>(url, options: Options(receiveTimeout: const Duration(seconds: 10)));
      final statusCode = response.statusCode;
      return statusCode != null && statusCode >= 200 && statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<int?> _getContentLength(String url) async {
    try {
      final response = await _dio.head<Response>(url);
      final length = response.headers.value('content-length');
      return length != null ? int.tryParse(length) : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _verifySha256(File file, String? expectedSha256) async {
    if (expectedSha256 == null) return true;
    try {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString() == expectedSha256.toLowerCase();
    } catch (_) {
      return false;
    }
  }

  String _extractVersionFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return 'unknown';
    final segments = uri.pathSegments;
    if (segments.isEmpty) return 'unknown';
    final last = segments.last;
    final dotIndex = last.lastIndexOf('.');
    return dotIndex > 0 ? last.substring(0, dotIndex) : last;
  }
}
