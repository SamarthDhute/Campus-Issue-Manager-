import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/constants/app_constants.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/core/widgets/custom_button.dart';
import 'package:smart_campus_issue_manager/core/widgets/custom_text_field.dart';
import 'package:smart_campus_issue_manager/features/resolution/data/models/evidence_model.dart';
import 'package:smart_campus_issue_manager/features/resolution/state/resolution_provider.dart';

class ResolutionEvidenceWidget extends StatefulWidget {
  final String issueId;
  final bool canUpload;

  const ResolutionEvidenceWidget({
    super.key,
    required this.issueId,
    this.canUpload = false,
  });

  @override
  State<ResolutionEvidenceWidget> createState() => _ResolutionEvidenceWidgetState();
}

class _ResolutionEvidenceWidgetState extends State<ResolutionEvidenceWidget> {
  final ImagePicker _picker = ImagePicker();

  void _showImagePreview(BuildContext context, EvidenceModel evidence) {
    final imageUrl = evidence.fileUrl.startsWith('http')
        ? evidence.fileUrl
        : '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}${evidence.fileUrl}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                  if (evidence.notes != null && evidence.notes!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.black87,
                      child: Text(
                        evidence.notes!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openUploadDialog(BuildContext parentContext) {
    EvidenceType selectedType = EvidenceType.afterRepair;
    final notesController = TextEditingController();
    Uint8List? pickedBytes;
    String? pickedFileName;
    bool isSubmitting = false;

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage(ImageSource source) async {
            try {
              final XFile? file = await _picker.pickImage(
                source: source,
                imageQuality: 85,
                maxWidth: 1920,
              );
              if (file != null) {
                final bytes = await file.readAsBytes();
                setDialogState(() {
                  pickedBytes = bytes;
                  pickedFileName = file.name;
                });
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to pick image: $e'),
                    backgroundColor: AppTheme.statusRed,
                  ),
                );
              }
            }
          }

          Future<void> submit() async {
            if (pickedBytes == null || pickedFileName == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select or capture a photo first'),
                  backgroundColor: AppTheme.statusAmber,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            setDialogState(() => isSubmitting = true);
            final resolutionProvider = parentContext.read<ResolutionProvider>();
            final result = await resolutionProvider.uploadEvidenceWithFile(
              issueId: widget.issueId,
              evidenceType: selectedType,
              fileBytes: pickedBytes!,
              fileName: pickedFileName!,
              notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            );

            if (context.mounted) {
              setDialogState(() => isSubmitting = false);
              if (result != null) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Evidence uploaded successfully!'),
                    backgroundColor: AppTheme.statusGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                final err = resolutionProvider.errorMessage ?? 'Upload failed';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err),
                    backgroundColor: AppTheme.statusRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primaryIndigo, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Upload Resolution Evidence',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Evidence Type Selector
                    const Text(
                      'Evidence Category',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('After Repair (Fixed)'),
                          selected: selectedType == EvidenceType.afterRepair,
                          selectedColor: AppTheme.statusGreen.withOpacity(0.2),
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedType = EvidenceType.afterRepair);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Before Repair (Initial)'),
                          selected: selectedType == EvidenceType.beforeRepair,
                          selectedColor: AppTheme.statusAmber.withOpacity(0.2),
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedType = EvidenceType.beforeRepair);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Receipt / Invoice'),
                          selected: selectedType == EvidenceType.receipt,
                          selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedType = EvidenceType.receipt);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Media Capture / File Picker Buttons
                    const Text(
                      'Capture or Select Photo',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    if (pickedBytes != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderSubtle),
                          image: DecorationImage(
                            image: MemoryImage(pickedBytes!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onPressed: () {
                              setDialogState(() {
                                pickedBytes = null;
                                pickedFileName = null;
                              });
                            },
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_rounded, size: 18),
                              label: const Text('Camera'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                              label: const Text('Gallery'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Work / Repair Notes
                    CustomTextField(
                      controller: notesController,
                      label: 'Work / Repair Notes (Optional)',
                      hint: 'e.g. Replaced circuit breaker, tested wiring and voltage output...',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    CustomButton(
                      label: 'Upload Evidence',
                      isLoading: isSubmitting,
                      onPressed: submit,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolutionProvider = context.watch<ResolutionProvider>();
    final beforeEvidence = resolutionProvider.beforeRepairEvidence;
    final afterEvidence = resolutionProvider.afterRepairEvidence;
    final allEvidence = resolutionProvider.evidenceList;

    if (resolutionProvider.isLoading && allEvidence.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.compare_arrows_rounded, color: AppTheme.primaryIndigo, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resolution Evidence Suite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Before vs After repair proof',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.canUpload)
                ElevatedButton.icon(
                  onPressed: () => _openUploadDialog(context),
                  icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                  label: const Text('Upload Evidence'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (allEvidence.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.photo_camera_back_outlined, size: 36, color: AppTheme.textMuted),
                    const SizedBox(height: 8),
                    const Text(
                      'No before/after repair photos uploaded yet',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                    ),
                    if (widget.canUpload) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _openUploadDialog(context),
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Add Repair Proof Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryIndigo,
                          side: const BorderSide(color: AppTheme.primaryIndigo),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildEvidenceColumn(
                    title: 'Before Repair',
                    icon: Icons.history_toggle_off,
                    color: AppTheme.statusAmber,
                    items: beforeEvidence,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEvidenceColumn(
                    title: 'After Repair (Resolved)',
                    icon: Icons.verified_outlined,
                    color: AppTheme.statusGreen,
                    items: afterEvidence,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvidenceColumn({
    required String title,
    required IconData icon,
    required Color color,
    required List<EvidenceModel> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Pending proof',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted.withOpacity(0.7)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final item = items[idx];
                final imageUrl = item.fileUrl.startsWith('http')
                    ? item.fileUrl
                    : '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}${item.fileUrl}';

                return InkWell(
                  onTap: () => _showImagePreview(context, item),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderSubtle),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
