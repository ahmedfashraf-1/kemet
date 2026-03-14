import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import 'package:kemet/core/services/auth_service.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import 'package:kemet/core/widgets/auth_header.dart';
import 'package:kemet/core/widgets/auth_label.dart';
import 'package:kemet/core/widgets/auth_text_field.dart';
import 'package:kemet/core/services/validation_service.dart';
import '../../../core/helpers/extensions.dart';
import '../../../core/routing/routes.dart';

class onLoginScreen extends StatefulWidget {
  const onLoginScreen({super.key});

  @override
  State<onLoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<onLoginScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _submitted = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0F0D0B),
      body: Stack(
        children: [
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

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: 5.h),
                        const Spacer(flex: 3),

                        const AuthHeader(),

                        const Spacer(flex: 2),

                        _buildLabeledField(
                          label: 'Email Address',
                          field: AuthTextField(
                            controller: _emailController,
                            hintText: 'Kemet@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: ValidationService.validateEmail,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        _buildLabeledField(
                          label: 'Password',
                          field: AuthTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: ValidationService.validateLoginPassword,
                            onFieldSubmitted: (_) => _handleSignIn(),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.mainGold.withOpacity(0.55),
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.pushNamed(Routes.forgotPassword);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.lightGold.withOpacity(0.55),
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 28.h),

                        AnimatedGoldButton(
                          text: _isLoading ? 'SIGNING IN...' : 'SIGN IN',
                          onTap: _handleSignIn,
                        ),

                        SizedBox(height: 20.h),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.mainGold.withOpacity(0.20),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: AppColors.mainGold.withOpacity(0.40),
                                  fontSize: 11.sp,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.mainGold.withOpacity(0.20),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        _buildGoogleButton(),

                        const Spacer(flex: 2),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(Routes.onRegisterScreen);
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.lightGold.withOpacity(0.55),
                              ),
                              children: [
                                const TextSpan(
                                  text: "Don't have an account?  ",
                                ),
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

                        // Continue as guest
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(Routes.OnHomeScreen);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue as Guest',
                                style: TextStyle(
                                  color: AppColors.lightGold.withOpacity(0.40),
                                  fontSize: 13.sp,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward,
                                size: 14.sp,
                                color: AppColors.lightGold.withOpacity(0.40),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 35.h),
                      ],
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

  Widget _buildLabeledField({required String label, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthLabel(text: label),
        SizedBox(height: 8.h),
        field,
      ],
    );
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;
    
    setState(() => _submitted = true);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      debugPrint('[Login] Email/password sign-in triggered for ${_emailController.text.trim()}');
      final UserCredential credential = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      final User? user = credential.user;

      await _afterSignIn(user);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: () async {
        if (_isLoading) return;
        setState(() => _isLoading = true);
        try {
          debugPrint('[Login] Google sign-in triggered.');
          final result = await _authService.signInWithGoogle();
          final user = result?.user;
          if (user != null) {
            await _afterSignIn(user);
          } else {
            _showError('Could not read your email from Google Sign-In.');
          }
        } catch (e) {
          _showError(e.toString());
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: AppColors.mainGold.withOpacity(0.25)),
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

  /// Email/password sign-in routes to Verify Email.
  Future<void> _afterSignIn(User? user) async {
    if (user == null) {
      _showError('Unable to read current user. Please sign in again.');
      return;
    }

    debugPrint('[Login] Resolving post-sign-in verification for user: ${user.email}');
    final verificationResult = await _authService.resolveSignInVerification(
      signedInUser: user,
    );

    if (!mounted) return;

    if (verificationResult.isVerified) {
      debugPrint('[Login] User is verified or does not require verification. Navigating home.');
      context.pushReplacementNamed(Routes.home);
      return;
    }

    final normalizedEmail =
        verificationResult.user.email?.trim().toLowerCase() ??
        _emailController.text.trim().toLowerCase();

    if (verificationResult.verificationEmailStatus ==
        VerificationEmailSendStatus.sent) {
      _showError('Verification email sent to $normalizedEmail');
    } else if (verificationResult.verificationEmailStatus ==
        VerificationEmailSendStatus.skippedCooldown) {
      final remaining = _authService.getRemainingVerificationCooldown(
        user: verificationResult.user,
      );
      final seconds = remaining.inSeconds > 0 ? remaining.inSeconds : 1;
      _showError('Please wait $seconds seconds before requesting another email.');
    }

    debugPrint(
      '[Login] Navigating to verify screen. sendStatus=${verificationResult.verificationEmailStatus}, email=$normalizedEmail',
    );

    context.pushReplacementNamed(
      Routes.verifyEmailOtp,
      arguments: normalizedEmail,
    );
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.mainGold.withOpacity(0.9),
      ),
    );
  }
}
