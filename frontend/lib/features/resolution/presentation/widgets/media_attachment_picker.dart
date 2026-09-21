import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';

class PickedMediaItem {
  final String fileName;
  final Uint8List bytes;
  final String? path;

  PickedMediaItem({
    required this.fileName,
    required this.bytes,
    this.path,
  });
}

class MediaAttachmentPicker extends StatefulWidget {
  final List<PickedMediaItem> initialFiles;
  final Function(List<PickedMediaItem>) onFilesChanged;
  final int maxFiles;

  const MediaAttachmentPicker({
    super.key,
    required this.onFilesChanged,
    this.initialFiles = const [],
    this.maxFiles = 5,
  });

  @override
  State<MediaAttachmentPicker> createState() => _MediaAttachmentPickerState();
}

class _MediaAttachmentPickerState extends State<MediaAttachmentPicker> {
  final ImagePicker _picker = ImagePicker();
  late List<PickedMediaItem> _files;

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.initialFiles);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_files.length >= widget.maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxFiles} photos allowed'),
          backgroundColor: AppTheme.statusAmber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final fileName = image.name.isNotEmpty
            ? image.name
            : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

        setState(() {
          _files.add(PickedMediaItem(
            fileName: fileName,
            bytes: bytes,
            path: image.path,
          ));
        });
        widget.onFilesChanged(_files);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture/select image: $e'),
            backgroundColor: AppTheme.statusRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
    widget.onFilesChanged(_files);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_camera_outlined, size: 18, color: AppTheme.primaryIndigo),
            const SizedBox(width: 8),
            const Text(
              'Attach Photos & Evidence',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const Spacer(),
            Text(
              '${_files.length}/${widget.maxFiles}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryIndigo,
                  side: BorderSide(color: AppTheme.primaryIndigo.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery / Files'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryIndigo,
                  side: BorderSide(color: AppTheme.primaryIndigo.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _files.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final file = _files[index];
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                        image: DecorationImage(
                          image: MemoryImage(file.bytes),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removeFile(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
