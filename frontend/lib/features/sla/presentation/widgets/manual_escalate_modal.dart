import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/sla_provider.dart';

class ManualEscalateModal extends StatefulWidget {
  final String issueId;
  final String issueNumber;

  const ManualEscalateModal({
    super.key,
    required this.issueId,
    required this.issueNumber,
  });

  static Future<void> show(BuildContext context, {required String issueId, required String issueNumber}) {
    return showDialog(
      context: context,
      builder: (_) => ManualEscalateModal(issueId: issueId, issueNumber: issueNumber),
    );
  }

  @override
  State<ManualEscalateModal> createState() => _ManualEscalateModalState();
}

class _ManualEscalateModalState extends State<ManualEscalateModal> {
  int _selectedLevel = 1;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a specific escalation reason.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final slaProvider = context.read<SlaProvider>();
    final success = await slaProvider.escalateIssue(
      widget.issueId,
      level: _selectedLevel,
      reason: reason,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.statusGreen,
            content: Text('Issue ${widget.issueNumber} successfully escalated to Tier $_selectedLevel!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.statusRed,
            content: Text(slaProvider.errorMessage ?? 'Failed to escalate issue.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.statusRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.crisis_alert_rounded, color: AppTheme.statusRed, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Escalate Issue',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                        ),
                        Text(
                          'Trigger management alert for ${widget.issueNumber}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Escalation Tier',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildTierOption(
                      level: 1,
                      title: 'Tier 1: Team Lead',
                      subtitle: 'Workload stall or domain blocker',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTierOption(
                      level: 2,
                      title: 'Tier 2: Manager',
                      subtitle: 'SLA breach / High campus impact',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                'Formal Reason & Context',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Explain why this case requires priority escalation...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.statusRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.arrow_upward_rounded, size: 18),
                    label: Text(_isSubmitting ? 'Escalating...' : 'Confirm Escalation'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierOption({required int level, required String title, required String subtitle}) {
    final isSelected = _selectedLevel == level;
    final color = level == 1 ? AppTheme.statusAmber : AppTheme.statusRed;

    return InkWell(
      onTap: () => setState(() => _selectedLevel = level),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 16,
                  color: isSelected ? color : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
