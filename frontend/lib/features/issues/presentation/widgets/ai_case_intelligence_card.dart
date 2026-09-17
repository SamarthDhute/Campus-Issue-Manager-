import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/ai_models.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/issue_model.dart';
import 'package:smart_campus_issue_manager/features/issues/state/ai_provider.dart';
import 'package:smart_campus_issue_manager/features/issues/state/issue_provider.dart';

class AiCaseIntelligenceCard extends StatefulWidget {
  final IssueModel issue;

  const AiCaseIntelligenceCard({
    super.key,
    required this.issue,
  });

  @override
  State<AiCaseIntelligenceCard> createState() => _AiCaseIntelligenceCardState();
}

class _AiCaseIntelligenceCardState extends State<AiCaseIntelligenceCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiProvider>().loadAnalysis(widget.issue.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isStaff = authProvider.isOperator || authProvider.isTeamLead || authProvider.isCampusManager || authProvider.isAdmin;

    final analysis = aiProvider.currentAnalysis;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10.5)),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Case Intelligence',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF312E81),
                        ),
                      ),
                      Text(
                        'Automated summarization & decision assistance',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ],
                  ),
                ),
                if (analysis != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, size: 12, color: Color(0xFF047857)),
                        const SizedBox(width: 4),
                        Text(
                          '${(analysis.confidence * 100).toInt()}% Confidence',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: aiProvider.isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                        )
                      : const Icon(Icons.refresh, size: 18, color: Color(0xFF4F46E5)),
                  tooltip: 'Re-Analyze with AI',
                  onPressed: aiProvider.isAnalyzing
                      ? null
                      : () {
                          context.read<AiProvider>().triggerAnalysis(widget.issue.id);
                        },
                ),
              ],
            ),
          ),

          // Content Body
          if (aiProvider.isLoading && analysis == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Analyzing issue context & history...',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else if (analysis != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Executive Summary
                  if (analysis.summary != null && analysis.summary!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.notes, size: 14, color: Color(0xFF64748B)),
                              SizedBox(width: 6),
                              Text(
                                'EXECUTIVE SUMMARY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            analysis.summary!,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 2. Missing Information Warning
                  if (analysis.missingInformation != null &&
                      analysis.missingInformation!.isNotEmpty &&
                      analysis.missingInformation!.toLowerCase() != 'none') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                                children: [
                                  const TextSpan(
                                    text: 'Missing Information: ',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: analysis.missingInformation!),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 3. AI Recommendations Loop
                  if (analysis.recommendations.isNotEmpty) ...[
                    const Text(
                      'AI Recommendations & Next Actions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...analysis.recommendations.map((rec) => _buildRecommendationItem(context, rec, isStaff)),
                  ],

                  // 4. Duplicate / Related Issues Alert
                  if (aiProvider.relatedIssues.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildRelatedIssuesAlert(aiProvider.relatedIssues),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(BuildContext context, AiRecommendationModel rec, bool isStaff) {
    final isPending = rec.decision == 'PENDING';
    final isAccepted = rec.decision == 'ACCEPTED';
    final isRejected = rec.decision == 'REJECTED';

    IconData typeIcon = Icons.recommend;
    String typeLabel = 'RECOMMENDATION';
    Color badgeColor = const Color(0xFF6366F1);

    if (rec.recommendationType == 'PRIORITY') {
      typeIcon = Icons.flag_outlined;
      typeLabel = 'SUGGESTED PRIORITY: ${rec.suggestedValue}';
      badgeColor = rec.suggestedValue == 'HIGH' || rec.suggestedValue == 'URGENT'
          ? AppTheme.statusRed
          : AppTheme.statusAmber;
    } else if (rec.recommendationType == 'NEXT_ACTION') {
      typeIcon = Icons.task_alt;
      typeLabel = 'RECOMMENDED ACTION';
      badgeColor = const Color(0xFF0284C7);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcon, size: 14, color: badgeColor),
              const SizedBox(width: 6),
              Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
              const Spacer(),
              if (isAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACCEPTED',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                  ),
                )
              else if (isRejected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DISMISSED',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rec.recommendationType == 'PRIORITY'
                ? (rec.explanation ?? 'Based on safety and operational disruption analysis.')
                : rec.suggestedValue,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
          if (isStaff && isPending) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await context.read<AiProvider>().recordDecision(widget.issue.id, rec.id, 'REJECTED');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: const Size(0, 30),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await context.read<AiProvider>().recordDecision(widget.issue.id, rec.id, 'ACCEPTED');
                    if (success && context.mounted) {
                      // Refresh issue details in IssueProvider to reflect new priority
                      context.read<IssueProvider>().loadIssueById(widget.issue.id);
                    }
                  },
                  icon: const Icon(Icons.check, size: 13, color: Colors.white),
                  label: Text(
                    rec.recommendationType == 'PRIORITY' ? 'Apply Priority' : 'Acknowledge',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 30),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedIssuesAlert(List<RelatedIssueModel> related) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.copy_all, size: 15, color: Color(0xFFEA580C)),
              const SizedBox(width: 6),
              Text(
                'Correlated / Duplicate Reports Detected (${related.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9A3412),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...related.map((r) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFED7AA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        r.issueNumber,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9A3412)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        r.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF7C2D12)),
                      ),
                    ),
                    Text(
                      '${(r.confidence * 100).toInt()}% Match',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEA580C)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
