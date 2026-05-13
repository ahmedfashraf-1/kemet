import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:kemet/features/notifications/presentation/cubit/notification_state.dart';
import 'package:kemet/features/notifications/presentation/screens/notifications_screen.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  static const Color _goldColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<NotificationCubit>().markAllAsRead();
          Navigator.of(context).pushNamed(Routes.notificationsScreen);

      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, color: _goldColor, size: 24),
          BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (prev, curr) {
              final p = prev is NotificationLoaded ? prev.unreadCount : 0;
              final c = curr is NotificationLoaded ? curr.unreadCount : 0;
              return p != c;
            },
            builder: (context, state) {
              final count = state is NotificationLoaded ? state.unreadCount : 0;
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC04040),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}