import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../issues/data/models/issue_model.dart';
import '../../operations/data/models/operation_models.dart';
import '../../operations/state/operations_provider.dart';

class InvestigationLogWidget extends StatefulWidget {
  final IssueModel issue;
  final bool isStaff;

  const InvestigationLogWidget({
    super.key,
    required this.issue,
    required this.isStaff,
  });

  @override
  State<InvestigationLogWidget> createState() => _InvestigationLogWidgetState();
}

class _InvestigationLogWidgetState extends State<InvestigationLogWidget> {
  bool _isFormOpen = false;
  final _obsController = TextEditingController();
  final _actionsController = TextEditingController();
  final _findingsController = TextEditingController();
  final _followUpController = TextEditingController();

  @override
  void dispose() {
    _obsController.dispose();
    _actionsController.dispose();
    _findingsController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OperationsProvider>(
      builder: (context, provider, child) {
        final investigations = provider.investigations;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.biotech_rounded, color: AppTheme.primaryBlue, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Field Investigation Reports',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    if (widget.isStaff && !_isFormOpen)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isFormOpen = true),
                        icon: const Icon(Icons.note_add, size: 16),
                        label: const Text('Log Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // New Investigation Form
                if (_isFormOpen) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Technical Investigation Entry',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _obsController,
                          decoration: const InputDecoration(
                            labelText: 'Field Observations *',
                            hintText: 'What did you observe upon inspecting the physical location?',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _findingsController,
                          decoration: const InputDecoration(
                            labelText: 'Root Cause & Findings',
                            hintText: 'Underlying cause (e.g. thermal overload, pipe coupling failure)',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _actionsController,
                          decoration: const InputDecoration(
                            labelText: 'Actions Taken',
                            hintText: 'Immediate remediations or tests performed on site',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _followUpController,
                          decoration: const InputDecoration(
                            labelText: 'Follow-up Requirements',
                            hintText: 'Parts to order, recurring check scheduled',
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _isFormOpen = false),
                              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: provider.isSubmittingInvestigation
                                  ? null
                                  : () async {
                                      final obs = _obsController.text.trim();
                                      if (obs.isNotEmpty) {
                                        final success = await provider.submitInvestigation(
                                          widget.issue.id,
                                          observations: obs,
                                          findings: _findingsController.text.trim(),
                                          actionsTaken: _actionsController.text.trim(),
                                          followUp: _followUpController.text.trim(),
                                        );
                                        if (success && mounted) {
                                          _obsController.clear();
                                          _findingsController.clear();
                                          _actionsController.clear();
                                          _followUpController.clear();
                                          setState(() => _isFormOpen = false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Field report submitted successfully'),
                                              backgroundColor: AppTheme.statusGreen,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: provider.isSubmittingInvestigation
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Save Report'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Reports List
                if (investigations.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 36, color: AppTheme.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 6),
                          const Text(
                            'No field investigation logged yet.',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: investigations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final inv = investigations[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14, color: AppTheme.primaryBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${inv.investigatorName} (${inv.investigatorRole})',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                                    ),
                                  ],
                                ),
                                if (inv.createdAt != null)
                                  Text(
                                    '${inv.createdAt!.day}/${inv.createdAt!.month} ${inv.createdAt!.hour}:${inv.createdAt!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Observations:', inv.observations),
                            if (inv.findings != null && inv.findings!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _buildInfoRow('Root Cause:', inv.findings!),
                            ],
                            if (inv.actionsTaken != null && inv.actionsTaken!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _buildInfoRow('Actions Taken:', inv.actionsTaken!),
                            ],
                            if (inv.followUp != null && inv.followUp!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _buildInfoRow('Follow-up:', inv.followUp!),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }
}
