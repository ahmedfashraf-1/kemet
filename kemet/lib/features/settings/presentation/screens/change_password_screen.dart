import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/utils/services/validation_service.dart';
import 'package:kemet/features/settings/presentation/cubit/password_reset_cubit.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final FocusNode _emailFocusNode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? '',
    );
    _emailFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          _emailController.clear();
          if (!mounted) return;
          _showSnackBar(
            context,
            context.tr('password_reset_sent'),
            isError: false,
          );
        } else if (state is PasswordResetError) {
          if (!mounted) return;
          _showSnackBar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is PasswordResetLoading;

        return Scaffold(
          backgroundColor: SettingsVisuals.pageBackground,
          appBar: AppBar(
            backgroundColor: SettingsVisuals.pageBackground,
            elevation: 0,
            centerTitle: true,
            title: Text(
              context.tr('change_password').toUpperCase(),
              style: GoogleFonts.cinzel(
                color: AppColors.mainGold,
                fontSize: 18.sp,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 320),
                    tween: Tween(begin: 0.96, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, scale, child) {
                      final safeOpacity =
                          ((scale - 0.96) / 0.04).clamp(0.0, 1.0).toDouble();

                      return Opacity(
                        opacity: safeOpacity,
                        child: Transform.scale(scale: scale, child: child),
                      );
                    },
                    child: PremiumCard(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(18.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48.w,
                                    height: 48.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      color: const Color(0xFFC9A34E).withValues(alpha: 0.10),
                                      border: Border.all(
                                        color: const Color(0xFFC9A34E).withValues(alpha: 0.30),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.lock_reset_rounded,
                                      color: AppColors.mainGold,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.tr('reset_password_title'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          context.tr('reset_password_desc'),
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.68),
                                            fontSize: 13.sp,
                                            height: 1.45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  autofocus: true,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(context),
                                  validator: ValidationService.validateEmail,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: context.tr('email_address'),
                                    labelStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.64),
                                    ),
                                    hintText: context.tr('enter_email'),
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.35),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.04),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 16.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.10),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.10),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFC9A34E),
                                        width: 1.2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 22.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : () => _submit(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC9A34E),
                                    foregroundColor: const Color(0xFF151008),
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 15.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isLoading
                                        ? SizedBox(
                                            key: const ValueKey('loading'),
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                const Color(0xFF151008).withValues(alpha: 0.92),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            key: const ValueKey('text'),
                                            context.tr('send_reset_link'),
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                context.tr('reset_password_hint'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.54),
                                  fontSize: 11.sp,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
    context.read<PasswordResetCubit>().sendResetLink(_emailController.text);
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.redAccent.withValues(alpha: 0.95)
            : AppColors.mainGold.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
