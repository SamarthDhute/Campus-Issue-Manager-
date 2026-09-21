import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../issues/presentation/screens/issue_detail_screen.dart';
import '../state/notification_provider.dart';

class NotificationsDrawer extends StatelessWidget {
  const NotificationsDrawer({super.key});

  static void open(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'SLA_WARNING':
        return Icons.hourglass_bottom_rounded;
      case 'SLA_BREACH':
        return Icons.timer_off_rounded;
      case 'ESCALATION_TRIGGERED':
        return Icons.crisis_alert_rounded;
      case 'ASSIGNMENT_UPDATE':
        return Icons.assignment_ind_outlined;
      case 'NEW_MESSAGE':
        return Icons.chat_bubble_outline_rounded;
      case 'ISSUE_RESOLVED':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'SLA_WARNING':
        return AppTheme.statusAmber;
      case 'SLA_BREACH':
      case 'ESCALATION_TRIGGERED':
        return AppTheme.statusRed;
      case 'ISSUE_RESOLVED':
        return AppTheme.statusGreen;
      default:
        return AppTheme.primaryIndigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;
    final unreadCount = notifProvider.unreadCount;

    return Drawer(
      width: 400,
      backgroundColor: AppTheme.surfaceWhite,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryBlue, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.statusRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount new',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: () => notifProvider.markAllAsRead(),
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryIndigo),
                      ),
                    ),
                ],
              ),
            ),

            // Notification List
            Expanded(
              child: notifProvider.isLoading && notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 48, color: AppTheme.textMuted.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              const Text(
                                'No notifications yet',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Real-time alerts will appear here',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => notifProvider.refreshNotifications(),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.borderSubtle),
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              final notifColor = _getNotificationColor(notif.notificationType);

                              return InkWell(
                                onTap: () {
                                  if (notif.isUnread) {
                                    notifProvider.markAsRead(notif.id);
                                  }
                                  if (notif.issueId != null) {
                                    Navigator.pop(context); // Close drawer
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IssueDetailScreen(issueId: notif.issueId!),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: notif.isUnread ? const Color(0xFFF0F9FF) : Colors.transparent,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: notifColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(_getNotificationIcon(notif.notificationType), size: 18, color: notifColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notif.title,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: notif.isUnread ? FontWeight.w700 : FontWeight.w600,
                                                      color: AppTheme.textDark,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _formatTimeAgo(notif.createdAt),
                                                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notif.body,
                                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (notif.isUnread) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primaryIndigo,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationBellAction extends StatelessWidget {
  const NotificationBellAction({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final unreadCount = notifProvider.unreadCount;

    return Builder(
      builder: (scaffoldContext) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppTheme.textDark),
              tooltip: 'Notifications',
              onPressed: () {
                Scaffold.of(scaffoldContext).openEndDrawer();
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.statusRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
