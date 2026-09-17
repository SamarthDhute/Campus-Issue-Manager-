import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/state/auth_provider.dart';
import '../../dashboard/presentation/widgets/role_badge.dart';
import '../state/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  void _showEditProfileDialog(String currentName) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final profileProvider = context.watch<ProfileProvider>();
          final isSaving = profileProvider.isSaving;

          return AlertDialog(
            title: const Text('Update Profile'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Display Name',
                    hint: 'Your full name',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Display name cannot be empty';
                      }
                      if (val.trim().length < 2 || val.trim().length > 100) {
                        return 'Name must be between 2 and 100 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final success = await context
                            .read<ProfileProvider>()
                            .updateProfile(nameController.text.trim());

                        if (success && mounted) {
                          final updatedUser = context.read<ProfileProvider>().user;
                          if (updatedUser != null) {
                            context.read<AuthProvider>().updateUser(updatedUser);
                          }
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                              backgroundColor: AppTheme.statusGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.user ?? authProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final initials = user.displayName.isNotEmpty
        ? user.displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'SC';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        initials.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoleBadge(role: user.role),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details Information Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.business_rounded,
                      'Organization',
                      user.organizationName ?? 'Smart Campus University',
                    ),
                    const Divider(height: 24, color: AppTheme.borderSubtle),
                    _buildInfoRow(
                      Icons.badge_outlined,
                      'System Role',
                      user.role,
                    ),
                    const Divider(height: 24, color: AppTheme.borderSubtle),
                    _buildInfoRow(
                      Icons.groups_outlined,
                      'Assigned Teams',
                      user.teams.isNotEmpty ? user.teams.join(', ') : 'None assigned',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Edit Profile Button
              CustomButton(
                label: 'Edit Profile Name',
                icon: Icons.edit_outlined,
                onPressed: () => _showEditProfileDialog(user.displayName),
                isOutlined: true,
              ),
              const SizedBox(height: 12),

              // Logout Button
              CustomButton(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                color: AppTheme.statusRed,
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
