import 'dart:io';
import 'package:flutter/material.dart';

class ProfileCoverWidget extends StatefulWidget {
  final String name;
  final String? location;
  final File? imageFile;
  final String? avatarRemoteUrl;
  final int avatarCacheBuster;
  final VoidCallback onEditProfileImage;
  final bool isEditable;

  const ProfileCoverWidget({
    super.key,
    required this.name,
    this.location,
    this.imageFile,
    this.avatarRemoteUrl,
    this.avatarCacheBuster = 0,
    required this.onEditProfileImage,
    this.isEditable = true,
  });

  @override
  State<ProfileCoverWidget> createState() => _ProfileCoverWidgetState();
}

class _ProfileCoverWidgetState extends State<ProfileCoverWidget> {
  @override
  Widget build(BuildContext context) {
    final coverHeight = 190.0;
    final avatarSize = 118.0;
    final topInset = MediaQuery.of(context).padding.top;
    final effectiveImage = widget.imageFile;
    final hasRemote = widget.avatarRemoteUrl != null &&
        widget.avatarRemoteUrl!.trim().isNotEmpty;
    final ImageProvider? avatarProvider = effectiveImage != null
        ? FileImage(effectiveImage)
        : (hasRemote
            ? NetworkImage(
                _cacheBustUrl(
                  widget.avatarRemoteUrl!.trim(),
                  widget.avatarCacheBuster,
                ),
              )
            : const AssetImage('images/logo.png'));
    final totalHeight = coverHeight + (avatarSize / 2) - 8;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Premium cover background
          Container(
            height: coverHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A1C07), Color(0xFF171104), Color(0xFF0E0E0E)],
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFC9A84C).withOpacity(0.20),
                  width: 0.6,
                ),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF0E0E0E).withOpacity(0.72),
                      ],
                    ),
                  ),
                ),
                const Center(
                  child: Opacity(
                    opacity: 0.11,
                    child: Text(
                      '𓂀',
                      style: TextStyle(fontSize: 80, color: Color(0xFFC9A84C)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: topInset + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF151207).withOpacity(0.55),
                  border: Border.all(
                    color: const Color(0xFFC9A84C).withOpacity(0.45),
                  ),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFFC9A84C),
                  size: 20,
                ),
              ),
            ),
          ),

          // Avatar with glow and circular clipping
          Positioned(
            bottom: -(avatarSize / 2) + 8,
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC9A84C),
                        width: 2.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC9A84C).withOpacity(0.30),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: const Color(0xFFC9A84C).withOpacity(0.12),
                          blurRadius: 38,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: widget.isEditable ? widget.onEditProfileImage : null,
                      child: Padding(
                        padding: const EdgeInsets.all(3.2),
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFF1E1A0A),
                          backgroundImage: avatarProvider,
                          child: null,
                        ),
                      ),
                    ),
                  ),
                  if (widget.isEditable)
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: InkWell(
                        onTap: widget.onEditProfileImage,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFC9A84C),
                            border: Border.all(
                              color: const Color(0xFF0E0E0E),
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC9A84C).withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF111111),
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cacheBustUrl(String url, int cacheBuster) {
    if (cacheBuster <= 0) {
      return url;
    }
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=$cacheBuster';
  }
}
