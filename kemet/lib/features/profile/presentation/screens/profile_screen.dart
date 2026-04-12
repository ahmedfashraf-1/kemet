import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/extensions.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_cubit.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_state.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

import '../cubit/profile_cubit.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';
import '../widgets/profile_cover_widget.dart';
import '../widgets/profile_stats_widget.dart';
import '../widgets/profile_widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  static const Color _bgColor = Color(0xFF0E0E0E);
  static const Color _goldColor = Color(0xFFD4AF37);

  File? _image;
  String _displayName = '';
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage = false;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  Future<void> pickProfileImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (!mounted || pickedFile == null) {
        return;
      }

      final selectedFile = File(pickedFile.path);
      setState(() => _image = selectedFile);
      print('Image updated: $_image');

      await context.read<SettingsCubit>().setProfileAvatar(
            localPath: pickedFile.path,
          );

      if (mounted) {
        _showToast(context, 'Profile photo updated successfully ✦');
      }
    } catch (e) {
      debugPrint('Failed to pick image: $e');
      if (mounted) {
        _showToast(context, 'Failed to update photo', isError: true);
      }
    } finally {
      _isPickingImage = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) {
        Navigator.of(context).pop();
        return;
      }
      context.read<ProfileCubit>().loadProfile(widget.userId);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _editDisplayName(String currentName) async {
    final parentContext = context;
    final String? savedName = await showDialog<String>(
      context: parentContext,
      barrierDismissible: true,
      builder: (_) => _EditDisplayNameDialog(
        initialName: currentName,
        parentContext: parentContext,
      ),
    );

    if (!mounted || savedName == null) {
      return;
    }

    setState(() => _displayName = savedName);
    print('Name updated: $_displayName');

    context.read<ProfileCubit>().loadProfile(widget.userId);

    if (parentContext.mounted) {
      _showToast(parentContext, ' name has been updated  ✦');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A1407).withOpacity(0.55),
                    const Color(0xFF0E0E0E),
                    const Color(0xFF0A0A0A),
                  ],
                ),
              ),
            ),
          ),
          BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoggedOut) {
                context.pushNamedAndRemoveUntil(
                  '/onLoginScreen',
                  predicate: (route) => false,
                );
              }
              if (state is ProfileLoaded && _displayName.isEmpty) {
                if (!mounted) return;
                setState(() => _displayName = state.profile.fullName);
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: _goldColor),
                );
              }
              if (state is ProfileError) {
                return _buildErrorView(context);
              }
              if (state is ProfileLoaded) {
                return _buildLoadedView(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // Error View

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '𓂀',
            style: TextStyle(fontSize: 48, color: Color(0xFF333333)),
          ),
          SizedBox(height: 12.h),
          // Text(
          //   message,
          //   style: TextStyle(
          //     color: Colors.white.withOpacity(0.45),
          //     fontSize: 13.sp,
          //   ),
          // ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () =>
                context.read<ProfileCubit>().loadProfile(widget.userId),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                border: Border.all(color: _goldColor.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'RETRY',
                style: GoogleFonts.cinzel(
                  color: _goldColor,
                  fontSize: 12.sp,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loaded View

  Widget _buildLoadedView(BuildContext context, ProfileLoaded state) {
    final profile = state.profile;
    final displayName = _displayName.trim().isNotEmpty
        ? _displayName
        : (profile.fullName.trim().isNotEmpty ? profile.fullName : 'Guest');
    final email = profile.email.trim().isNotEmpty ? profile.email : '-';
    final horizontalPadding = MediaQuery.of(context).size.width < 360
        ? 16.0
        : 24.0;
    final avatarLocalPath =
        context.select((SettingsCubit cubit) => cubit.state.avatarLocalPath);
    final avatarRemoteUrl =
        context.select((SettingsCubit cubit) => cubit.state.avatarRemoteUrl);
    final avatarCacheBuster =
        context.select((SettingsCubit cubit) => cubit.state.avatarCacheBuster);
    final localFile = _image ??
        ((avatarLocalPath != null &&
                avatarLocalPath.isNotEmpty &&
                File(avatarLocalPath).existsSync())
            ? File(avatarLocalPath)
            : null);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: 190 + (118 / 2) - 8,
            child: ProfileCoverWidget(
              name: displayName,
              imageFile: localFile,
              avatarRemoteUrl: avatarRemoteUrl,
              avatarCacheBuster: avatarCacheBuster,
              onEditProfileImage: pickProfileImage,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 72.h),

                _buildNameSection(displayName, email),

                SizedBox(height: 20.h),

                ProfileStatsWidget(
                  trips: profile.tripsCount,
                  saved: profile.savedCount,
                  reviews: profile.reviewsCount,
                ),

                // ── Recent Places
                const ProfileSectionLabel(label: 'RECENT PLACES'),

                _buildRecentPlacesRow(state),

                // ── My Reviews
                const ProfileSectionLabel(label: 'MY REVIEWS'),
                if (state.reviews.isEmpty)
                  _buildEmptyHint('No reviews yet.')
                else
                  ...state.reviews.map(
                      (r) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: ProfileReviewItem(
                          place: r.landmarkId, // مؤقت لحد ما تجيبي الاسم الحقيقي
                          rating: r.rating,
                          date: formatDate(r.createdAt),
                        ),
                      ),
                    ),

                // ── Favorite Places Section ──────────────────────────────────
                const ProfileSectionLabel(label: 'FAVORITE PLACES'),

                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, favState) {
                    if (favState is! FavoritesLoaded || favState.favorites.isEmpty) {
                      return _buildEmptyHint('No favorites yet.');
                    }

                    // أول 3 فقط
                    final preview = favState.favorites.take(3).toList();

                    return Column(
                      children: [
                        ...preview.map(
                          (landmark) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: _buildFavoritePreviewItem(context, landmark),
                          ),
                        ),

                        // سهم "See All" لو عنده أكتر من 3
                        if (favState.favorites.length > 3)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, Routes.favoritesScreen),
                              icon: Text(
                                'See all ${favState.favorites.length}',
                                style: TextStyle(
                                  color: _goldColor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              label: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _goldColor,
                                size: 14.sp,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritePreviewItem(BuildContext context, Landmark landmark) {
    final imageUrl = landmark.photos.isNotEmpty
        ? landmark.photos.first.url
        : '';
    final hasValidUrl = imageUrl.isNotEmpty &&
        (Uri.tryParse(imageUrl)?.hasScheme ?? false);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        Routes.landmarkDetails,
        arguments: landmark,
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _goldColor.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 58.w,
                height: 58.w,
                child: hasValidUrl
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: const Color(0xFF1A1A1A),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFF1A1A1A),
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      )
                    : Container(color: const Color(0xFF1A1A1A)),
              ),
            ),

            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    landmark.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: _goldColor.withOpacity(0.8), size: 13.sp),
                      SizedBox(width: 4.w),
                      Text(
                        landmark.city,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.arrow_forward_ios_rounded,
                color: _goldColor.withOpacity(0.6), size: 14.sp),
          ],
        ),
      ),
    );
  }
  Widget _buildNameSection(String fullName, String email) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorant(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () => _editDisplayName(fullName),
                  child: Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF19140B),
                      border: Border.all(
                        color: AppColors.mainGold.withOpacity(0.42),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: AppColors.mainGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 11.sp,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, child) => Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mainGold.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainGold.withOpacity(_glowAnim.value * 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: child,
            ),
            child: Text(
              '✦  KEMET MEMBER',
              style: GoogleFonts.cinzel(
                color: AppColors.mainGold,
                fontSize: 10.sp,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recent Places horizontal scroll
  Widget _buildRecentPlacesRow(ProfileLoaded state) {
    if (state.recentTrips.isEmpty) {
      return _buildEmptyHint('No recent places yet.');
    }

    const gradients = [
      [Color(0xFF2A1800), Color(0xFF0E0800)],
      [Color(0xFF001822), Color(0xFF000A0F)],
      [Color(0xFF1A001A), Color(0xFF0A000A)],
      [Color(0xFF001A0A), Color(0xFF000A05)],
    ];

    return SizedBox(
      height: 76.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: state.recentTrips.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) => ProfileTripCard(
          name: state.recentTrips[i].name,
          city: state.recentTrips[i].city,
          gradientColors: gradients[i % gradients.length],
        ),
      ),
    );
  }

  // Empty state hint

  Widget _buildEmptyHint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12.sp),
      ),
    );
  }
}

void _showToast(BuildContext context, String message, {bool isError = false}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 48,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1407),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isError
                    ? Colors.redAccent.withOpacity(0.5)
                    : const Color(0xFFD4AF37).withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: isError
                      ? Colors.red.withOpacity(0.15)
                      : const Color(0xFFD4AF37).withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: isError ? Colors.redAccent : const Color(0xFFD4AF37),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () => entry.remove());
}

class _EditDisplayNameDialog extends StatefulWidget {
  final String initialName;
  final BuildContext parentContext;

  const _EditDisplayNameDialog({
    required this.initialName,
    required this.parentContext,
  });

  @override
  State<_EditDisplayNameDialog> createState() => _EditDisplayNameDialogState();
}

class _EditDisplayNameDialogState extends State<_EditDisplayNameDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('User is not available');
      }

      await user.updateDisplayName(newName);
      await user.reload();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fullName': newName});

      if (!mounted) return;

      Navigator.of(context).pop(newName);
    } catch (e) {
      debugPrint('Error saving name: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (widget.parentContext.mounted) {
        _showToast(widget.parentContext, 'Failed to update name', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimmedName = _controller.text.trim();

    return AlertDialog(
      backgroundColor: const Color(0xFF17140D),
      title: const Text(
        'Edit Display Name',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _ProfileScreenState._goldColor.withOpacity(0.35),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _ProfileScreenState._goldColor),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFBBBBBB)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _ProfileScreenState._goldColor,
            foregroundColor: Colors.black,
          ),
          onPressed: (!_isSaving && trimmedName.isNotEmpty) ? _save : null,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

String formatDate(DateTime date) {
  return "${date.month}/${date.year}";
}