import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/features/chatbot/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final bool isError = message.isError;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxBubbleWidth = constraints.maxWidth * 0.82;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.mainGold.withOpacity(0.98),
                          AppColors.darkGold.withOpacity(0.95),
                        ],
                      )
                    : isError
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF381F1B).withOpacity(0.98),
                              const Color(0xFF241412).withOpacity(0.98),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.cardBackground.withOpacity(0.98),
                              const Color(0xFF211B17).withOpacity(0.98),
                            ],
                          ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(isUser ? 20.r : 6.r),
                  bottomRight: Radius.circular(isUser ? 6.r : 20.r),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.white.withOpacity(0.18)
                      : isError
                          ? const Color(0xFFE4A48B).withOpacity(0.45)
                          : AppColors.mainGold.withOpacity(0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? AppColors.darkGold.withOpacity(0.28)
                        : isError
                            ? const Color(0xFFE4A48B).withOpacity(0.14)
                            : Colors.black.withOpacity(0.34),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildContent(isUser: isUser, isError: isError),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent({
    required bool isUser,
    required bool isError,
  }) {
    if (message.isTyping) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TypingDot(color: AppColors.mainGold),
          SizedBox(width: 4.w),
          const _TypingDot(color: AppColors.lightGold),
          SizedBox(width: 4.w),
          const _TypingDot(color: AppColors.mainGold),
          SizedBox(width: 10.w),
          Text(
            'Thinking...',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary.withOpacity(0.9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      );
    }

    if (isError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18.sp,
            color: const Color(0xFFFFC6A8),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                color: const Color(0xFFFFD7C3),
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    switch (message.type) {
      case MessageType.image:
        return _buildImageContent(isUser: isUser);
      case MessageType.text:
        return Text(
          message.text,
          style: GoogleFonts.inter(
            color: isUser ? AppColors.textDarkOnGold : AppColors.textPrimary,
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        );
    }
  }

  Widget _buildImageContent({required bool isUser}) {
    final String? imagePath = message.localFilePath;
    final bool hasText = message.text.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.file(
              File(imagePath),
              width: 220.w,
              height: 150.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 220.w,
                  height: 150.h,
                  color: Colors.black.withOpacity(0.25),
                  alignment: Alignment.center,
                  child: Text(
                    'Image not available',
                    style: TextStyle(
                      color: isUser
                          ? AppColors.textDarkOnGold
                          : AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                );
              },
            ),
          ),
        if (hasText) ...[
          SizedBox(height: 8.h),
          Text(
            message.text,
            style: GoogleFonts.inter(
              color: isUser ? AppColors.textDarkOnGold : AppColors.textPrimary,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _TypingDot extends StatelessWidget {
  final Color color;

  const _TypingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ],
      ),
    );
  }
}
