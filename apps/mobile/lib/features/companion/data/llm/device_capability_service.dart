import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Result of a device capability check for running an on-device LLM.
class DeviceCapability {
  final bool canRunLLM;
  final String? reason; // Human-readable explanation if canRunLLM is false
  final int? availableRamMB;
  final int? requiredRamMB;
  final int? availableStorageMB;
  final int? requiredStorageMB;
  final bool is64Bit;
  final String platform;

  const DeviceCapability({
    required this.canRunLLM,
    this.reason,
    this.availableRamMB,
    this.requiredRamMB,
    this.availableStorageMB,
    this.requiredStorageMB,
    required this.is64Bit,
    required this.platform,
  });

  /// A known-good capability indicating the device can run the LLM.
  factory DeviceCapability.ok(String platform) => DeviceCapability(
        canRunLLM: true,
        is64Bit: true,
        platform: platform,
      );
}

/// Checks whether the current device can run the on-device LLM.
///
/// The LLM (Gemma 4 E2B at INT4 quantization) requires:
/// - 64-bit CPU architecture (arm64-v8a / aarch64)
/// - Approximately 4 GB of total RAM (3+ GB free recommended)
/// - Approximately 2.5 GB of free storage for model download and extraction
///
/// On devices that do not meet these requirements, the app will offer a
/// content-only fallback mode powered by keyword-matched parenting advice cards.
class DeviceCapabilityService {
  final DeviceInfoPlugin _deviceInfo;

  DeviceCapabilityService({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  /// Minimum RAM (MB) required to load and run the LLM.
  static const int requiredRamMB = 4096;

  /// Recommended free storage (MB) for model download + workspace.
  /// SmolLM2 is ~271 MB; 1 GB gives comfortable headroom.
  static const int requiredStorageMB = 1024;

  /// Performs a full capability check.
  ///
  /// Returns [DeviceCapability.ok] if the device meets all requirements,
  /// or a detailed [DeviceCapability] with the reason for failure.
  Future<DeviceCapability> checkCapability() async {
    // ── Architecture check ────────────────────────────────────────
    // llamadart / llama.cpp requires 64-bit ARM (or x86-64 on desktop).
    // All modern iOS devices (iPhone 5s+) and Android devices (API 21+)
    // are 64-bit, but we verify explicitly.
    final is64Bit = !Platform.isAndroid || await _isAndroid64Bit();
    if (!is64Bit) {
      return DeviceCapability(
        canRunLLM: false,
        reason: 'Your device uses a 32-bit processor. The AI model requires a 64-bit processor.',
        is64Bit: false,
        platform: _platformName,
      );
    }

    // ── RAM check ─────────────────────────────────────────────────
    final ramMB = await _getTotalRamMB();
    if (ramMB != null && ramMB < requiredRamMB) {
      return DeviceCapability(
        canRunLLM: false,
        reason: 'Your device has ${ramMB}MB of RAM. The AI model needs at least ${requiredRamMB}MB. '
            'You can still use the Companion with parenting content cards.',
        availableRamMB: ramMB,
        requiredRamMB: requiredRamMB,
        is64Bit: true,
        platform: _platformName,
      );
    }

    // ── Storage check ─────────────────────────────────────────────
    try {
      final storageMB = await _getFreeStorageMB();
      if (storageMB != null && storageMB < requiredStorageMB) {
        return DeviceCapability(
          canRunLLM: false,
          reason: 'Your device has only ${storageMB}MB of free storage. '
              'The AI model needs ~${requiredStorageMB}MB. '
              'Free up space or use the Companion with content cards instead.',
          availableStorageMB: storageMB,
          requiredStorageMB: requiredStorageMB,
          is64Bit: true,
          platform: _platformName,
        );
      }
    } catch (_) {
      // Storage check is best-effort; proceed if we can't determine.
    }

    return DeviceCapability.ok(_platformName);
  }

  /// Quick check suitable for synchronous UI decisions.
  /// Falls back to optimistic true when the async check hasn't completed.
  Future<bool> canRunLLM() async {
    final cap = await checkCapability();
    return cap.canRunLLM;
  }

  // ─── Platform-specific helpers ──────────────────────────────────

  String get _platformName {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'desktop';
  }

  /// Checks whether the Android device has a 64-bit CPU.
  /// All Android devices running API 21+ on arm64-v8a are 64-bit.
  /// This reads the CPU ABI list from the system.
  Future<bool> _isAndroid64Bit() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final supportedAbis = androidInfo.supportedAbis;
      return supportedAbis.any((abi) => abi.contains('arm64') || abi.contains('aarch64') || abi.contains('x86_64'));
    } catch (_) {
      // If we can't determine, assume 64-bit (most devices since 2015 are).
      return true;
    }
  }

  /// Estimates total device RAM in MB.
  /// On Android: reads /proc/meminfo for MemTotal.
  /// On iOS: device_info_plus doesn't expose RAM directly, so we estimate
  /// based on device model heuristics (iPhone 12+ = 4GB+, iPhone XR/XS = 3GB).
  Future<int?> _getTotalRamMB() async {
    try {
      if (Platform.isAndroid) {
        final memInfo = await File('/proc/meminfo').readAsString();
        final match = RegExp(r'MemTotal:\s+(\d+)\s+kB').firstMatch(memInfo);
        if (match != null) {
          final kb = int.parse(match.group(1)!);
          return (kb / 1024).round();
        }
      }
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final model = iosInfo.model;
        // Heuristic RAM estimates based on device model identifiers.
        // iPhone 12+ have 4GB+; earlier models may have 3GB or less.
        if (model.contains('iPhone13') || // iPhone 12 series
            model.contains('iPhone14') || // iPhone 13 series
            model.contains('iPhone15') || // iPhone 14 series
            model.contains('iPhone16') || // iPhone 15 series
            model.contains('iPhone17')) {
          // iPhone 16/17 series
          return 8192; // iPhone 15 Pro+ / 16 have 8GB
        }
        return 4096; // Conservative: most supported iPhones have >=4GB
      }
    } catch (_) {
      // Best-effort; return null if we cannot determine.
    }
    return null;
  }

  /// Estimates free storage in MB on the device's primary storage.
  Future<int?> _getFreeStorageMB() async {
    try {
      // Use the application documents directory as a proxy for the
      // primary storage volume.
      final tmpDir = Directory.systemTemp;
      // dart:io doesn't directly provide free space.
      // On mobile, we use a command-line approach as a fallback.
      if (Platform.isAndroid || Platform.isLinux) {
        final result = await Process.run('df', ['-m', tmpDir.path]);
        if (result.exitCode == 0) {
          final lines = (result.stdout as String).split('\n');
          if (lines.length >= 2) {
            final parts = lines[1].split(RegExp(r'\s+'));
            // df -m output: Filesystem 1M-blocks Used Available Use% Mounted
            if (parts.length >= 4) {
              return int.tryParse(parts[3]); // Available column
            }
          }
        }
      }
    } catch (_) {
      // Best-effort; return null if we cannot determine.
    }
    return null;
  }
}
