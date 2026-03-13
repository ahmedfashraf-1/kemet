import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import 'package:kemet/core/animated_gold_button.dart';
import 'package:kemet/core/widgets/auth_header.dart';
import 'package:kemet/core/widgets/auth_label.dart';
import 'package:kemet/core/widgets/auth_text_field.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  Widget _buildLabeledField({
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthLabel(text: label),
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
      backgroundColor: const Color(0xFF0F0D0B),
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
                  const Color(0xFF0F0D0B).withOpacity(0.2),
                  const Color(0xFF0A0E14).withOpacity(0.8),
                  const Color(0xFF1A120B).withOpacity(1.0),
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
              top: topPadding,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                  const Center(child: AuthHeader()),
                  SizedBox(height: 12.h),


                  // First Name
                  _buildLabeledField(
                    label: 'First Name',
                    field: AuthTextField(
                      controller: _firstNameController,
                      hintText: 'Ahmed',
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Last Name
                  _buildLabeledField(
                    label: 'Last Name',
                    field: AuthTextField(
                      controller: _lastNameController,
                      hintText: 'Ashraf',
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Email
                  _buildLabeledField(
                    label: 'Email Address',
                    field: AuthTextField(
                      controller: _emailController,
                      hintText: 'Kemet@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: ValidationService.validateEmail,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Password
                  _buildLabeledField(
                    label: 'Password',
                    field: AuthTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
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
                    field: AuthTextField(
                      controller: _confirmPasswordController,
                      hintText: '••••••••',
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
                      onFieldSubmitted: (_) => _onCreateAccountPressed(),
                    ),
                  ),
                  SizedBox(height: 24.h),

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
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

