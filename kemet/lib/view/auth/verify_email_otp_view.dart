import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import 'package:kemet/core/helpers/extensions.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/services/auth_service.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';

/// Email verification status screen shown after login.
class VerifyEmailOtpView extends StatefulWidget {
  const VerifyEmailOtpView({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<VerifyEmailOtpView> createState() => _VerifyEmailOtpViewState();
}

class _VerifyEmailOtpViewState extends State<VerifyEmailOtpView>
{
  final _authService = AuthService();
  bool _isChecking = false;
  bool _isSendingEmail = false;
  bool _didAutoSendOnOpen = false;
  Duration _remainingCooldown = Duration.zero;
  Timer? _cooldownTicker;

  String get _email =>
      widget.initialEmail?.trim().toLowerCase() ??
      FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ??
      '';

  bool get _isCooldownActive => _remainingCooldown > Duration.zero;

  String get _cooldownLabel {
    final seconds = _remainingCooldown.inSeconds;
    if (seconds <= 0) return '';
    return 'Resend available in ${seconds}s';
  }

  @override
  void initState() {
    super.initState();
    _syncCooldown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSendVerificationEmailOnOpen();
    });
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    super.dispose();
  }

  void _startCooldownTicker() {
    _cooldownTicker?.cancel();
    if (!_isCooldownActive) return;

    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncCooldown();
    });
  }

  void _syncCooldown() {
    final remaining = _authService.getRemainingVerificationCooldown();
    if (!mounted) {
      _remainingCooldown = remaining;
      return;
    }

    if (_remainingCooldown != remaining) {
      setState(() => _remainingCooldown = remaining);
    }

    if (remaining <= Duration.zero) {
      _cooldownTicker?.cancel();
      _cooldownTicker = null;
    } else if (_cooldownTicker == null || !_cooldownTicker!.isActive) {
      _startCooldownTicker();
    }
  }

  Future<void> _autoSendVerificationEmailOnOpen() async {
    if (_didAutoSendOnOpen) return;
    _didAutoSendOnOpen = true;
    await _sendVerificationEmail(showCooldownNotice: false);
  }

  Future<void> _sendVerificationEmail({bool showCooldownNotice = true}) async {
    if (_isSendingEmail) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    debugPrint(
      '[VerifyEmail] sendVerificationEmail triggered. userExists=${currentUser != null}, email=${currentUser?.email}',
    );

    if (currentUser == null) {
      _showMessage('Session expired. Please sign in again.');
      return;
    }

    if (_isCooldownActive) {
      if (showCooldownNotice) {
        _showMessage(_cooldownLabel);
      }
      return;
    }

    setState(() => _isSendingEmail = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        throw Exception('No logged in user');
      }

      if (refreshedUser.emailVerified) {
        debugPrint('[VerifyEmail] User already verified. Skipping email send.');
        _showMessage('Your email is already verified.');
        return;
      }

      final sendStatus = await _authService.sendVerificationEmail(
        user: refreshedUser,
        forceReload: false,
        respectCooldown: true,
      );

      debugPrint('[VerifyEmail] sendVerificationEmail result: $sendStatus');
      _syncCooldown();

      if (!mounted) return;

      if (sendStatus == VerificationEmailSendStatus.sent) {
        final targetEmail = refreshedUser.email?.trim() ?? _email;
        _showMessage('Verification email sent to $targetEmail');
        return;
      }

      if (sendStatus == VerificationEmailSendStatus.skippedCooldown) {
        if (showCooldownNotice) {
          _showMessage(_cooldownLabel.isEmpty ? 'Please wait before resending.' : _cooldownLabel);
        }
        return;
      }

      if (sendStatus == VerificationEmailSendStatus.skippedAlreadyVerified) {
        _showMessage('Your email is already verified.');
        return;
      }

      _showMessage('This sign-in method does not require email verification.');
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[VerifyEmail] FirebaseAuthException while sending verification email: code=${e.code}, message=${e.message}',
      );
      if (!mounted) return;
      _showMessage(e.message ?? 'Failed to send verification email.');
    } catch (e) {
      debugPrint('[VerifyEmail] Failed to send verification email: $e');
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSendingEmail = false);
      }
      _syncCooldown();
    }
  }

  Future<void> _verifyEmail() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw 'Session expired. Please sign in again.';
      }
      if (!mounted) return;

      if (user.emailVerified) {
        context.pushNamedAndRemoveUntil(
          Routes.home,
          predicate: (route) => false,
        );
        return;
      }

      _showMessage('Please verify your email first.');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.mainGold.withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F0D0B).withValues(alpha: 0.2),
                  const Color(0xFF0A0E14).withValues(alpha: 0.8),
                  const Color(0xFF1A120B).withValues(alpha: 1.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  // Back arrow → returns to Login
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () =>
                          context.pushReplacementNamed(Routes.login),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.h,
                      ),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),

                  Center(
                    child: Transform.translate(
                      offset: Offset(0, 10.h),
                      child: Opacity(
                        opacity: 0.85,
                        child: Container(
                          width: 110.w,
                          height: 110.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mainGold.withValues(alpha: 0.06),
                            border: Border.all(
                              color: AppColors.mainGold,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            size: 55.sp,
                            color: AppColors.mainGold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── Title ─────────────────────────────────────
                  Text(
                    'Verify Your Email',
                    style: GoogleFonts.cormorant(
                      color: AppColors.textPrimary,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // ── Subtitle ──────────────────────────────────
                  Text(
                    'We will send a verification email. After verifying, press the button below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.78),
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),

                  // ── Email address display ──────────────────────
                  if (_email.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      _email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mainGold.withValues(alpha: 0.9),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                  SizedBox(height: 28.h),

                  AnimatedGoldButton(
                    text: _isChecking ? 'CHECKING...' : 'Check Verification',
                    onTap: _isChecking ? () {} : _verifyEmail,
                  ),

                  SizedBox(height: 10.h),

                  TextButton(
                    onPressed: (_isSendingEmail || _isCooldownActive)
                        ? null
                        : () => _sendVerificationEmail(),
                    child: Text(
                      _isSendingEmail
                          ? 'Sending verification email...'
                          : _isCooldownActive
                          ? _cooldownLabel
                          : 'Resend Email',
                      style: TextStyle(
                        color: AppColors.mainGold.withValues(alpha: 0.85),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ── Back to Login ─────────────────────────────
                  TextButton(
                    onPressed: () => context.pushReplacementNamed(Routes.login),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.55),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
