import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analytics_models.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<CategoryDistributionModel> categories;

  const CategoryBreakdownWidget({Key? key, required this.categories}) : super(key: key);

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppTheme.primaryIndigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.pie_chart_outline, color: AppTheme.primaryIndigo, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Category Incident Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                '${categories.length} Categories',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No category data available.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final barColor = _parseColor(cat.colorHex);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: barColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat.categoryName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${cat.totalIssuesCount} (${cat.percentageShare.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (cat.percentageShare / 100.0).clamp(0.0, 1.0),
                        backgroundColor: AppTheme.backgroundLight,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active: ${cat.activeCount}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.statusAmber),
                        ),
                        Text(
                          'Resolved: ${cat.resolvedCount}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.statusGreen),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
