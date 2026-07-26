import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../services/user_service.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';
import '../../widgets/sprinkle_button.dart';
import '../../widgets/sprinkle_text_field.dart';
import '../../widgets/sprinkle_toast.dart';
import '../main_tab_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedAvatar = '📸';
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _avatarEmojis = [
    '📸', '☕', '🥐', '✨', '🌿', '🍕', '🎨', '🚀', '⭐', '🐶'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      SprinkleToast.show(
        context,
        'Please fill in all fields',
        type: ToastType.error,
      );
      return;
    }

    if (password.length < 6) {
      SprinkleToast.show(
        context,
        'Password must be at least 6 characters',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.instance.signUp(
        email: email,
        password: password,
        name: name,
        avatar: _selectedAvatar,
      );
      await UserService.instance.getOrCreateCurrentUser();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainTabView()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        SprinkleToast.show(
          context,
          'Registration failed. Please try again.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: AppTypography.displayLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Join Sprinkle to share moments with friends.',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar Emoji Selector
              const Text('CHOOSE AVATAR', style: AppTypography.sectionTitle),
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

              SprinkleTextField(
                label: 'YOUR NAME',
                hint: 'Alex Rivers',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              SprinkleTextField(
                label: 'EMAIL',
                hint: 'alex@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              SprinkleTextField(
                label: 'PASSWORD',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: Colors.white60,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SprinkleButton(
                label: 'Create Account',
                isLoading: _isLoading,
                onPressed: _handleSignup,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
