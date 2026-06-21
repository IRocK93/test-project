// BabyMon App Icon Generator
//
// Generates app icons at all required Android mipmap densities and iOS sizes.
// Run with: dart run tool/generate_icons.dart
//
// Requires the `image` package. Install with: dart pub add image

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Output directory for generated icons
const outputDir = 'tool/generated_icons';

/// Icon sizes for Android mipmap densities
const androidSizes = {
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};

/// Icon sizes for iOS AppIcon.appiconset (iPhone)
const iosSizes = {
  'Icon-20@2x': 40,
  'Icon-20@3x': 60,
  'Icon-29@2x': 58,
  'Icon-29@3x': 87,
  'Icon-40@2x': 80,
  'Icon-40@3x': 120,
  'Icon-60@2x': 120,
  'Icon-60@3x': 180,
  'Icon-76@2x': 152,
  'Icon-83.5@2x': 167,
  'Icon-1024': 1024, // App Store
};

/// BabyMon brand colors
const primaryColor = 0xFF1A1A2E;     // Deep navy
const accentColor = 0xFF6C63FF;      // Soft purple accent
const backgroundColor = 0xFFF8F6FF;  // Light lavender background

/// Draw the BabyMon app icon
///
/// The icon consists of:
/// - A rounded rectangle background with gradient
/// - A simplified baby/parent icon silhouette (geometric)
/// - The wordmark "BM" in bold
img.Image drawBabyMonIcon(int size) {
  final image = img.Image(width: size, height: size);

  // Background: soft gradient from light lavender to white
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final t = (x + y) / (2 * size); // diagonal gradient factor
      final r = lerp(0xF8, 0xFF, t).toInt();
      final g = lerp(0xF6, 0xFF, t).toInt();
      final b = lerp(0xFF, 0xFF, t).toInt();
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Draw rounded rectangle mask (subtle border effect)
  final cornerRadius = (size * 0.22).toInt();
  drawRoundedRect(image, 0, 0, size - 1, size - 1, cornerRadius, 0x1A, 0x1A, 0x2E, 20);

  // Center: stylized "b" + heart motif using simple geometry
  final center = size ~/ 2;

  // Draw a simplified baby/parent icon (geometric shapes)
  // Head circle
  drawFilledCircle(image, center, center, (size * 0.28).toInt(), 0x6C, 0x63, 0xFF, 240);
  drawFilledCircle(image, center, center, (size * 0.24).toInt(), 0x6C, 0x63, 0xFF, 255);

  // Small heart accent below
  final heartY = (size * 0.72).toInt();
  final heartSize = (size * 0.08).toInt();
  drawHeart(image, center, heartY, heartSize, 0xFF, 0x6B, 0x6B, 200);

  return image;
}

/// Draw a filled circle at (cx, cy) with given radius
void drawFilledCircle(img.Image image, int cx, int cy, int radius, int r, int g, int b, int a) {
  for (var dy = -radius; dy <= radius; dy++) {
    for (var dx = -radius; dx <= radius; dx++) {
      if (dx * dx + dy * dy <= radius * radius) {
        final px = cx + dx;
        final py = cy + dy;
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          final existing = image.getPixel(px, py);
          // Alpha blend
          final blendA = a / 255.0;
          final outR = (r * blendA + existing.r * (1 - blendA)).toInt();
          final outG = (g * blendA + existing.g * (1 - blendA)).toInt();
          final outB = (b * blendA + existing.b * (1 - blendA)).toInt();
          image.setPixelRgba(px, py, outR, outG, outB, 255);
        }
      }
    }
  }
}

/// Draw a simple heart shape
void drawHeart(img.Image image, int cx, int cy, int size, int r, int g, int b, int a) {
  for (var dy = -size * 2; dy <= size; dy++) {
    for (var dx = -size; dx <= size; dx++) {
      final x = dx / size;
      final y = -dy / (size * 2.0);
      // Heart equation: (x^2 + y^2 - 1)^3 - x^2 * y^3 <= 0
      final val = pow(x * x + y * y - 1, 3) - x * x * y * y * y;
      if (val <= 0.05) {
        final px = cx + dx;
        final py = cy + dy;
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          image.setPixelRgba(px, py, r, g, b, a);
        }
      }
    }
  }
}

/// Draw a rounded rectangle outline
void drawRoundedRect(img.Image image, int x1, int y1, int x2, int y2, int r, int cr, int cg, int cb, int ca) {
  // Simple: draw corners and edges
  for (var x = x1 + r; x <= x2 - r; x++) {
    image.setPixelRgba(x, y1, cr, cg, cb, ca);
    image.setPixelRgba(x, y2, cr, cg, cb, ca);
  }
  for (var y = y1 + r; y <= y2 - r; y++) {
    image.setPixelRgba(x1, y, cr, cg, cb, ca);
    image.setPixelRgba(x2, y, cr, cg, cb, ca);
  }
}

double lerp(double a, double b, double t) => a + (b - a) * t;

void main() async {
  print('BabyMon Icon Generator');
  print('======================\n');

  // Create output directories
  final androidDir = Directory('$outputDir/android');
  final iosDir = Directory('$outputDir/ios');
  await androidDir.create(recursive: true);
  await iosDir.create(recursive: true);

  // Generate Android icons
  print('Generating Android mipmap icons...');
  for (final entry in androidSizes.entries) {
    final icon = drawBabyMonIcon(entry.value);
    final filename = '${androidDir.path}/ic_launcher_${entry.key}.png';
    File(filename).writeAsBytesSync(img.encodePng(icon));
    print('  ✓ $filename (${entry.value}x${entry.value})');
  }

  // Generate iOS icons
  print('\nGenerating iOS app icons...');
  for (final entry in iosSizes.entries) {
    final icon = drawBabyMonIcon(entry.value);
    final filename = '${iosDir.path}/${entry.key}.png';
    File(filename).writeAsBytesSync(img.encodePng(icon));
    print('  ✓ $filename (${entry.value}x${entry.value})');
  }

  print('\nInstructions:');
  print('1. Copy Android icons from $androidDir/ to apps/mobile/android/app/src/main/res/mipmap-*/');
  print('   - mdpi → mipmap-mdpi/ic_launcher.png');
  print('   - hdpi → mipmap-hdpi/ic_launcher.png');
  print('   - xhdpi → mipmap-xhdpi/ic_launcher.png');
  print('   - xxhdpi → mipmap-xxhdpi/ic_launcher.png');
  print('   - xxxhdpi → mipmap-xxxhdpi/ic_launcher.png');
  print('2. Copy iOS icons from $iosDir/ to apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/');
  print('3. Run: dart pub add image   (to install the image package)');
  print('\nDone!');
}
