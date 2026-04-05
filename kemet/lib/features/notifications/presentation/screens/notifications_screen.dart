import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _bgColor     = Color(0xFF0E0E0E);
  static const Color _goldColor   = Color(0xFFD4AF37);
  static const Color _cardColor   = Color(0xFF141108);
  static const Color _borderColor = Color(0xFF2E2810);

  @override
  void initState() {
    super.initState();
    
  //  WidgetsBinding.instance.addPostFrameCallback((_) => _markAllAsRead());
  @override
void dispose() {
  _markAllAsRead();
  super.dispose();
}
  }

  Future<void> _markAllAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    try {
      final unread = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      if (unread.docs.isEmpty) return;
  
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(
            child: Text('Not logged in',
                style: TextStyle(color: Colors.white54))),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: _goldColor.withOpacity(0.4), width: 0.5),
            ),
            child: const Icon(Icons.chevron_left, color: _goldColor),
          ),
        ),
        title: Text('NOTIFICATIONS',
            style: GoogleFonts.cinzel(
                color: _goldColor, fontSize: 14.sp, letterSpacing: 3)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _goldColor));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(snapshot.error.toString(),
                    style:
                        TextStyle(color: Colors.white54, fontSize: 13.sp)));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('𓂀',
                      style:
                          TextStyle(fontSize: 48, color: Color(0xFF333333))),
                  SizedBox(height: 12.h),
                  Text('No notifications yet',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 13.sp)),
                ],
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: docs.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final notif = docs[index];
              final isRead = notif['isRead'] as bool? ?? true;

              return GestureDetector(
                onTap: () {
                  notif.reference.update({'isRead': true});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationDetailsScreen(
                        title: notif['title'] as String?,
                        body: notif['body'] as String?,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isRead
                          ? _borderColor
                          : _goldColor.withOpacity(0.5),
                      width: isRead ? 0.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _bgColor,
                              border: Border.all(
                                  color: _goldColor.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: _goldColor, size: 18),
                          ),
                          if (!isRead)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFC04040),
                                    shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['title'] ?? '',
                              style: TextStyle(
                                color:
                                    isRead ? Colors.white70 : Colors.white,
                                fontSize: 13.sp,
                                fontWeight: isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              notif['body'] ?? '',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 11.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 6,
                          height: 6,
                          margin: EdgeInsets.only(left: 8.w),
                          decoration: const BoxDecoration(
                              color: _goldColor, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}