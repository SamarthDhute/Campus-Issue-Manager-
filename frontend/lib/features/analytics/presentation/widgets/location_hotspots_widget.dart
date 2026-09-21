import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analytics_models.dart';

class LocationHotspotsWidget extends StatelessWidget {
  final List<LocationHotspotModel> hotspots;

  const LocationHotspotsWidget({Key? key, required this.hotspots}) : super(key: key);

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return AppTheme.statusRed;
      case 'MEDIUM':
        return AppTheme.statusAmber;
      case 'LOW':
      default:
        return AppTheme.statusGreen;
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
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Campus Hotspots & Failure Density',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${hotspots.length} Zones',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hotspots.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No hotspot activity detected for this time range.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hotspots.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.borderSubtle, height: 20),
              itemBuilder: (context, index) {
                final item = hotspots[index];
                final riskColor = _getRiskColor(item.riskLevel);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.locationName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: riskColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.riskLevel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: riskColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Zone: ${item.buildingZone} • Primary: ${item.primaryCategory}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.totalIncidentCount} incidents',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.recurringRate.toStringAsFixed(0)}% repeat rate',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: item.recurringRate > 40 ? AppTheme.statusAmber : AppTheme.textMuted,
                          ),
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
