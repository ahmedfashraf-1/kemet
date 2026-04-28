import 'dart:io';

import 'package:flutter/material.dart';

class ProfileAvatarButton extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final String? avatarLocalPath;
  final String? avatarRemoteUrl;
  final int avatarCacheBuster;
  final VoidCallback onViewProfile;
  final VoidCallback onLogout;
  final bool isGuest;

  const ProfileAvatarButton({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    this.avatarLocalPath,
    this.avatarRemoteUrl,
    this.avatarCacheBuster = 0,
    required this.onViewProfile,
    required this.onLogout,
    this.isGuest = false,
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
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _PopupHeader(
            name: name,
            email: email,
            photoUrl: photoUrl,
            avatarLocalPath: avatarLocalPath,
            avatarRemoteUrl: avatarRemoteUrl,
            avatarCacheBuster: avatarCacheBuster,
            isGuest: isGuest,
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: onViewProfile,
          child: const _PopupAction(
            icon: Icons.person_outline,
            label: 'VIEW PROFILE',
            color: Color(0xFFCCCCCC),
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 1,
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Divider(color: Color(0xFF2A2A2A), height: 1),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: onLogout,
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
          Container(
            width: 38,
            height: 38,
            clipBehavior: Clip.antiAlias,
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
            child: _AvatarCircle(
              name: name,
              photoUrl: photoUrl,
              avatarLocalPath: avatarLocalPath,
              avatarRemoteUrl: avatarRemoteUrl,
              avatarCacheBuster: avatarCacheBuster,
              size: 38,
              fontSize: 16,
              isGuest: isGuest,
            ),
          ),
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

class _PopupHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final String? avatarLocalPath;
  final String? avatarRemoteUrl;
  final int avatarCacheBuster;
  final bool isGuest;

  const _PopupHeader({
    required this.name,
    required this.email,
    this.photoUrl,
    this.avatarLocalPath,
    this.avatarRemoteUrl,
    this.avatarCacheBuster = 0,
    this.isGuest = false,
  });

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
          Container(
            width: 44,
            height: 44,
            clipBehavior: Clip.antiAlias,
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
            child: _AvatarCircle(
              name: name,
              photoUrl: photoUrl,
              avatarLocalPath: avatarLocalPath,
              avatarRemoteUrl: avatarRemoteUrl,
              avatarCacheBuster: avatarCacheBuster,
              size: 44,
              fontSize: 20,
              isGuest: isGuest,
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

class _AvatarCircle extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? avatarLocalPath;
  final String? avatarRemoteUrl;
  final int avatarCacheBuster;
  final double size;
  final double fontSize;
  final bool isGuest;

  const _AvatarCircle({
    required this.name,
    required this.photoUrl,
    required this.avatarLocalPath,
    required this.avatarRemoteUrl,
    required this.avatarCacheBuster,
    required this.size,
    required this.fontSize,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return const CircleAvatar(
        backgroundColor: Color(0xFF1E1A0A),
        child: Icon(
          Icons.person,
          color: Color(0xFFD4AF37),
          size: 20,
        ),
      );
    }

    final normalizedPhotoUrl = _normalizeUrl(photoUrl);
    if (normalizedPhotoUrl != null) {
      return CircleAvatar(
        backgroundColor: const Color(0xFF1E1A0A),
        backgroundImage: NetworkImage(normalizedPhotoUrl),
      );
    }

    final hasLocal = avatarLocalPath != null &&
        avatarLocalPath!.isNotEmpty &&
        File(avatarLocalPath!).existsSync();

    if (hasLocal) {
      return CircleAvatar(
        backgroundColor: const Color(0xFF1E1A0A),
        backgroundImage: FileImage(File(avatarLocalPath!)),
      );
    }

    final hasRemote = avatarRemoteUrl != null && avatarRemoteUrl!.isNotEmpty;
    if (hasRemote) {
      final cacheBustedUrl = _cacheBustUrl(avatarRemoteUrl!, avatarCacheBuster);
      return CircleAvatar(
        backgroundColor: const Color(0xFF1E1A0A),
        backgroundImage: NetworkImage(cacheBustedUrl),
      );
    }

    return _fallbackInitial();
  }

  Widget _fallbackInitial() {
    final userInitial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'A';
    return CircleAvatar(
      backgroundColor: const Color(0xFF1E1A0A),
      child: Text(
        userInitial,
        style: TextStyle(
          color: const Color(0xFFC9A84C),
          fontSize: fontSize,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }

  String? _normalizeUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _cacheBustUrl(String url, int cacheBuster) {
    if (cacheBuster <= 0) {
      return url;
    }
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=$cacheBuster';
  }
}

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

