import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/constants/app_constants.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import '../models/evidence_model.dart';
import '../state/resolution_provider.dart';

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
              const Text(
                'Resolution Evidence Suite',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: allEvidence.isNotEmpty
                      ? AppTheme.statusGreen.withOpacity(0.12)
                      : AppTheme.statusAmber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  allEvidence.isNotEmpty ? '${allEvidence.length} Evidences' : 'No Evidence',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: allEvidence.isNotEmpty ? AppTheme.statusGreen : AppTheme.statusAmber,
                  ),
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
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.photo_camera_back_outlined, size: 36, color: AppTheme.textMuted),
                    SizedBox(height: 8),
                    Text(
                      'No before/after repair photos uploaded yet',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Row(
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
              Text(
                '${items.length}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
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
                    height: 100,
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
