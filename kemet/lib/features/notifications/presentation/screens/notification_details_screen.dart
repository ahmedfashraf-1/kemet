import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationDetailsScreen extends StatefulWidget {
  final String? docId;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;

  const NotificationDetailsScreen({
    this.docId,
    super.key,
    this.title,
    this.body,
    this.data,
  });

  @override
  State<NotificationDetailsScreen> createState() => _NotificationDetailsScreenState();
}

  
class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {

  static const Color _bgColor     = Color(0xFF0E0E0E);
  static const Color _goldColor   = Color(0xFFD4AF37);
  static const Color _cardColor   = Color(0xFF141108);
  static const Color _borderColor = Color(0xFF2E2810);


  // @override
  // void initState() {
  //   super.initState();
  //    WidgetsBinding.instance.addPostFrameCallback((_) {
  //   try {
  //     if (widget.docId != null) {
  //       context.read<NotificationCubit>().markOneAsRead(widget.docId!);
  //     }
  //   } catch (_) {}
  // });
  // }
    

    @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      context.read<NotificationCubit>().markAllAsRead();
    } catch (_) {}
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: GestureDetector(
           onTap: () {
    Navigator.pushNamed(
      context,
      Routes.notificationsScreen,
    );
  },
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _goldColor.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: _goldColor,
            ),
          ),
        ),
        title: Text(
          'NOTIFICATION',
          style: GoogleFonts.cinzel(
            color: _goldColor,
            fontSize: 14.sp,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _cardColor,
                  border: Border.all(color: _goldColor.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: _goldColor.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: _goldColor,
                  size: 28,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TITLE',
                      style: TextStyle(
                          color: _goldColor, fontSize: 10.sp, letterSpacing: 2)),
                  SizedBox(height: 8.h),
                  Text(widget.title ?? 'No title',
                      style: GoogleFonts.cormorant(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MESSAGE',
                      style: TextStyle(
                          color: _goldColor, fontSize: 10.sp, letterSpacing: 2)),
                  SizedBox(height: 8.h),
                  Text(widget.body ?? 'No message',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14.sp,
                          height: 1.6)),
                ],
              ),
            ),
            if (widget.data != null && widget.data!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATA',
                        style: TextStyle(
                            color: _goldColor,
                            fontSize: 10.sp,
                            letterSpacing: 2)),
                    SizedBox(height: 8.h),
                    ...widget.data!.entries.map(
                      (e) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Text('${e.key}: ',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12.sp)),
                            Text('${e.value}',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}