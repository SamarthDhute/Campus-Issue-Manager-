import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/issue_model.dart';
import 'package:smart_campus_issue_manager/features/operations/state/operations_provider.dart';

class InternalNotesWidget extends StatefulWidget {
  final IssueModel issue;

  const InternalNotesWidget({super.key, required this.issue});

  @override
  State<InternalNotesWidget> createState() => _InternalNotesWidgetState();
}

class _InternalNotesWidgetState extends State<InternalNotesWidget> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OperationsProvider>(
      builder: (context, provider, child) {
        final notes = provider.internalNotes;

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
                        Icon(Icons.lock_clock_rounded, color: AppTheme.statusAmber, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Staff-Only Internal Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.statusAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'RESTRICTED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.statusAmber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Note Input Box
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          hintText: 'Add private staff note (e.g. ordered replacement valve)...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: provider.isAddingNote
                          ? null
                          : () async {
                              final text = _noteController.text.trim();
                              if (text.isNotEmpty) {
                                final success = await provider.addInternalNote(widget.issue.id, text);
                                if (success && mounted) {
                                  _noteController.clear();
                                }
                              }
                            },
                      icon: provider.isAddingNote
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, size: 18),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Notes List
                if (notes.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.speaker_notes_off_rounded, size: 36, color: AppTheme.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 6),
                          const Text(
                            'No internal staff notes posted yet.',
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
                    itemCount: notes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.statusAmber.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.statusAmber.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      note.authorName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        note.authorRole,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                                      ),
                                    ),
                                  ],
                                ),
                                if (note.createdAt != null)
                                  Text(
                                    '${note.createdAt!.day}/${note.createdAt!.month} ${note.createdAt!.hour}:${note.createdAt!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              note.body,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.3),
                            ),
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
}
