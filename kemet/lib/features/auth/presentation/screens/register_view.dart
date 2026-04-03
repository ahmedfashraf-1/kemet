import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/extensions.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import 'package:kemet/core/widgets/auth_header.dart';
import 'package:kemet/core/widgets/auth_label.dart';
import 'package:kemet/core/widgets/auth_text_field.dart';
import 'package:kemet/core/utils/services/validation_service.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _submitted = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onStateChange,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF0F0D0B),
        body: Stack(
          children: [
            // ── Background ────────────────────────────────────────
            Image.asset(
              'images/onboarding1_bg.png',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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

            // ── Content ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: topPadding,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Form(
                    key: _formKey,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Back button ────────────────────────
                          IconButton(
                            onPressed: context.pop,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                                minWidth: 32.w, minHeight: 32.h),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textPrimary,
                              size: 20.sp,
                            ),
                          ),

                          const Center(child: AuthHeader()),
                          SizedBox(height: 12.h),

                          // ── First Name ─────────────────────────
                          _buildLabeledField(
                            label: context.tr('first_name'),
                            field: AuthTextField(
                              controller: _firstNameController,
                              hintText: context.tr('enter_first_name'),
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  ValidationService.validateName(
                                value,
                                fieldName: 'First name',
                                translate: (key, {args}) => context.tr(key, args: args),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Last Name ──────────────────────────
                          _buildLabeledField(
                            label: context.tr('last_name'),
                            field: AuthTextField(
                              controller: _lastNameController,
                              hintText: context.tr('enter_last_name'),
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  ValidationService.validateName(
                                value,
                                fieldName: 'Last name',
                                translate: (key, {args}) => context.tr(key, args: args),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Email ──────────────────────────────
                          _buildLabeledField(
                            label: context.tr('email_address'),
                            field: AuthTextField(
                              controller: _emailController,
                              hintText: context.tr('enter_email_address'),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) => ValidationService.validateEmail(
                                value,
                                translate: (key, {args}) => context.tr(key, args: args),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Password ───────────────────────────
                          _buildLabeledField(
                            label: context.tr('password'),
                            field: AuthTextField(
                              controller: _passwordController,
                              hintText: context.tr('enter_password'),
                              textInputAction: TextInputAction.next,
                              obscureText: !_isPasswordVisible,
                              validator: (value) => ValidationService.validatePassword(
                                value,
                                translate: (key, {args}) => context.tr(key, args: args),
                              ),
                              onChanged: (_) {
                                if (_confirmPasswordController
                                    .text.isNotEmpty) {
                                  _formKey.currentState?.validate();
                                }
                              },
                              suffixIcon: _buildVisibilityIcon(
                                isVisible: _isPasswordVisible,
                                onPressed: () => setState(() =>
                                    _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Confirm Password ───────────────────
                          _buildLabeledField(
                            label: context.tr('confirm_password'),
                            field: AuthTextField(
                              controller: _confirmPasswordController,
                              hintText: context.tr('confirm_your_password'),
                              textInputAction: TextInputAction.done,
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) =>
                                  ValidationService.validateConfirmPassword(
                                _passwordController.text,
                                value ?? '',
                                translate: (key, {args}) => context.tr(key, args: args),
                              ),
                              suffixIcon: _buildVisibilityIcon(
                                isVisible: _isConfirmPasswordVisible,
                                onPressed: () => setState(
                                  () => _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible,
                                ),
                              ),
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // ── Create Account button ──────────────
                          AnimatedGoldButton(
                            text: isLoading
                                ? context.tr('creating_account')
                                : context.tr('create_account'),
                            onTap: isLoading
                                ? () {}
                                : () => _submit(context),
                          ),
                          SizedBox(height: 16.h),

                          // ── Sign In link ───────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: () => context.pushReplacementNamed(
                                  Routes.LoginView),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color:
                                        AppColors.lightGold.withOpacity(0.55),
                                  ),
                                  children: [
                                      TextSpan(
                                        text: '${context.tr('already_have_account')} ',),
                                    TextSpan(
                                      text: context.tr('sign_in'),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().signUp(
          _emailController.text,
          _passwordController.text,
          _firstNameController.text,
          _lastNameController.text,
        );
  }

  void _onStateChange(BuildContext context, AuthState state) {
    if (state is AuthNeedsEmailVerification) {
      _showSnackBar(
        context,
        'Account created successfully. Please verify your email.',
      );
      context.pushReplacementNamed(
        Routes.verifyEmailOtp,
        arguments: _emailController.text.trim().toLowerCase(),
      );
    } else if (state is AuthError) {
      _showSnackBar(context, state.message);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textDarkOnGold),
        ),
        backgroundColor: AppColors.mainGold.withOpacity(0.92),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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

  Widget _buildVisibilityIcon({
    required bool isVisible,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.mainGold.withOpacity(0.55),
        size: 20.sp,
      ),
    );
  }
}