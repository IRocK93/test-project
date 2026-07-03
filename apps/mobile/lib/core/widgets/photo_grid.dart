import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/widgets/animated_entry.dart';
import 'package:baby_mon/core/constants/constants.dart';


/// A single photo tile in the album grid.
///
/// Renders a square thumbnail with [Hero] wrapping for shared-element
/// transitions to the [PhotoViewerPage]. Supports tap (view full-screen)
/// and long-press (delete) gestures.
class PhotoGridItem extends StatelessWidget {
  final Map<String, dynamic> photo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PhotoGridItem({
    super.key,
    required this.photo,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final url = photo['url']?.toString() ?? '';
    final heroTag = 'photo_${photo['id'] ?? url}';

    return Hero(
      tag: heroTag,
      child: Semantics(
        label: context.l10n.photoGridViewPhoto,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Semantics(
              label: context.l10n.photoGridPhotoFromAlbum,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                color: context.colorScheme.onSurface.withValues(alpha: 0.38).withValues(alpha: 0.1),
              ),
              errorWidget: (ctx, url, error) => Container(
                color: context.colorScheme.onSurface.withValues(alpha: 0.38).withValues(alpha: 0.1),
                child: ExcludeSemantics(
                  child: Icon(PhosphorIconsLight.imageBroken,
                      color: context.colorScheme.onSurface.withValues(alpha: 0.38), size: 32),
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A photo month section with a header label and a 3-column photo grid.
///
/// Wrapped in [ScrollStagger] for staggered entry animation. Each photo
/// uses [PhotoGridItem] with tap and long-press callbacks provided by
/// the parent.
class PhotoMonthSection extends StatelessWidget {
  final int staggerIndex;
  final String month;
  final List<Map<String, dynamic>> photos;
  final void Function(Map<String, dynamic> photo) onPhotoTap;
  final void Function(Map<String, dynamic> photo) onPhotoLongPress;

  const PhotoMonthSection({
    super.key,
    required this.staggerIndex,
    required this.month,
    required this.photos,
    required this.onPhotoTap,
    required this.onPhotoLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollStagger(
      index: staggerIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              month,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return PhotoGridItem(
                photo: photo,
                onTap: () => onPhotoTap(photo),
                onLongPress: () => onPhotoLongPress(photo),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
