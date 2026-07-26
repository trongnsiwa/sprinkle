import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/sprinkle_button.dart';
import '../widgets/sprinkle_text_field.dart';
import '../widgets/sprinkle_toast.dart';

class EditProfileView extends StatefulWidget {
  final User user;
  final ProfileViewModel viewModel;

  const EditProfileView({
    super.key,
    required this.user,
    required this.viewModel,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late String _selectedAvatar;
  bool _isSaving = false;

  final List<String> _avatarEmojis = [
    '📸', '☕', '🥐', '✨', '🌿', '🍕', '🎨', '🚀', '⭐', '🐶'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _selectedAvatar = widget.user.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      SprinkleToast.show(
        context,
        'Name cannot be empty',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.viewModel.updateProfile(
      name: newName,
      bio: _bioController.text.trim(),
      avatar: _selectedAvatar,
    );

    if (mounted) {
      Navigator.maybePop(context);
      SprinkleToast.show(
        context,
        'Profile updated! ✨',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profile',
                  style: AppTypography.headlineMedium,
                ),
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Avatar Emoji Selector
            const Text('AVATAR', style: AppTypography.sectionTitle),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _avatarEmojis.map((emoji) {
                  final isSelected = _selectedAvatar == emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatar = emoji;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            SprinkleTextField(
              label: 'DISPLAY NAME',
              hint: 'Enter your name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            // Bio Field
            SprinkleTextField(
              label: 'BIO',
              hint: 'Share a quick bio...',
              controller: _bioController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Save Button
            SprinkleButton(
              label: 'Save Changes',
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
