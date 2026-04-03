import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/extensions.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import 'package:kemet/features/auth/domain/repositories/auth_repository.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_state.dart';

class VerifyEmailOtpView extends StatefulWidget {
  const VerifyEmailOtpView({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<VerifyEmailOtpView> createState() => _VerifyEmailOtpViewState();
}

class _VerifyEmailOtpViewState extends State<VerifyEmailOtpView> {
  // Cooldown is purely local UI state — the cubit doesn't need to know about it.
  Duration _remainingCooldown = Duration.zero;
  Timer? _cooldownTicker;
  bool _didAutoSend = false;

  String get _email =>
      widget.initialEmail?.trim().toLowerCase() ?? '';

  bool get _isCooldownActive => _remainingCooldown > Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didAutoSend) {
        _didAutoSend = true;
        _sendVerificationAndSyncCooldown();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    super.dispose();
  }

  Future<void> _syncCooldownFromRepository() async {
    final remaining = context
        .read<AuthRepository>()
        .getRemainingVerificationCooldown();
    if (!mounted) return;
    setState(() => _remainingCooldown = remaining);
  }

  Future<void> _sendVerificationAndSyncCooldown() async {
    await context.read<AuthCubit>().sendVerificationEmail();
    await _syncCooldownFromRepository();
    _startCooldownTicker();
  }

  void _startCooldownTicker() {
    _cooldownTicker?.cancel();
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingCooldown = context
            .read<AuthRepository>()
            .getRemainingVerificationCooldown();
      });
      if (_remainingCooldown == Duration.zero) {
        _cooldownTicker?.cancel();
      }
    });
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isChecking = state is AuthLoading;
                    final cooldownLabel = _remainingCooldown.inSeconds > 0
                        ? context.tr(
                            'resend_available_in',
                            args: {'seconds': '${_remainingCooldown.inSeconds}'},
                          )
                        : '';

                    return Column(
                      children: [
                        SizedBox(height: 8.h),

                        // ── Back button ────────────────────────
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            onPressed: () => context
                                .pushReplacementNamed(Routes.LoginView),
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
                        ),

                        const Spacer(flex: 2),

                        // ── Email icon ─────────────────────────
                        Transform.translate(
                          offset: Offset(0, 10.h),
                          child: Opacity(
                            opacity: 0.85,
                            child: Container(
                              width: 110.w,
                              height: 110.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.mainGold.withOpacity(0.06),
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
                        SizedBox(height: 20.h),

                        // ── Title ──────────────────────────────
                        Text(
                          context.tr('verify_email_title'),
                          style: GoogleFonts.cormorant(
                            color: AppColors.textPrimary,
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // ── Subtitle ───────────────────────────
                        Text(
                          context.tr('verify_email_subtitle'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                AppColors.textSecondary.withOpacity(0.78),
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                        ),

                        // ── Email address ──────────────────────
                        if (_email.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Text(
                            _email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.mainGold.withOpacity(0.9),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                        SizedBox(height: 28.h),

                        // ── Check Verification button ──────────
                        AnimatedGoldButton(
                          text: isChecking
                              ? context.tr('checking_upper')
                              : context.tr('check_verification'),
                          onTap: isChecking
                              ? () {}
                              : () => context
                                  .read<AuthCubit>()
                                  .checkEmailVerified(),
                        ),
                        SizedBox(height: 10.h),

                        // ── Resend button ──────────────────────
                        TextButton(
                          onPressed: (isChecking || _isCooldownActive)
                              ? null
                              : _resend,
                          child: Text(
                            isChecking
                                ? context.tr('checking')
                                : _isCooldownActive
                                    ? cooldownLabel
                                    : context.tr('resend_email'),
                            style: TextStyle(
                              color:
                                  AppColors.mainGold.withOpacity(0.85),
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // ── Back to Login ──────────────────────
                        TextButton(
                          onPressed: () => context.pushReplacementNamed(
                              Routes.LoginView),
                          child: Text(
                            context.tr('back_to_login'),
                            style: TextStyle(
                              color: AppColors.textSecondary
                                  .withOpacity(0.55),
                              fontSize: 13.sp,
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _resend() async {
    if (_isCooldownActive) return;
    await _sendVerificationAndSyncCooldown();
  }

  void _onStateChange(BuildContext context, AuthState state) {
    if (state is AuthEmailVerified) {
      context.pushNamedAndRemoveUntil(
        Routes.HomeScreen,
        predicate: (route) => false,
      );
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.mainGold.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
      );
    }
  }
}