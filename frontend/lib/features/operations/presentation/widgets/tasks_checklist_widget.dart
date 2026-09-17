import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../issues/data/models/issue_model.dart';
import '../../operations/data/models/operation_models.dart';
import '../../operations/state/operations_provider.dart';

class TasksChecklistWidget extends StatefulWidget {
  final IssueModel issue;
  final bool isStaff;

  const TasksChecklistWidget({
    super.key,
    required this.issue,
    required this.isStaff,
  });

  @override
  State<TasksChecklistWidget> createState() => _TasksChecklistWidgetState();
}

class _TasksChecklistWidgetState extends State<TasksChecklistWidget> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  bool _isAddingTask = false;

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog(BuildContext context, OperationsProvider provider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.add_task, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Add Operational Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskTitleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'e.g. Inspect main water valve',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _taskDescController,
              decoration: const InputDecoration(
                labelText: 'Description / Instructions',
                hintText: 'Details for field technician...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _taskTitleController.text.trim();
              final desc = _taskDescController.text.trim();
              if (title.isNotEmpty) {
                Navigator.of(dialogCtx).pop();
                final success = await provider.createTask(
                  widget.issue.id,
                  title: title,
                  description: desc.isNotEmpty ? desc : null,
                );
                _taskTitleController.clear();
                _taskDescController.clear();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task added successfully'),
                      backgroundColor: AppTheme.statusGreen,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OperationsProvider>(
      builder: (context, provider, child) {
        final tasks = provider.tasks;
        final progress = provider.taskProgress;

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
                    Row(
                      children: [
                        const Icon(Icons.checklist_rounded, color: AppTheme.primaryBlue, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Execution Checklist (${provider.completedTasksCount}/${tasks.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    if (widget.isStaff)
                      TextButton.icon(
                        onPressed: () => _showAddTaskDialog(context, provider),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Task'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress Bar
                if (tasks.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppTheme.borderSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0 ? AppTheme.statusGreen : AppTheme.primaryIndigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                if (tasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.task_alt, size: 36, color: AppTheme.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 6),
                          const Text(
                            'No operational sub-tasks created yet.',
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
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderSubtle),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return CheckboxListTile(
                        value: task.isCompleted,
                        onChanged: widget.isStaff ? (_) => provider.toggleTaskStatus(task) : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppTheme.statusGreen,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted ? AppTheme.textMuted : AppTheme.textDark,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description != null && task.description!.isNotEmpty)
                              Text(
                                task.description!,
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (task.ownerName != null) ...[
                                  const Icon(Icons.person_outline, size: 12, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.ownerName!,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: task.isCompleted
                                        ? AppTheme.statusGreen.withOpacity(0.1)
                                        : AppTheme.statusAmber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: task.isCompleted ? AppTheme.statusGreen : AppTheme.statusAmber,
                                    ),
                                  ),
                                ),
                              ],
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
