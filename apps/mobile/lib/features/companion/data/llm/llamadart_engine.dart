import 'dart:async';
import 'package:baby_mon/features/companion/data/llm/llm_inference_service.dart';
import 'package:llamadart/llamadart.dart' as llamadart;

/// Typed wrapper around the llamadart native API.
///
/// Centralises all llamadart interaction behind typed methods so that
/// [LlamadartEngine] never needs `as dynamic`.  On platforms where the
/// native library is not available, construction throws — callers should
/// handle that gracefully (typically by falling back to content-only mode).
class _LlamadartWrapper {
  final llamadart.LlamaEngine _engine;

  _LlamadartWrapper._(this._engine);

  /// Initialise the backend and load the GGUF model at [path].
  /// Throws if llamadart is unavailable on this platform.
  static Future<_LlamadartWrapper> create(String path) async {
    final backend = llamadart.LlamaBackend();
    final engine = llamadart.LlamaEngine(backend);
    await engine.loadModel(path);
    return _LlamadartWrapper._(engine);
  }

  /// Stream tokens from the loaded model for the given [prompt].
  Stream<String> generate(String prompt) => _engine.generate(prompt);

  /// Release native resources.
  Future<void> dispose() => _engine.dispose();
}

/// Real on-device LLM engine using llamadart / llama.cpp.
///
/// On platforms where llamadart is available (Android arm64, iOS arm64),
/// this engine loads a GGUF model and runs inference entirely on-device.
/// On unsupported platforms, it falls back to a streaming mock response.
class LlamadartEngine implements LlmEngine {
  bool _loaded = false;
  _LlamadartWrapper? _wrapper;

  LlamadartEngine();

  @override
  bool get isLoaded => _loaded;

  @override
  Future<void> loadModel(String path) async {
    try {
      // On first call, this initializes the llama.cpp backend and loads
      // the model file into memory (~2 GB RAM for a 3B model at Q4).
      _wrapper = await _LlamadartWrapper.create(path);
      _loaded = true;
    } catch (e) {
      // llamadart not available on this platform — engine stays unloaded.
      // The chat screen will show a "model not ready" state.
      _loaded = false;
      rethrow;
    }
  }

  @override
  Future<void> unload() async {
    try {
      await _wrapper?.dispose();
    } catch (_) {
      // dispose failed — engine will be garbage collected
    } finally {
      _wrapper = null;
      _loaded = false;
    }
  }

  @override
  Stream<String> generate(String prompt) async* {
    if (!_loaded || _wrapper == null) {
      yield 'The AI model is not available. '
          'Please download the model from the Companion tab to enable AI-powered advice. '
          'In the meantime, you can browse advice cards and routines.';
      return;
    }

    // Real inference via llamadart — streams tokens as they are generated
    try {
      final stream = _wrapper!.generate(prompt);
      await for (final token in stream) {
        yield token;
      }
    } catch (e) {
      yield '\n\n[Error during inference. Please try again.]';
      rethrow;
    }
  }
}
