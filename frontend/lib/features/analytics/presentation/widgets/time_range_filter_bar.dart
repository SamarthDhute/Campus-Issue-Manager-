import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TimeRangeFilterBar extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onSelected;

  const TimeRangeFilterBar({
    Key? key,
    required this.selectedRange,
    required this.onSelected,
  }) : super(key: key);

  static const List<Map<String, String>> ranges = [
    {'key': '7d', 'label': 'Last 7 Days'},
    {'key': '30d', 'label': 'Last 30 Days'},
    {'key': '90d', 'label': 'Last Quarter'},
    {'key': 'all', 'label': 'All Time'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: ranges.map((r) {
          final isSelected = selectedRange == r['key'];
          return InkWell(
            onTap: () => onSelected(r['key']!),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                r['label']!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
