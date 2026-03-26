import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import 'package:kemet/features/home/presentation/screens/hero_slider.dart';

class Place {
  final String image;
  final String title;
  final String location;
  final String rating;
  final String reviews;
  final String category;
  final String description;

  const Place({
    required this.image,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.description,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bgColor = Color(0xFF0E0E0E);
  static const Color _goldColor = Color(0xFFD4AF37);

  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Place> _places = [
    Place(
      image: 'images/KarnakTemple.jpg',
      title: 'Karnak Temple Complex',
      location: 'Luxor, Egypt',
      rating: '4.9',
      reviews: '12.4k',
      category: 'Temples',
      description:
          'The largest ancient religious site in the world, home to 134 massive pillars.',
    ),
    Place(
      image: 'images/valley.jpg',
      title: 'Valley of the Kings',
      location: 'Luxor, Egypt',
      rating: '4.8',
      reviews: '9.2k',
      category: 'Tomb',
      description:
          'Royal burial ground of Egypt\'s most powerful pharaohs for over 500 years.',
    ),
    Place(
      image: 'images/pyramids.jpg',
      title: 'Great Pyramids of Giza',
      location: 'Cairo, Egypt',
      rating: '5.0',
      reviews: '20k',
      category: 'Temples',
      description:
          'One of the Seven Wonders of the Ancient World, standing for over 7,500 years.',
    ),
    Place(
      image: 'images/museum.jpg',
      title: 'Egyptian Museum',
      location: 'Cairo, Egypt',
      rating: '4.7',
      reviews: '8.1k',
      category: 'Museums',
      description:
          'Home to the world\'s largest collection of ancient Egyptian antiquities.',
    ),
  ];


  final Map<String, bool> _favourites = {};

  List<Place> get _filteredPlaces {
    final query = _searchController.text.trim().toLowerCase();

    final categoryFiltered = _selectedCategory == 'All'
        ? _places
        : _places.where((p) => p.category == _selectedCategory).toList();

    if (query.isEmpty) {
      return categoryFiltered;
    }

    return categoryFiltered.where((p) {
      return p.title.toLowerCase().contains(query) ||
          p.location.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final shellOverlayClearance = 140.h + bottomSafeArea;
    final filteredPlaces = _filteredPlaces;
    const headerItemsCount = 9;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: shellOverlayClearance),
              itemCount: headerItemsCount + filteredPlaces.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return SizedBox(height: 18.h);
                if (index == 1) return _buildSearchBar();
                if (index == 2) return SizedBox(height: 22.h);
                if (index == 3) return const HeroSlider();
                if (index == 4) return SizedBox(height: 24.h);
                if (index == 5) return _buildCategoryChips();
                if (index == 6) return SizedBox(height: 34.h);
                if (index == 7) return _buildHeroTitle();
                if (index == 8) return SizedBox(height: 24.h);
                if (index == headerItemsCount + filteredPlaces.length) {
                  return SizedBox(height: 12.h);
                }

                final place = filteredPlaces[index - headerItemsCount];
                return Padding(
                  padding: EdgeInsets.only(bottom: 28.h),
                  child: _buildLandmarkCard(place),
                );
              },
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
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
              border: Border.all(color: _goldColor.withOpacity(0.75), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _goldColor.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: const Icon(
              Icons.person,
              color: AppColors.textDarkOnGold,
              size: 22,
            ),
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
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: _goldColor,
              size: 24,
            ),
          ),
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
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search landmarks, places, cities',
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
                  text: 'Iconic\n',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Landmarks',
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
            'Curated destinations with timeless history and elegance.',
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

  Widget _buildCategoryChips() {
    final categories = ['All', ..._places.map((p) => p.category).toSet()];

    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                color: isActive
                    ? AppColors.mainGold
                    : AppColors.cardBackground.withOpacity(0.78),
                gradient: isActive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkGold,
                          AppColors.mainGold,
                          AppColors.lightGold,
                        ],
                      )
                    : null,
                border: Border.all(
                  color: isActive
                      ? AppColors.mainGold
                      : AppColors.subtleGoldBorder,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.darkGold.withOpacity(0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  category.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.25,
                    color: isActive
                        ? AppColors.textDarkOnGold
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLandmarkCard(Place place) {
    final isFav = _favourites[place.title] ?? false;
    final rawUrl = place.image;
    final imageUrl = rawUrl.trim();
    final parsedUri = Uri.tryParse(imageUrl);
    final hasValidNetworkUrl =
        imageUrl.isNotEmpty &&
        parsedUri != null &&
        (parsedUri.scheme == 'http' || parsedUri.scheme == 'https');

    debugPrint('Home card image url: $imageUrl');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(
            color: _goldColor.withOpacity(0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.38),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: _goldColor.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
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
                          ),
                          errorWidget: (context, url, error) {
                            debugPrint('Image load failed: $url | $error');
                            return Container(
                              color: const Color(0xFF1A1A1A),
                              child: Center(
                                child: Icon(
                                  Icons.landscape,
                                  color: _goldColor,
                                  size: 60,
                                ),
                              ),
                            );
                          },
                        )
                      : (imageUrl.isNotEmpty
                          ? Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  'Invalid image source: $imageUrl | $error',
                                );
                                return Container(
                                  color: const Color(0xFF1A1A1A),
                                  child: Center(
                                    child: Icon(
                                      Icons.landscape,
                                      color: _goldColor,
                                      size: 60,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: const Color(0xFF1A1A1A),
                              child: Center(
                                child: Icon(
                                  Icons.landscape,
                                  color: _goldColor,
                                  size: 60,
                                ),
                              ),
                            )),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.34),
                          _bgColor.withOpacity(0.92),
                        ],
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
                      place.category.toUpperCase(),
                      style: TextStyle(
                        color: _goldColor,
                        fontSize: 9.8.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _favourites[place.title] = !isFav;
                      });
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _bgColor.withOpacity(0.62),
                        border: Border.all(
                          color: _goldColor.withOpacity(0.24),
                        ),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: _goldColor,
                        size: 21,
                      ),
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
                          place.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorant(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _bgColor.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _goldColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: _goldColor, size: 14.sp),
                            SizedBox(width: 3.w),
                            Text(
                              place.rating,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: _goldColor,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              place.reviews,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.68),
                              ),
                            ),
                          ],
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
                      Icon(Icons.location_on_outlined,
                          color: _goldColor.withOpacity(0.82), size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        place.location,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: Colors.white.withOpacity(0.72),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    place.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.68),
                      height: 1.55,
                    ),
                  ),

                  SizedBox(height: 18.h),

                  GestureDetector(
                    onTap: () {},
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
                          colors: [
                            AppColors.darkGold,
                            AppColors.mainGold,
                            AppColors.darkGold,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkGold.withOpacity(0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'VIEW DETAILS',
                        style: GoogleFonts.inter(
                          color: AppColors.textDarkOnGold,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
}