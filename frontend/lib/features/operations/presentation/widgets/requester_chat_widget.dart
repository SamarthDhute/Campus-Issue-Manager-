import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/features/auth/state/auth_provider.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/issue_model.dart';
import 'package:smart_campus_issue_manager/features/operations/state/operations_provider.dart';

class RequesterChatWidget extends StatefulWidget {
  final IssueModel issue;

  const RequesterChatWidget({super.key, required this.issue});

  @override
  State<RequesterChatWidget> createState() => _RequesterChatWidgetState();
}

class _RequesterChatWidgetState extends State<RequesterChatWidget> {
  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthProvider>(context).currentUser;

    return Consumer<OperationsProvider>(
      builder: (context, provider, child) {
        final messages = provider.messages;

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
                const Row(
                  children: [
                    Icon(Icons.forum_rounded, color: AppTheme.primaryBlue, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Requester & Operations Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Messages Container
                if (messages.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 36, color: AppTheme.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 6),
                          const Text(
                            'No messages exchanged yet. Start the conversation!',
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
                    itemCount: messages.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = authUser != null && authUser.id == msg.senderId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? AppTheme.primaryBlue : AppTheme.backgroundLight,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 2),
                              bottomRight: Radius.circular(isMe ? 2 : 12),
                            ),
                            border: Border.all(
                              color: isMe ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isMe ? 'You' : msg.senderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isMe ? Colors.white : AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '• ${msg.senderRole}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white70 : AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isMe ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (msg.createdAt != null)
                                Text(
                                  '${msg.createdAt!.hour}:${msg.createdAt!.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isMe ? Colors.white60 : AppTheme.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 14),

                // Message input box
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message to the team or requester...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onSubmitted: (_) async {
                          final text = _msgController.text.trim();
                          if (text.isNotEmpty) {
                            final success = await provider.sendMessage(widget.issue.id, text);
                            if (success && mounted) {
                              _msgController.clear();
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: provider.isSendingMessage
                          ? null
                          : () async {
                              final text = _msgController.text.trim();
                              if (text.isNotEmpty) {
                                final success = await provider.sendMessage(widget.issue.id, text);
                                if (success && mounted) {
                                  _msgController.clear();
                                }
                              }
                            },
                      icon: provider.isSendingMessage
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, size: 18),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
