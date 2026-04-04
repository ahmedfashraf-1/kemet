import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProfileAvatarButton extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onViewProfile;
  final VoidCallback onLogout;

  const ProfileAvatarButton({
    super.key,
    required this.name,
    required this.email,
    required this.onViewProfile,
    required this.onLogout,
  });

  void _showPopup(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset position =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu(
      context: context,
      color: const Color(0xFF171510),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFC9A84C).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      position: RelativeRect.fromLTRB(
        position.dx - 160,
        position.dy + button.size.height + 6,
        position.dx + button.size.width,
        0,
      ),
      items: [
        // ── User info header
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _PopupHeader(name: name, email: email),
        ),

        // ── View Profile
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: onViewProfile,
          child: const _PopupAction(
            icon: Icons.person_outline,
            label: 'VIEW PROFILE',
            color: Color(0xFFCCCCCC),
          ),
        ),

        // ── Divider
        const PopupMenuItem(
          enabled: false,
          height: 1,
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Divider(color: Color(0xFF2A2A2A), height: 1),
        ),

        // ── Logout
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: () => _logout(context),
          child: const _PopupAction(
            icon: Icons.logout,
            label: 'LOGOUT',
            color: Color(0xFFC04040),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Glow avatar circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1A0A),
              border: Border.all(
                color: const Color(0xFFC9A84C),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC9A84C).withOpacity(0.35),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFC9A84C).withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: Color(0xFFC9A84C),
                  fontSize: 16,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),

          // ── Online dot
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CAF79),
                border: Border.all(
                  color: const Color(0xFF0E0E0E),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Popup Header (User info)

class _PopupHeader extends StatelessWidget {
  final String name;
  final String email;

  const _PopupHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // mini avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1A0A),
              border: Border.all(color: const Color(0xFFC9A84C), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC9A84C).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: Color(0xFFC9A84C),
                  fontSize: 20,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Popup Action Row
class _PopupAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PopupAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/onLoginScreen',
    (route) => false,
  );
}