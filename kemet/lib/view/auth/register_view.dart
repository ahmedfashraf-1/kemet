import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import 'package:kemet/core/animated_gold_button.dart';
import 'package:kemet/services/validation_service.dart';
import '../../../core/helpers/extensions.dart';
import '../../../core/routing/routes.dart';

class onRegisterScreen extends StatefulWidget {
  const onRegisterScreen({super.key});

  @override
  State<onRegisterScreen> createState() => _OnRegisterScreenState();
}

class _OnRegisterScreenState extends State<onRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCreateAccountPressed() {
    if (_formKey.currentState!.validate()) {
      context.pushReplacementNamed(Routes.login);
    }
  }

  OutlineInputBorder _goldBorder({double width = 1.0}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: AppColors.mainGold.withValues(alpha: 0.30),
          width: width,
        ),
      );

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: AppColors.mainGold.withValues(alpha: 0.35),
        fontSize: 14.sp,
      ),
      filled: true,
      fillColor: AppColors.mainGold.withValues(alpha: 0.06),
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: _goldBorder(),
      enabledBorder: _goldBorder(),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.lightGold, width: 1.2),
      ),
      errorBorder: _goldBorder(),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.lightGold, width: 1.2),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.lightGold.withValues(alpha: 0.65),
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildVisibilityIcon({
    required bool isVisible,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.mainGold.withValues(alpha: 0.55),
        size: 20.sp,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String) validator,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: (value) => validator(value ?? ''),
      onChanged: onChanged,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
      decoration: _inputDecoration(hint: hint, suffixIcon: suffixIcon),
      onFieldSubmitted: (_) {
        if (textInputAction == TextInputAction.done) {
          _onCreateAccountPressed();
        }
      },
    );
  }

  Widget _buildTopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Opacity(
          opacity: 0.7,
          child: Image.asset(
            'images/KEMET Logo.png',
            width: 150.w,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'KEMET',
          style: GoogleFonts.cormorant(
            textStyle: TextStyle(
              color: AppColors.mainGold,
              fontSize: 42.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(0, 5),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'JOIN THE LEGACY',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.lightGold,
            fontSize: 12.sp,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: 6.h),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.screenBackground,
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'images/onboarding1_bg.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.screenBackground.withValues(alpha: 0.25),
                  AppColors.screenBackground.withValues(alpha: 0.78),
                  AppColors.screenBackground.withValues(alpha: 1.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: topPadding + 4.h,
              bottom: 16.h,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: context.pop,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20.sp,
                    ),
                  ),

                  // Header
                  Center(child: _buildTopHeader()),
                  SizedBox(height: 10.h),

                  // Title
                  Text(
                    'Register',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Subtitle
                  Text(
                    'Begin your journey through history',
                    style: TextStyle(
                      color: AppColors.lightGold.withValues(alpha: 0.80),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Email
                  _buildLabeledField(
                    label: 'Email Address',
                    field: _buildFormField(
                      controller: _emailController,
                      hint: 'Kemet@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: ValidationService.validateEmail,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Password
                  _buildLabeledField(
                    label: 'Password',
                    field: _buildFormField(
                      controller: _passwordController,
                      hint: '••••••••',
                      textInputAction: TextInputAction.next,
                      obscureText: !_isPasswordVisible,
                      validator: ValidationService.validatePassword,
                      onChanged: (_) {
                        if (_confirmPasswordController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                      suffixIcon: _buildVisibilityIcon(
                        isVisible: _isPasswordVisible,
                        onPressed: () =>
                            setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Confirm Password
                  _buildLabeledField(
                    label: 'Confirm Password',
                    field: _buildFormField(
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      textInputAction: TextInputAction.done,
                      obscureText: !_isConfirmPasswordVisible,
                      validator: (value) =>
                          ValidationService.validateConfirmPassword(
                        _passwordController.text,
                        value ?? '',
                      ),
                      suffixIcon: _buildVisibilityIcon(
                        isVisible: _isConfirmPasswordVisible,
                        onPressed: () => setState(() =>
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Create Account button
                  AnimatedGoldButton(
                    onTap: _onCreateAccountPressed,
                    text: 'Create Account',
                  ),
                  SizedBox(height: 16.h),

                  // Sign In link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pushReplacementNamed(Routes.login),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.lightGold.withValues(alpha: 0.55),
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
                              style: GoogleFonts.cormorant(
                                textStyle: TextStyle(
                                  color: AppColors.mainGold,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

