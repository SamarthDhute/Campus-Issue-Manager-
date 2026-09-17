import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../issues/data/models/issue_model.dart';
import '../../issues/state/issue_provider.dart';
import '../../operations/data/models/operation_models.dart';
import '../../operations/state/operations_provider.dart';

class SmartAssignmentCard extends StatefulWidget {
  final IssueModel issue;

  const SmartAssignmentCard({super.key, required this.issue});

  @override
  State<SmartAssignmentCard> createState() => _SmartAssignmentCardState();
}

class _SmartAssignmentCardState extends State<SmartAssignmentCard> {
  CandidateOperatorModel? _selectedAlternate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final opProvider = Provider.of<OperationsProvider>(context, listen: false);
      if (opProvider.recommendation == null || opProvider.recommendation!.issueId != widget.issue.id) {
        opProvider.fetchRecommendation(widget.issue.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OperationsProvider>(
      builder: (context, provider, child) {
        final rec = provider.recommendation;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.primaryIndigo],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Smart Dispatch Engine',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  if (rec != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.statusGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.statusGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, size: 14, color: AppTheme.statusGreen),
                          const SizedBox(width: 4),
                          Text(
                            '${(rec.matchScore * 100).toInt()}% Match',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.statusGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              if (provider.isRecommending)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (rec == null)
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Generate optimal technician dispatch recommendation based on category skills & active load.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchRecommendation(widget.issue.id),
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('Analyze'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ],
                )
              else ...[
                // Recommended technician card
                Container(
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
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue,
                            radius: 18,
                            child: Text(
                              rec.recommendedUserName.isNotEmpty ? rec.recommendedUserName[0] : 'T',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.recommendedUserName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                                ),
                                Text(
                                  '${rec.recommendedTeamName} • ${rec.recommendedUserEmail}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.statusAmber.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${rec.currentActiveWorkload} Active',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.statusAmber),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rec.rationale,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.3),
                      ),
                    ],
                  ),
                ),

                // Alternates dropdown if available
                if (rec.alternateCandidates.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Alternate Candidates:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: rec.alternateCandidates.map((alt) {
                      final isSelected = _selectedAlternate?.userId == alt.userId;
                      return ChoiceChip(
                        label: Text('${alt.name} (${alt.activeTasksCount} active)'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAlternate = selected ? alt : null;
                          });
                        },
                        selectedColor: AppTheme.primaryIndigo.withOpacity(0.2),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 14),

                // Dispatch Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isAssigning
                        ? null
                        : () async {
                            final targetUserId = _selectedAlternate?.userId ?? rec.recommendedUserId;
                            final targetTeamId = _selectedAlternate?.teamId ?? rec.recommendedTeamId;
                            final targetName = _selectedAlternate?.name ?? rec.recommendedUserName;

                            final success = await provider.assignIssue(
                              widget.issue.id,
                              userId: targetUserId,
                              teamId: targetTeamId,
                              assignmentType: 'PRIMARY',
                              recommendationSource: _selectedAlternate != null ? 'MANUAL_OVERRIDE' : 'AI_RECOMMENDED',
                              reason: 'Dispatched to $targetName based on workload & specialization.',
                            );

                            if (success && context.mounted) {
                              // Refresh Issue details
                              Provider.of<IssueProvider>(context, listen: false).loadIssueDetails(widget.issue.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Successfully assigned issue to $targetName'),
                                  backgroundColor: AppTheme.statusGreen,
                                ),
                              );
                            }
                          },
                    icon: provider.isAssigning
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      provider.isAssigning
                          ? 'Dispatching...'
                          : 'Confirm & Dispatch to ${_selectedAlternate?.name ?? rec.recommendedUserName}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
