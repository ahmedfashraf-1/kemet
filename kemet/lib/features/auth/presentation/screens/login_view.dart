import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/extensions.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import 'package:kemet/core/widgets/auth_header.dart';
import 'package:kemet/core/widgets/auth_label.dart';
import 'package:kemet/core/widgets/auth_text_field.dart';
import 'package:kemet/core/utils/services/validation_service.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return Form(
                        key: _formKey,
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              SizedBox(height: 5.h),
                              const Spacer(flex: 3),

                              const AuthHeader(),
                              const Spacer(flex: 2),

                              // ── Email ──────────────────────────
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
                              SizedBox(height: 16.h),

                              // ── Password ───────────────────────
                              _buildLabeledField(
                                label: 'Password',
                                field: AuthTextField(
                                  controller: _passwordController,
                                  hintText: '••••••••',
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  validator:
                                      ValidationService.validateLoginPassword,
                                  onFieldSubmitted: (_) =>
                                      _submit(context, isLoading),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color:
                                          AppColors.mainGold.withOpacity(0.55),
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),

                              // ── Forgot Password ────────────────
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      context.pushNamed(Routes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.lightGold
                                          .withOpacity(0.55),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 28.h),

                              // ── Sign In button ─────────────────
                              AnimatedGoldButton(
                                text: isLoading ? 'SIGNING IN...' : 'SIGN IN',
                                onTap: isLoading
                                    ? () {}
                                    : () => _submit(context, isLoading),
                              ),
                              SizedBox(height: 20.h),

                              // ── Divider ────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color:
                                          AppColors.mainGold.withOpacity(0.20),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: AppColors.mainGold
                                            .withOpacity(0.40),
                                        fontSize: 11.sp,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color:
                                          AppColors.mainGold.withOpacity(0.20),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // ── Google button ──────────────────
                              _buildGoogleButton(context, isLoading),
                              const Spacer(flex: 2),

                              // ── Register link ──────────────────
                              GestureDetector(
                                onTap: () => context
                                    .pushNamed(Routes.RegisterView),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.lightGold
                                          .withOpacity(0.55),
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: "Don't have an account?  "),
                                      TextSpan(
                                        text: 'Create Account',
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
                              SizedBox(height: 16.h),

                              // ── Guest ──────────────────────────
                              GestureDetector(
                                onTap: () =>
                                    context.pushNamed(Routes.HomeScreen),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue as Guest',
                                      style: TextStyle(
                                        color: AppColors.lightGold
                                            .withOpacity(0.40),
                                        fontSize: 13.sp,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 14.sp,
                                      color:
                                          AppColors.lightGold.withOpacity(0.40),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 35.h),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _submit(BuildContext context, bool isLoading) {
    if (isLoading) return;
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().signIn(
          _emailController.text,
          _passwordController.text,
        );
  }

  void _onStateChange(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.pushReplacementNamed(Routes.HomeScreen);
    } else if (state is AuthNeedsEmailVerification) {
      context.pushReplacementNamed(
        Routes.verifyEmailOtp,
        arguments: _emailController.text.trim().toLowerCase(),
      );
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.message,
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
  }

  Widget _buildLabeledField({
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthLabel(text: label),
        SizedBox(height: 8.h),
        field,
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context, bool isLoading) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () => context.read<AuthCubit>().signInWithGoogle(),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border:
              Border.all(color: AppColors.mainGold.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/google.png',
              width: 22.w,
              height: 22.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            Text(
              'Continue with Google',
              style: TextStyle(
                color: Colors.white.withOpacity(0.80),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}