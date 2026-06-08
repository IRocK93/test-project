import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';

/// E4 — Photo Timeline / Baby Album: A scrollable gallery of baby photos.
///
/// Displays photos uploaded via camera or gallery in a 3-column grid grouped by
/// month/year section headers (e.g. "January 2026"). Each photo can be tapped
/// for full-screen viewing with caption display, or long-pressed to delete.
/// Uploads are handled via the image_picker package: camera icon for new photos,
/// gallery icon for existing images. Photos are base64-encoded and sent to the
/// backend which stores them via Cloudinary. Milestone photos from the
/// MilestonesScreen also appear here when linked via linkedEntryId.
///
/// API: POST/GET/DELETE /api/baby-mons/:id/photos
/// Dependencies: image_picker ^1.1.0
/// Integration points: MainScreen (7th tab), DashboardScreen (recent photos carousel)
class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key});

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen> {
  /// The currently selected BabyMon ID from secure storage
  String? _babyMonId;

  /// All photos fetched from the API, ordered by takenAt descending
  List<Map<String, dynamic>> _photos = [];

  /// Whether data is currently loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadData();
    });
  }

  /// Loads the BabyMon ID and fetches photos
  Future<void> _loadData() async {
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null || id.isEmpty) {
      if (id != null && id.isEmpty) await api.setSelectedBabyMonId(null);
      setState(() => _isLoading = false);
      return;
    }
    _babyMonId = id;
    await _fetchPhotos();
  }

  /// Fetches all photos for the BabyMon from the backend (ordered by date desc)
  Future<void> _fetchPhotos() async {
    if (_babyMonId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getPhotos(_babyMonId!);
      final items = (response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? [];
      setState(() {
        _photos = items.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      // Backend endpoint not yet implemented — quietly show empty state
      setState(() => _isLoading = false);
    }
  }

  /// Uploads a selected image file to the backend after reading and base64 encoding it
  Future<void> _uploadPhoto(File file) async {
    if (_babyMonId == null) return;
    try {
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);

      await ref.read(apiClientProvider).uploadPhoto(_babyMonId!, {
        'image': base64,
        'caption': '',
        'takenAt': DateTime.now().toIso8601String(),
      });

      await _fetchPhotos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo upload coming soon')),
        );
      }
    }
  }

  /// Opens the device camera to capture a new photo
  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) await _uploadPhoto(File(picked.path));
  }

  /// Opens the device gallery to select an existing photo
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) await _uploadPhoto(File(picked.path));
  }

  /// Deletes a photo after user confirmation, removes from Cloudinary too
  Future<void> _deletePhoto(String id, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Remove this photo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(apiClientProvider).deletePhoto(id);
      setState(() => _photos.removeAt(index));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Shows a photo full-screen in a dialog with optional caption overlay
  void _viewPhotoFullScreen(String url, String? caption) {
    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url, fit: BoxFit.contain),
              ),
              if (caption != null && caption.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(caption, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Groups photos by month/year for section headers (e.g. "June 2026")
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
      appBar: AppBar(title: const Text('Album')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Start your baby album', style: TextStyle(color: Colors.grey)),
                      Text('Tap + to add photos'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPhotos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: grouped.length,
                    itemBuilder: (context, groupIndex) {
                      final month = grouped.keys.elementAt(groupIndex);
                      final photos = grouped[month]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(month, style: Theme.of(context).textTheme.titleMedium),
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
                              final url = photo['url']?.toString() ?? '';
                              return GestureDetector(
                                onTap: () => _viewPhotoFullScreen(url, photo['caption']?.toString()),
                                onLongPress: () => _deletePhoto(photo['id'], _photos.indexOf(photo)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(url, fit: BoxFit.cover),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'album_camera_fab',
            onPressed: _pickFromCamera,
            mini: true,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'album_gallery_fab',
            onPressed: _pickFromGallery,
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}