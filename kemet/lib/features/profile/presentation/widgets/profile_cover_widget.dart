import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileCoverWidget extends StatefulWidget {
  final String name;
  final String? location;

  const ProfileCoverWidget({
    super.key,
    required this.name,
    this.location,
  });

  @override
  State<ProfileCoverWidget> createState() => _ProfileCoverWidgetState();
}

class _ProfileCoverWidgetState extends State<ProfileCoverWidget> {
  File? _image;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // ── Cover
        Container(
          height: 140,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1200),
                Color(0xFF2E1E02),
                Color(0xFF0E0E0E),
              ],
            ),
          ),
          child: const Center(
            child: Opacity(
              opacity: 0.10,
              child: Text(
                '𓂀',
                style: TextStyle(fontSize: 72, color: Color(0xFFC9A84C)),
              ),
            ),
          ),
        ),

        // ── Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC9A84C).withOpacity(0.4),
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

        // ── Edit cover button (القلم على اليمين)
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: GestureDetector(
            onTap: _pickImage, // ← نفس الفانكشن
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC9A84C).withOpacity(0.4),
                ),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFFC9A84C),
                size: 16,
              ),
            ),
          ),
        ),

        // ── Avatar
        Positioned(
          bottom: -44,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1A0A),
                  border: Border.all(
                    color: const Color(0xFFC9A84C),
                    width: 2.5,
                  ),
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC9A84C).withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: const Color(0xFFC9A84C).withOpacity(0.15),
                      blurRadius: 36,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: _image == null
                    ? Center(
                        child: Text(
                          widget.name.isNotEmpty
                              ? widget.name[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: Color(0xFFC9A84C),
                            fontSize: 32,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      )
                    : null,
              ),

              // ── Edit avatar badge (القلم جوا الأفاتار)
              GestureDetector(
                onTap: _pickImage, // ← نفس الفانكشن
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFC9A84C),
                    border: Border.all(
                      color: const Color(0xFF0E0E0E),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF111111),
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}