import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/mixins/mixins.dart';

class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key});

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen>
    with DataScreenMixin<AlbumScreen> {
  @override
  bool get autoInit => true;

  @override
  int? get listenToTabRefresh => 4;

  @override
  Duration? get refreshCooldown => const Duration(seconds: 10);

  List<Map<String, dynamic>> _photos = [];

  @override
  IconData get emptyIcon => PhosphorIconsLight.camera;

  @override
  String get emptyTitle => 'Start your baby album';

  @override
  String get emptySubtitle => 'Tap + to add photos';

  @override
  String get emptyActionLabel => 'Add a photo';

  @override
  void onEmptyAction() => _pickFromGallery();

  @override
  Future<void> fetchData() async {
    final response = await ref.read(apiClientProvider).getPhotos(babyMonId!);
    _photos = parseItemsTyped(response.data);
  }

  Future<void> _uploadPhoto(File file) async {
    // Capture messenger upfront so we can safely use it after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    if (babyMonId == null) return;
    try {
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);

      await ref.read(apiClientProvider).uploadPhoto(babyMonId!, {
        'image': base64,
        'caption': '',
        'takenAt': DateTime.now().toIso8601String(),
      });

      await loadData(force: true);
      messenger.showSnackBar(
        const SnackBar(content: Text('Photo uploaded!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e))),
      );
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) await _uploadPhoto(File(picked.path));
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) await _uploadPhoto(File(picked.path));
  }

  Future<void> _deletePhoto(String id, int index) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Delete Photo',
      message: 'Remove this photo?',
    );
    if (!confirmed) return;

    try {
      await ref.read(apiClientProvider).deletePhoto(id);
      setState(() => _photos.removeAt(index));
      messenger.showSnackBar(const SnackBar(content: Text('Photo deleted')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
    }
  }

  void _viewPhotoFullScreen(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PhotoViewerPage(
          photos: List.from(_photos),
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupedPhotos() {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final photo in _photos) {
      final date = DateTime.tryParse(photo['takenAt']?.toString() ?? '') ?? DateTime.now();
      final key = DateFormat('MMMM yyyy').format(date);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(photo);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedPhotos();

    return Scaffold(
      appBar: ScreenHeader(
        title: 'Album',
        onBack: () => popOrGoHome(context),
      ),
      body: PremiumBackground(
        child: isLoading
            ? buildLoading()
            : !hasBabyMon
                ? buildNoBabyMon()
                : _photos.isEmpty
                    ? buildEmptyState()
                    : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DesignTokens.bentoPadding),
                    itemCount: grouped.length,
                    itemBuilder: (context, groupIndex) {
                      final month = grouped.keys.elementAt(groupIndex);
                      final photos = grouped[month]!;
                      return PhotoMonthSection(
                        staggerIndex: groupIndex,
                        month: month,
                        photos: photos,
                        onPhotoTap: (photo) =>
                            _viewPhotoFullScreen(_photos.indexOf(photo)),
                        onPhotoLongPress: (photo) =>_deletePhoto(parseString(photo['id']) ?? '', _photos.indexOf(photo)),
                      );
                    },                ),
              ),
            ),
      floatingActionButton: InfoFab(
        tooltip: 'Add a photo to your album',
        icon: PhosphorIconsLight.camera,
        children: [
          InfoFabAction(
            tooltip: 'Take a photo',
            infoDescription: 'Camera',
            onTap: _pickFromCamera,
            child: const Icon(PhosphorIconsLight.camera, color: AppColors.textOnPrimary),
          ),
          InfoFabAction(
            tooltip: 'Pick from gallery',
            infoDescription: 'Gallery',
            onTap: _pickFromGallery,
            child: const Icon(PhosphorIconsLight.images, color: AppColors.textOnPrimary),
          ),
        ],
      ),
    );
  }
}
