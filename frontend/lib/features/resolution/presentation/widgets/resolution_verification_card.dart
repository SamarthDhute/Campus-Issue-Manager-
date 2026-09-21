import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/core/widgets/custom_button.dart';
import 'package:smart_campus_issue_manager/core/widgets/custom_text_field.dart';
import '../../issues/data/models/issue_model.dart';
import '../../issues/state/issue_provider.dart';
import '../models/feedback_model.dart';
import '../state/resolution_provider.dart';

class ResolutionVerificationCard extends StatefulWidget {
  final IssueModel issue;
  final VoidCallback? onStatusUpdated;

  const ResolutionVerificationCard({
    super.key,
    required this.issue,
    this.onStatusUpdated,
  });

  @override
  State<ResolutionVerificationCard> createState() => _ResolutionVerificationCardState();
}

class _ResolutionVerificationCardState extends State<ResolutionVerificationCard> {
  int _selectedRating = 5;
  ResolutionQuality _selectedQuality = ResolutionQuality.satisfied;
  final _feedbackController = TextEditingController();
  final _reopenReasonController = TextEditingController();
  bool _isReopening = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _reopenReasonController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmResolution() async {
    final resolutionProvider = context.read<ResolutionProvider>();
    final success = await resolutionProvider.submitFeedback(
      issueId: widget.issue.id,
      rating: _selectedRating,
      feedbackText: _feedbackController.text.trim(),
      resolutionQuality: _selectedQuality,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resolution confirmed! Issue is now closed.'),
          backgroundColor: AppTheme.statusGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.read<IssueProvider>().loadIssueById(widget.issue.id);
      widget.onStatusUpdated?.call();
    }
  }

  Future<void> _handleReopenIssue() async {
    if (_reopenReasonController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please explain why the issue was not resolved (min 5 chars)'),
          backgroundColor: AppTheme.warningAmber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final resolutionProvider = context.read<ResolutionProvider>();
    final success = await resolutionProvider.reopenIssue(
      issueId: widget.issue.id,
      reason: _reopenReasonController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _isReopening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue disputed and reopened for further action.'),
          backgroundColor: AppTheme.statusRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.read<IssueProvider>().loadIssueById(widget.issue.id);
      widget.onStatusUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolutionProvider = context.watch<ResolutionProvider>();
    final feedback = resolutionProvider.feedback;
    final isPendingConfirmation = widget.issue.status == 'RESOLVED_PENDING_CONFIRMATION';
    final isClosed = widget.issue.status == 'CLOSED' || widget.issue.status == 'CONFIRMED';

    if (!isPendingConfirmation && !isClosed) {
      return const SizedBox.shrink();
    }

    if (isClosed && feedback != null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.statusGreen.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.statusGreen.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: AppTheme.statusGreen, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Resolution Verified & Closed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.statusGreen),
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < feedback.rating ? Icons.star : Icons.star_border,
                      size: 18,
                      color: AppTheme.statusAmber,
                    );
                  }),
                ),
              ],
            ),
            if (feedback.feedbackText != null && feedback.feedbackText!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '"${feedback.feedbackText}"',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppTheme.textDark),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                child: const Icon(Icons.rate_review_outlined, color: AppTheme.primaryIndigo, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requester Verification & Sign-off',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  ),
                  Text(
                    'Operator has marked this ticket resolved. Please verify the repair.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isReopening) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.statusRed.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.statusRed.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why was this issue not resolved?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.statusRed),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _reopenReasonController,
                    label: 'Describe unresolved problems or defects',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _isReopening = false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: resolutionProvider.isLoading ? null : _handleReopenIssue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.statusRed,
                          foregroundColor: Colors.white,
                        ),
                        child: resolutionProvider.isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Confirm Dispute & Reopen'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text('Rate Resolution Quality:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starNum = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _selectedRating = starNum),
                  icon: Icon(
                    starNum <= _selectedRating ? Icons.star : Icons.star_border,
                    color: AppTheme.statusAmber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _feedbackController,
              label: 'Feedback & Comments (Optional)',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    label: 'Confirm & Close Ticket',
                    isLoading: resolutionProvider.isLoading,
                    icon: Icons.check_circle_outline,
                    onPressed: _handleConfirmResolution,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _isReopening = true),
                    icon: const Icon(Icons.replay, size: 16),
                    label: const Text('Dispute & Reopen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.statusRed,
                      side: BorderSide(color: AppTheme.statusRed.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
