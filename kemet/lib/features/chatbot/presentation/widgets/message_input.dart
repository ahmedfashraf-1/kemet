import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final bool isSending;
  final bool isBusy;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    this.isSending = false,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disableSend = isBusy;
    final bool disableImage = isBusy;

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.inputBackground.withOpacity(0.98),
            const Color(0xFF1A1511).withOpacity(0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.subtleGoldBorder.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _InputActionButton(
            icon: Icons.image_outlined,
            onTap: disableImage ? null : onPickImage,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) {
                if (!disableSend) {
                  onSend();
                }
              },
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 13.5.sp,
                height: 1.35,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about history, tickets, how to get there...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.72),
                  fontSize: 12.5.sp,
                  height: 1.35,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6.w),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disableSend ? null : onSend,
              borderRadius: BorderRadius.circular(999.r),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.mainGold, AppColors.darkGold],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainGold.withOpacity(0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSending
                      ? SizedBox(
                          key: const ValueKey<String>('loading'),
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textDarkOnGold,
                            ),
                          ),
                        )
                      : Icon(
                          key: const ValueKey<String>('send'),
                          Icons.send_rounded,
                          color: AppColors.textDarkOnGold,
                          size: 18.sp,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _InputActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.mainGold.withOpacity(0.14),
                AppColors.darkGold.withOpacity(0.3),
              ],
            ),
            border: Border.all(
              color: AppColors.mainGold.withOpacity(0.22),
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.mainGold,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
