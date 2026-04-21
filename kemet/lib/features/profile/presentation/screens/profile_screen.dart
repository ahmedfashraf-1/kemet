import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/extensions.dart';

import '../cubit/profile_cubit.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';
import '../widgets/profile_cover_widget.dart';
import '../widgets/profile_stats_widget.dart';
import '../widgets/profile_widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:kemet/features/landmarks/domain/usecases/get_landmark_by_id.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  static const Color _bgColor = Color(0xFF0E0E0E);
  static const Color _goldColor = Color(0xFFD4AF37);

  File? _image;
  String _displayName = '';
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage = false;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  _LandmarkLookupCache? _landmarkLookup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _landmarkLookup ??= _LandmarkLookupCache(
      GetLandmarkByIdUseCase(context.read<LandmarksRepository>()),
    );
  }

  Future<void> pickProfileImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      debugPrint(
        'Profile photo flow started for widget.userId=${widget.userId}',
      );
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (!mounted || pickedFile == null) {
        debugPrint('Profile photo pick cancelled or widget disposed.');
        return;
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;
      debugPrint(
        'Current auth user for upload: ${firebaseUser?.uid ?? 'null'}',
      );
      if (firebaseUser == null ||
          firebaseUser.uid.isEmpty ||
          firebaseUser.isAnonymous) {
        if (mounted) {
          _showToast(context, 'Please sign in to update photo', isError: true);
        }
        return;
      }

      if (firebaseUser.uid != widget.userId) {
        if (mounted) {
          _showToast(
            context,
            'You can edit only your profile photo',
            isError: true,
          );
        }
        return;
      }

      final selectedFile = File(pickedFile.path);
      if (!selectedFile.existsSync()) {
        debugPrint('Selected image path is not accessible: ${pickedFile.path}');
        if (mounted) {
          _showToast(
            context,
            'Selected image is not accessible',
            isError: true,
          );
        }
        return;
      }

      final remoteUrl = await uploadProfileImage(selectedFile);

      if (!mounted) return;
      setState(() => _image = selectedFile);

      try {
        await context.read<SettingsCubit>().setProfileAvatar(
          localPath: pickedFile.path,
          remoteUrl: remoteUrl,
        );
      } catch (settingsError, settingsStack) {
        debugPrint('Non-fatal settings cache update failed: $settingsError');
        debugPrintStack(stackTrace: settingsStack);
      }

      if (mounted) {
        _showToast(context, 'Profile photo updated successfully ✦');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth error during photo upload: ${e.code} ${e.message}');
      if (mounted) {
        _showToast(
          context,
          'Upload failed: ${_formatUploadError(e)}',
          isError: true,
        );
      }
    } on FirebaseException catch (e, st) {
      debugPrint(
        'Firebase photo upload/save error: code=${e.code} message=${e.message}',
      );
      debugPrintStack(stackTrace: st);
      if (mounted) {
        _showToast(
          context,
          'Upload failed: ${_formatUploadError(e)}',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Unexpected photo upload error: $e');
      if (mounted) {
        _showToast(context, 'Upload failed: ${e.toString()}', isError: true);
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    try {
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse(
                'https://api.cloudinary.com/v1_1/datkysjx4/image/upload',
              ),
            )
            ..fields['upload_preset'] = 'kmt_upload'
            ..files.add(
              await http.MultipartFile.fromPath('file', imageFile.path),
            );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint(
          'Cloudinary upload failed: status=${response.statusCode} body=$body',
        );
        return null;
      }

      final data = jsonDecode(body);
      if (data is! Map<String, dynamic>) {
        debugPrint('Cloudinary upload failed: invalid response shape');
        return null;
      }

      final secureUrl = data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.trim().isEmpty) {
        debugPrint('Cloudinary upload failed: secure_url missing');
        return null;
      }

      return secureUrl.trim();
    } catch (e, st) {
      debugPrint('Cloudinary upload exception: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  Future<String> uploadProfileImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'User must be authenticated before uploading a profile photo.',
      );
    }

    if (!file.existsSync()) {
      throw StateError('Selected profile image file does not exist on disk.');
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadPath = 'users/$uid/$fileName.jpg';

    print('UID: $uid');
    print('UPLOAD PATH: $uploadPath');

    final downloadUrl = await uploadToCloudinary(file);
    if (downloadUrl == null) {
      throw FirebaseException(
        plugin: 'cloudinary_upload',
        code: 'upload-failed',
        message: 'Cloudinary upload failed: secure_url was not returned.',
      );
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'photoUrl': downloadUrl,
    });

    return downloadUrl;
  }

  String _formatUploadError(Object error) {
    if (error is FirebaseAuthException) {
      final message = error.message?.trim();
      return message == null || message.isEmpty
          ? error.code
          : '${error.code}: $message';
    }

    if (error is FirebaseException) {
      if (error.code == 'upload-failed') {
        return 'Image upload failed. Please try again.';
      }

      final message = error.message?.trim();
      return message == null || message.isEmpty
          ? error.code
          : '${error.code}: $message';
    }

    return error.toString();
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
    final horizontalPadding = MediaQuery.of(context).size.width < 360
        ? 16.0
        : 24.0;
    final viewedUserId = widget.userId;
    final signedInUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile = viewedUserId == signedInUserId;
    final isPrivateView = profile.isPrivate && !isOwnProfile;
    final displayName = isPrivateView
        ? 'Private Account'
        : (_displayName.trim().isNotEmpty
              ? _displayName
              : (profile.fullName.trim().isNotEmpty
                    ? profile.fullName
                    : 'Guest'));
    final email = isPrivateView
        ? 'This account is private'
        : (profile.email.trim().isNotEmpty ? profile.email : '-');
    final avatarLocalPath = context.select(
      (SettingsCubit cubit) => cubit.state.avatarLocalPath,
    );
    final avatarRemoteUrlFromSettings = context.select(
      (SettingsCubit cubit) => cubit.state.avatarRemoteUrl,
    );
    final avatarCacheBuster = context.select(
      (SettingsCubit cubit) => cubit.state.avatarCacheBuster,
    );
    final localFile = isOwnProfile
        ? (_image ??
              ((avatarLocalPath != null &&
                      avatarLocalPath.isNotEmpty &&
                      File(avatarLocalPath).existsSync())
                  ? File(avatarLocalPath)
                  : null))
        : null;
    final avatarRemoteUrl = isOwnProfile
        ? (avatarRemoteUrlFromSettings ?? profile.photoUrl)
        : (isPrivateView ? null : profile.photoUrl);

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
              isEditable: isOwnProfile && !isPrivateView,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 72.h),

                _buildNameSection(
                  displayName,
                  email,
                  canEdit: isOwnProfile && !isPrivateView,
                ),

                SizedBox(height: 20.h),

                if (isPrivateView) ...[
                  _buildPrivateAccountNotice(),
                  SizedBox(height: 24.h),
                ] else ...[
                  ProfileStatsWidget(
                    trips: profile.tripsCount,
                    saved: profile.savedCount,
                    reviews: profile.reviewsCount,
                    onExploredTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Explored list coming soon.'),
                        ),
                      );
                    },
                    onFavoriteTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favorites coming soon.')),
                      );
                    },
                    onReviewsTap: () {
                      Navigator.of(context).pushNamed(
                        Routes.userReviewsScreen,
                        arguments: widget.userId,
                      );
                    },
                  ),

                  const ProfileSectionLabel(label: 'RECENT PLACES'),
                  _buildRecentPlacesRow(state),

                  const ProfileSectionLabel(label: 'MY REVIEWS'),
                  if (state.reviews.isEmpty)
                    _buildEmptyHint('No reviews yet.')
                  else ...[
                    ...state.reviews.map(
                      (review) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: ProfileReviewPreviewCard(
                          rating: review.rating,
                          comment: review.comment,
                          createdAt: review.createdAt,
                          onTap: () => _openLandmarkFromReview(review),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                          Routes.userReviewsScreen,
                          arguments: widget.userId,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mainGold,
                        ),
                        child: const Text(
                          'VIEW ALL REVIEWS',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const ProfileSectionLabel(label: 'FAVORITE PLACES'),
                  if (state.favoritePlaces.isEmpty)
                    _buildEmptyHint('No favorites yet.')
                  else
                    ...state.favoritePlaces.map(
                      (f) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: ProfileSavedItem(
                          name: f.name,
                          location: f.location,
                          icon: '',
                        ),
                      ),
                    ),

                  SizedBox(height: 16.h),
                  if (isOwnProfile) const ProfileSignOutButton(),
                  SizedBox(height: 24.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Name Section

  Widget _buildNameSection(
    String fullName,
    String email, {
    required bool canEdit,
  }) {
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
                if (canEdit) ...[
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
                    color: AppColors.mainGold.withOpacity(
                      _glowAnim.value * 0.3,
                    ),
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

  Widget _buildPrivateAccountNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13110C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mainGold.withOpacity(0.22)),
      ),
      child: const Text(
        'This account is private',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _openLandmarkFromReview(Review review) async {
    final lookup = _landmarkLookup;
    if (lookup == null) {
      return;
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    final landmark = await lookup.getLandmark(
      review.landmarkId,
      languageCode: languageCode,
    );
    if (!mounted) {
      return;
    }

    if (landmark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Landmark details are unavailable.')),
      );
      return;
    }

    Navigator.of(
      context,
    ).pushNamed(Routes.landmarkDetails, arguments: landmark);
  }
}

class _LandmarkLookupCache {
  _LandmarkLookupCache(this._getLandmarkByIdUseCase);

  final GetLandmarkByIdUseCase _getLandmarkByIdUseCase;
  final Map<String, Future<Landmark?>> _landmarkFutures = {};

  Future<Landmark?> getLandmark(String id, {String? languageCode}) {
    final cacheKey = '${languageCode ?? 'en'}|$id';
    return _landmarkFutures.putIfAbsent(cacheKey, () async {
      final result = await _getLandmarkByIdUseCase(
        id,
        languageCode: languageCode,
      );
      return result.fold((_) => null, (landmark) => landmark);
    });
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

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'fullName': newName},
      );

      if (!mounted) return;

      Navigator.of(context).pop(newName);
    } catch (e) {
      debugPrint('Error saving name: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (widget.parentContext.mounted) {
        _showToast(
          widget.parentContext,
          'Failed to update name',
          isError: true,
        );
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
