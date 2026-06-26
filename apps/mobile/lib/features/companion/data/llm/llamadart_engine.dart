import 'dart:async';
import 'package:llamadart/llamadart.dart' as llamadart;

/// Real on-device LLM engine using llamadart v0.8.x.
class LlamadartEngine {
  bool _loaded = false;
  llamadart.LlamaEngine? _engine;
  llamadart.LlamaBackend? _backend;
  llamadart.ChatSession? _session;
  Future<void>? _pendingUnload;

  LlamadartEngine();

  bool get isLoaded => _loaded;

  Future<void> loadModel(String path) async {
    // Wait for any in-flight unload to complete before initializing
    await _pendingUnload;
    try {
      _backend = llamadart.LlamaBackend();
      _engine = llamadart.LlamaEngine(_backend!);
      await _engine!.loadModel(path);
      _loaded = true;
    } catch (e) {
      _loaded = false;
      rethrow;
    }
  }

  Future<void> unload() async {
    if (_engine == null) {
      _loaded = false;
      return;
    }
    _pendingUnload = _doUnload();
    await _pendingUnload;
    _pendingUnload = null;
  }

  Future<void> _doUnload() async {
    try {
      await _engine?.dispose();
    } catch (_) {} finally {
      _engine = null;
      _backend = null;
      _session = null;
      _loaded = false;
    }
  }

  /// Creates a new chat session with the given system prompt.
  void startSession(String systemPrompt) {
    _session = llamadart.ChatSession(
      _engine!,
      systemPrompt: systemPrompt,
    );
  }

  /// Updates the system prompt without clearing conversation history.
  void updateSystemPrompt(String systemPrompt) {
    _session?.systemPrompt = systemPrompt;
  }

  /// Sends a user message and streams the response tokens.
  Stream<String> sendMessage(String userMessage) async* {
    if (!_loaded || _engine == null) {
      yield 'Model not loaded.';
      return;
    }

    // Create session if not yet created
    _session ??= llamadart.ChatSession(_engine!);

    try {
      final stream = _session!.create([
        llamadart.LlamaTextContent(userMessage),
      ]);

      await for (final chunk in stream) {
        if (chunk.choices.isNotEmpty) {
          final content = chunk.choices.first.delta.content;
          if (content != null) {
            yield content;
          }
        }
      }
    } catch (e) {
      yield '\n\n[Error generating response. Please try again.]';
      rethrow;
    }
  }

  /// Clears the current chat session.
  void resetSession({bool keepSystemPrompt = true}) {
    _session?.reset(keepSystemPrompt: keepSystemPrompt);
  }
}
