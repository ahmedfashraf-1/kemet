import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/extensions.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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

                      return IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.h),

                            // ── Back button ────────────────────
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.mainGold.withOpacity(0.08),
                                  borderRadius:
                                      BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color:
                                        AppColors.mainGold.withOpacity(0.25),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.mainGold,
                                  size: 18.sp,
                                ),
                              ),
                            ),

                            const Spacer(flex: 3),

                            // ── Logo ───────────────────────────
                            Center(
                              child: Transform.translate(
                                offset: Offset(0, 10.h),
                                child: Opacity(
                                  opacity: 0.7,
                                  child: Image.asset(
                                    'images/KEMET Logo.png',
                                    width: 130.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // ── Title ──────────────────────────
                            Center(
                              child: Text(
                                'Forgot Password',
                                style: GoogleFonts.cormorant(
                                  textStyle: TextStyle(
                                    color: AppColors.mainGold,
                                    fontSize: 38.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color:
                                            Colors.black.withOpacity(0.8),
                                        offset: const Offset(0, 5),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // ── Description ────────────────────
                            Center(
                              child: Text(
                                'Enter your email to receive a password reset link.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.lightGold
                                      .withOpacity(0.65),
                                  fontSize: 13.sp,
                                  height: 1.6,
                                ),
                              ),
                            ),

                            const Spacer(flex: 2),

                            // ── Form ───────────────────────────
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Email Address'),
                                  SizedBox(height: 8.h),
                                  _buildEmailField(isLoading),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // ── Send Reset Link button ──────────
                            AnimatedGoldButton(
                              text: isLoading
                                  ? 'SENDING...'
                                  : 'SEND RESET LINK',
                              onTap: isLoading
                                  ? () {}
                                  : () => _submit(context),
                            ),
                            SizedBox(height: 24.h),

                            // ── Back to Login link ──────────────
                            Center(
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.lightGold
                                          .withOpacity(0.55),
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Remember your password?  ',
                                      ),
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

                            const Spacer(flex: 3),
                            SizedBox(height: 24.h),
                          ],
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

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context
        .read<AuthCubit>()
        .sendPasswordReset(_emailController.text.trim());
  }

  void _onStateChange(BuildContext context, AuthState state) {
    if (state is AuthPasswordResetSent) {
      _showSnackBar(context, 'Password reset link sent to your email.');
      context.pop();
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

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.lightGold.withOpacity(0.65),
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      enabled: !isLoading,
      onFieldSubmitted: (_) => _submit(context),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email address is required.';
        }
        final emailRegex =
            RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Kemet@example.com',
        hintStyle: TextStyle(
          color: AppColors.mainGold.withOpacity(0.30),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: AppColors.mainGold.withOpacity(0.06),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: AppColors.mainGold.withOpacity(0.30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: AppColors.mainGold.withOpacity(0.30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              const BorderSide(color: AppColors.mainGold, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: Colors.redAccent.withOpacity(0.70)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: TextStyle(
          color: Colors.redAccent.withOpacity(0.85),
          fontSize: 11.sp,
        ),
      ),
    );
  }
}