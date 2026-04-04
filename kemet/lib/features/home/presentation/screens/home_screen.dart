import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
//import 'package:kemet/features/home/presentation/screens/hero_slider.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/presentation/cubit/landmarks_cubit.dart';
import 'package:kemet/features/landmarks/presentation/screens/hero_slider.dart';
import 'package:kemet/features/landmarks/presentation/screens/home_screen.dart';
import 'package:kemet/features/landmarks/presentation/screens/landmark_details_screen.dart';
import 'package:kemet/features/notifications/presentation/widgets/notification_bell_button.dart';
import 'package:kemet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kemet/features/profile/presentation/screens/profile_screen.dart';
import 'package:kemet/features/profile/presentation/widgets/profile_avatar_button.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bgColor = Color(0xFF0E0E0E);
  static const Color _goldColor = Color(0xFFD4AF37);

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  String _selectedCategory = '';
  String _selectedCity = '';

  final List<String> _egyptCities = [
    'Cairo', 'Luxor', 'Aswan', 'Giza', 'Alexandria', 'Red Sea', 'South Sinai'
  ];

  final List<String> _categories = [
    'historic', 'temple', 'museum', 'nature', 'island'
  ];

  final Map<String, bool> _favourites = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandmarksCubit>().getLandmarks(page: 1);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<LandmarksCubit>().applyFilter(
      city: _selectedCity.isEmpty ? null : _selectedCity,
      kind: _selectedCategory.isEmpty ? null : _selectedCategory,
      query: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _applyFilters);
  }


  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final shellOverlayClearance = 140.h + bottomSafeArea;
    const headerItemsCount = 9;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18.h),
                      const HeroSlider(),
                      SizedBox(height: 24.h),
                      _buildHeroTitle(),
                      SizedBox(height: 24.h),
                      _buildSearchBar(),
                      SizedBox(height: 18.h),

                      _buildFilterList(
                        items: _egyptCities,
                        selectedValue: _selectedCity,
                        onSelected: (val) {
                          setState(() => _selectedCity = val == 'All' ? '' : val);
                          _applyFilters();
                        },
                      ),
                      SizedBox(height: 16.h),

                      _buildFilterList(
                        items: _categories,
                        selectedValue: _selectedCategory,
                        onSelected: (val) {
                          setState(() => _selectedCategory = val == 'All' ? '' : val);
                          _applyFilters();
                        },
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),

                BlocBuilder<LandmarksCubit, LandmarksState>(
                  builder: (context, state) {
                    if (state is LandmarksLoading) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(color: _goldColor)),
                      );
                    } else if (state is LandmarksEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            context.tr('no_data'),
                            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 16.sp),
                          ),
                        ),
                      );
                    } else if (state is LandmarksError) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.message, style: const TextStyle(color: Colors.redAccent)),
                              SizedBox(height: 12.h),
                              SizedBox(
                                width: 170.w,
                                child: AnimatedGoldButton(
                                  text: context.tr('retry'),
                                  onTap: _applyFilters,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is LandmarksLoaded) {
                      return SliverPadding(
                        padding: EdgeInsets.only(bottom: shellOverlayClearance),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              if (index == state.landmarks.length) {
                                return _buildPagination(
                                  currentPage: state.currentPage,
                                  isLastPage: state.isLastPage,
                                  onPageSelected: (page) {
                                    context.read<LandmarksCubit>().getLandmarks(
                                      page: page,
                                      city: state.city,
                                      kind: state.kind,
                                      query: state.query,
                                      isPagination: true,
                                    );
                                  },
                                );
                              }

                              final landmark = state.landmarks[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 28.h),
                                child: _buildLandmarkCard(landmark),
                              );
                            },
                            childCount: state.landmarks.length + 1,
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: _bgColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 24.w,
        right: 24.w,
        bottom: 12.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Container(
          //   width: 40.w,
          //   height: 40.w,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Colors.white.withOpacity(0.03),
          //     border: Border.all(color: _goldColor.withOpacity(0.75), width: 1.5),
          //     boxShadow: [
          //       BoxShadow(
          //         color: _goldColor.withOpacity(0.12),
          //         blurRadius: 20,
          //         offset: const Offset(0, 8),
          //       ),
          //     ],
          //   ),
          //   clipBehavior: Clip.antiAlias,
          //   child: const Icon(
          //     Icons.person,
          //     color: AppColors.textDarkOnGold,
          //     size: 22,
          //   ),
          // ),
          // في الـ Row بتاع الـ AppBar استبدلي الـ Container بـده:
          ProfileAvatarButton(
            name: FirebaseAuth.instance.currentUser?.displayName ?? 'Guest',
            email: FirebaseAuth.instance.currentUser?.email ?? '',
            onViewProfile: _openProfile,   // تأكدي إن الميثود دي موجودة تحت
            onLogout: _logout,             // تأكدي إن الميثود دي موجودة تحت
          ),
          Text(
            'KEMET',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
              color: _goldColor,
              letterSpacing: 5,
            ),
          ),
        const NotificationBellButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: _goldColor.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(Icons.search, color: _goldColor.withOpacity(0.75), size: 21.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: context.tr('search_hint'),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 13.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.cormorant(
                fontSize: 56.sp,
                height: 0.98,
                letterSpacing: -1.2,
              ),
              children: [
                TextSpan(
                  text: '${context.tr('iconic')}\n',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: context.tr('landmarks'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _goldColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            context.tr('hero_subtitle'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12.5.sp,
              height: 1.45,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterList({
    required List<String> items,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    final allItems = ['All', ...items];
    final activeValue = selectedValue.isEmpty ? 'All' : selectedValue;

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: allItems.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final item = allItems[index];
          final isActive = activeValue == item;

          return GestureDetector(
            onTap: () => onSelected(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isActive ? AppColors.mainGold : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isActive ? AppColors.mainGold : AppColors.subtleGoldBorder,
                ),
              ),
              child: Center(
                child: Text(
                  _filterLabel(context, item).toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isActive ? AppColors.textDarkOnGold : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPagination({
    required int currentPage,
    required bool isLastPage,
    required Function(int) onPageSelected,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: currentPage > 1 ? () => onPageSelected(currentPage - 1) : null,
            child: Text(
              context.tr('back').toUpperCase(),
              style: GoogleFonts.cinzel(
                color: currentPage > 1 ? _goldColor : Colors.white24,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),

          if (currentPage > 1) ...[
            _pageNumberNode(1, onPageSelected, false),
            if (currentPage > 2) ...[
              Text('...', style: TextStyle(color: _goldColor, fontSize: 16.sp)),
              SizedBox(width: 8.w),
            ]
          ],

          _pageNumberNode(currentPage, onPageSelected, true),

          if (!isLastPage) ...[
            _pageNumberNode(currentPage + 1, onPageSelected, false),
            SizedBox(width: 8.w),
            Text('...', style: TextStyle(color: _goldColor, fontSize: 16.sp)),
          ],

          SizedBox(width: 16.w),
          GestureDetector(
            onTap: !isLastPage ? () => onPageSelected(currentPage + 1) : null,
            child: Text(
              context.tr('next_caps').toUpperCase(),
              style: GoogleFonts.cinzel(
                color: !isLastPage ? _goldColor : Colors.white24,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _pageNumberNode(int page, Function(int) onPageSelected, bool isActive) {
    return GestureDetector(
      onTap: () => onPageSelected(page),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? _goldColor : Colors.transparent,
        ),
        child: Text(
          page.toString(),
          style: GoogleFonts.cinzel(
            color: isActive ? _bgColor : _goldColor,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }


  Widget _buildLandmarkCard(Landmark landmark) {
    final isFav = _favourites[landmark.id] ?? false;


    final imageUrl = landmark.photos.isNotEmpty ? landmark.photos.first.url : '';
    final parsedUri = Uri.tryParse(imageUrl);
    final hasValidNetworkUrl = imageUrl.isNotEmpty &&
        parsedUri != null &&
        (parsedUri.scheme == 'http' || parsedUri.scheme == 'https');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: _goldColor.withOpacity(0.22), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.38), blurRadius: 24, offset: const Offset(0, 14)),
            BoxShadow(color: _goldColor.withOpacity(0.06), blurRadius: 22, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,

                  child: hasValidNetworkUrl
                      ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFF161616),
                      child: const Center(child: CircularProgressIndicator(color: _goldColor)),
                    ),
                    errorWidget: (context, url, error) => _buildPlaceholderImage(),
                  )
                      : _buildPlaceholderImage(),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.34), _bgColor.withOpacity(0.92)],
                        stops: const [0.1, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14.h,
                  left: 14.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _goldColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _goldColor.withOpacity(0.35)),
                    ),

                    child: Text(
                      landmark.category.name.toUpperCase(),
                      style: TextStyle(color: _goldColor, fontSize: 9.8.sp, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _favourites[landmark.id] = !isFav;
                      });
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _bgColor.withOpacity(0.62),
                        border: Border.all(color: _goldColor.withOpacity(0.24)),
                      ),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: _goldColor, size: 21),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18.h,
                  left: 18.w,
                  right: 18.w,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          landmark.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorant(fontSize: 28.sp, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: _goldColor.withOpacity(0.82), size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        landmark.city,
                        style: TextStyle(fontSize: 12.5.sp, color: Colors.white.withOpacity(0.72), letterSpacing: 0.3),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    landmark.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.68), height: 1.55),
                  ),
                  SizedBox(height: 18.h),
                  GestureDetector(
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LandmarkDetailsScreen(
        landmark: landmark,
      ),
    ),
  );
},
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      height: 55.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.darkGold, AppColors.mainGold, AppColors.darkGold],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.darkGold.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Text(
                        context.tr('view_details'),
                        style: GoogleFonts.inter(color: AppColors.textDarkOnGold, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Icon(Icons.landscape, color: _goldColor, size: 60),
      ),
    );
  }

  String _filterLabel(BuildContext context, String value) {
    switch (value) {
      case 'All':
        return context.tr('all');
      case 'Cairo':
        return context.tr('city_cairo');
      case 'Luxor':
        return context.tr('city_luxor');
      case 'Aswan':
        return context.tr('city_aswan');
      case 'Giza':
        return context.tr('city_giza');
      case 'Alexandria':
        return context.tr('city_alexandria');
      case 'Red Sea':
        return context.tr('city_red_sea');
      case 'South Sinai':
        return context.tr('city_south_sinai');
      case 'historic':
        return context.tr('category_historic');
      case 'temple':
        return context.tr('category_temple');
      case 'museum':
        return context.tr('category_museum');
      case 'nature':
        return context.tr('category_nature');
      case 'island':
        return context.tr('category_island');
      default:
        return value;
    }
  }


Future<void> _openProfile() async {
    // ✅ بنجيب الـ userId من FirebaseAuth مباشرة — مش محتاجين AuthCubit هنا
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
 
    if (!mounted) return;
 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<ProfileCubit>(),
          child: ProfileScreen(userId: userId),
        ),
      ),
    );
  }

   Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    
    Navigator.pushNamedAndRemoveUntil(context, '/onLoginScreen', (_) => false);
  }


}

mixin LandmarksEmpty {
}

