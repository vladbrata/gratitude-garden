import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../authentication/firebase_auth.dart';
import '../theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _isSubmitting = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;

  // Controllers for Login Form
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // Controllers for Register Form
  final _registerFirstNameController = TextEditingController();
  final _registerLastNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  // Focus nodes to track focus state and animate icons/borders
  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _registerFirstNameFocus = FocusNode();
  final _registerLastNameFocus = FocusNode();
  final _registerEmailFocus = FocusNode();
  final _registerPasswordFocus = FocusNode();
  final _registerConfirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add listeners to force rebuild when focus changes (to animate colors)
    _loginEmailFocus.addListener(_onFocusChange);
    _loginPasswordFocus.addListener(_onFocusChange);
    _registerFirstNameFocus.addListener(_onFocusChange);
    _registerLastNameFocus.addListener(_onFocusChange);
    _registerEmailFocus.addListener(_onFocusChange);
    _registerPasswordFocus.addListener(_onFocusChange);
    _registerConfirmPasswordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerFirstNameController.dispose();
    _registerLastNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();

    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _registerFirstNameFocus.dispose();
    _registerLastNameFocus.dispose();
    _registerEmailFocus.dispose();
    _registerPasswordFocus.dispose();
    _registerConfirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submitForm() async {
    final formKey = _isLogin ? _loginFormKey : _registerFormKey;
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final authService = AuthService();
        if (_isLogin) {
          await authService.login(
            email: _loginEmailController.text,
            password: _loginPasswordController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Logged in successfully! Welcome to your Garden.',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                backgroundColor: const Color(0xFF54AA1D),
              ),
            );
          }
        } else {
          await authService.registerUser(
            email: _registerEmailController.text,
            password: _registerPasswordController.text,
            firstName: _registerFirstNameController.text.trim(),
            lastName: _registerLastNameController.text.trim(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account cultivated successfully! Welcome.',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                backgroundColor: const Color(0xFF54AA1D),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString(), style: GoogleFonts.plusJakartaSans()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: ZenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Section
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Main Glassmorphic Auth Card
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _buildAuthCard(),
                  ),
                  const SizedBox(height: 48),

                  // Bottom Visual Grounding Ornament
                  _buildBottomOrnament(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: OverflowBox(
            maxHeight: 280,
            minHeight: 280,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/logo/gratitude-garden.svg',
              height: 280,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Slogan
        Opacity(
          opacity: 0.8,
          child: Text(
            'Grow your forest of thankfulness.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFC0CAB4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x663D3A3A), // rgba(61, 58, 58, 0.4)
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0x1AFAF4F4), // rgba(250, 244, 244, 0.1)
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom Auth Toggle Tabs
              _buildAuthToggles(),
              const SizedBox(height: 32),

              // Animated Forms switcher
              AnimatedCrossFade(
                firstChild: _buildLoginForm(),
                secondChild: _buildRegisterForm(),
                crossFadeState: _isLogin
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                sizeCurve: Curves.easeInOut,
              ),
              const SizedBox(height: 32),

              // Footer links
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthToggles() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x80100E0E), // rgba(16, 14, 14, 0.5)
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          // Login tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isLogin) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isLogin = true;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLogin
                      ? const Color(0xFF54AA1D)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: _isLogin
                          ? const Color(0xFF143700)
                          : const Color(0xFFC0CAB4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Register tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isLogin) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isLogin = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLogin
                      ? const Color(0xFF54AA1D)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: !_isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Register',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: !_isLogin
                          ? const Color(0xFF143700)
                          : const Color(0xFFC0CAB4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Opacity(
      opacity: _isLogin ? 1.0 : 0.0,
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            // Email field
            _buildTextField(
              controller: _loginEmailController,
              focusNode: _loginEmailFocus,
              hintText: 'Email Address',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            _buildTextField(
              controller: _loginPasswordController,
              focusNode: _loginPasswordFocus,
              hintText: 'Password',
              icon: Icons.lock,
              obscureText: _obscureLoginPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFFC0CAB4),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(
              text: _isSubmitting ? 'Seeding...' : 'Enter Your Garden',
              onPressed: _isSubmitting ? null : _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Opacity(
      opacity: !_isLogin ? 1.0 : 0.0,
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            // First Name
            _buildTextField(
              controller: _registerFirstNameController,
              focusNode: _registerFirstNameFocus,
              hintText: 'First Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Last Name
            _buildTextField(
              controller: _registerLastNameController,
              focusNode: _registerLastNameFocus,
              hintText: 'Last Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            _buildTextField(
              controller: _registerEmailController,
              focusNode: _registerEmailFocus,
              hintText: 'Email Address',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Create Password
            _buildTextField(
              controller: _registerPasswordController,
              focusNode: _registerPasswordFocus,
              hintText: 'Create Password',
              icon: Icons.lock,
              obscureText: _obscureRegisterPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFFC0CAB4),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureRegisterPassword = !_obscureRegisterPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please create a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildTextField(
              controller: _registerConfirmPasswordController,
              focusNode: _registerConfirmPasswordFocus,
              hintText: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: _obscureRegisterConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFFC0CAB4),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureRegisterConfirmPassword =
                        !_obscureRegisterConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please re-enter your password';
                }
                if (value != _registerPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(
              text: _isSubmitting ? 'Seeding...' : 'Cultivate Your Garden',
              onPressed: _isSubmitting ? null : _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isFocused = focusNode.hasFocus;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.notoSerif(
        fontSize: 16,
        color: const Color(0xFFFAF4F4),
      ),
      cursorColor: const Color(0xFF82DC4D),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.notoSerif(
          fontSize: 16,
          color: const Color(0x80C0CAB4), // 50% opacity of #c0cab4
        ),
        prefixIcon: Icon(
          icon,
          color: isFocused ? const Color(0xFF82DC4D) : const Color(0xFFC0CAB4),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFFFAF4F4).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF82DC4D), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          color: Colors.redAccent,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF54AA1D),
          disabledBackgroundColor: const Color(
            0xFF54AA1D,
          ).withValues(alpha: 0.6),
          foregroundColor: const Color(0xFFFAF4F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF54AA1D).withValues(alpha: 0.3),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        // Forgot password
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Password reset link requested.',
                  style: GoogleFonts.plusJakartaSans(),
                ),
              ),
            );
          },
          child: Text(
            'Forgot password?',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFC0CAB4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Divider
        Container(
          width: 48,
          height: 1,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 16),

        // Social Login Section
        Text(
          'or continue with',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0x99C0CAB4),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                logoAsset: 'assets/images/google_logo.png',
                label: 'Google',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Connecting with Google...',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      backgroundColor: const Color(0xFF54AA1D),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                logoAsset: 'assets/images/apple_logo.png',
                label: 'Apple',
                logoColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Connecting with Apple ID...',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      backgroundColor: const Color(0xFF54AA1D),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String logoAsset,
    required String label,
    Color? logoColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0x1F100E0E),
          foregroundColor: const Color(0xFFFAF4F4),
          side: BorderSide(
            color: const Color(0xFFFAF4F4).withValues(alpha: 0.15),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(logoAsset, height: 20, width: 20, color: logoColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFAF4F4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOrnament() {
    return Opacity(
      opacity: 0.20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.psychology_alt, color: Color(0xFF82DC4D), size: 24),
          SizedBox(width: 16),
          Icon(Icons.spa, color: Color(0xFF82DC4D), size: 24),
          SizedBox(width: 16),
          Icon(Icons.nature, color: Color(0xFF82DC4D), size: 24),
        ],
      ),
    );
  }
}
