import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/core/widgets/custom_button.dart';
import 'package:smart_campus_issue_manager/core/widgets/custom_text_field.dart';
import 'package:smart_campus_issue_manager/features/resolution/presentation/widgets/media_attachment_picker.dart';
import 'package:smart_campus_issue_manager/features/resolution/state/resolution_provider.dart';
import '../../state/category_provider.dart';
import '../../state/issue_provider.dart';

class CreateIssueScreen extends StatefulWidget {
  const CreateIssueScreen({super.key});

  @override
  State<CreateIssueScreen> createState() => _CreateIssueScreenState();
}

class _CreateIssueScreenState extends State<CreateIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedPriority = 'MEDIUM';
  List<PickedMediaItem> _pickedFiles = [];
  bool _isUploadingAttachments = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an issue category'),
          backgroundColor: AppTheme.statusRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final issueProvider = context.read<IssueProvider>();
    final resolutionProvider = context.read<ResolutionProvider>();

    final newIssue = await issueProvider.createIssue(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      location: _locationController.text.trim(),
      priority: _selectedPriority,
    );

    if (newIssue != null && mounted) {
      if (_pickedFiles.isNotEmpty) {
        setState(() => _isUploadingAttachments = true);
        for (final file in _pickedFiles) {
          await resolutionProvider.uploadAttachment(
            issueId: newIssue.id,
            fileBytes: file.bytes,
            fileName: file.fileName,
          );
        }
        if (mounted) setState(() => _isUploadingAttachments = false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Issue ${newIssue.issueNumber} submitted successfully with ${_pickedFiles.length} attachments!'),
            backgroundColor: AppTheme.statusGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else if (mounted && issueProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(issueProvider.errorMessage!),
          backgroundColor: AppTheme.statusRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final issueProvider = context.watch<IssueProvider>();
    final categories = categoryProvider.categories;
    final isBusy = issueProvider.isSubmitting || _isUploadingAttachments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Campus Issue'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderSubtle, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category Dropdown
                  const Text(
                    'Issue Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Select category (e.g. Water, Electrical, IT)'),
                    decoration: const InputDecoration(),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 18),

                  // Location
                  CustomTextField(
                    controller: _locationController,
                    label: 'Campus Location / Room',
                    hint: 'e.g. Hostel Block B, Room 204 or Lab 3',
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please specify the exact location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Issue Title',
                    hint: 'Brief summary of the issue',
                    prefixIcon: const Icon(Icons.title_rounded, size: 20),
                    validator: (val) {
                      if (val == null || val.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Priority Selector
                  const Text(
                    'Priority Level',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip('LOW', 'Low', AppTheme.statusGreen),
                      const SizedBox(width: 8),
                      _buildPriorityChip('MEDIUM', 'Medium', AppTheme.statusAmber),
                      const SizedBox(width: 8),
                      _buildPriorityChip('HIGH', 'High', AppTheme.statusRed),
                      const SizedBox(width: 8),
                      _buildPriorityChip('URGENT', 'Urgent', const Color(0xFF991B1B)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Detailed Description',
                    hint: 'Provide details about the issue so staff can investigate quickly...',
                    maxLines: 4,
                    validator: (val) {
                      if (val == null || val.trim().length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Media Attachment Picker (Camera & Gallery)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: MediaAttachmentPicker(
                      onFilesChanged: (files) {
                        setState(() {
                          _pickedFiles = files;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  CustomButton(
                    label: _isUploadingAttachments
                        ? 'Uploading photos & creating ticket...'
                        : 'Submit Campus Issue',
                    icon: Icons.send_rounded,
                    isLoading: isBusy,
                    onPressed: isBusy ? null : _submitIssue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = _selectedPriority == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPriority = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : AppTheme.borderSubtle,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
