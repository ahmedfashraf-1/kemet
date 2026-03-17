import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import 'package:kemet/view/home/hero_slider.dart';
import 'package:kemet/view/home/category_filter.dart';

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
          'One of the Seven Wonders of the Ancient World, standing for over 4,500 years.',
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

  List<Place> get _filteredPlaces => _selectedCategory == 'All'
      ? _places
      : _places.where((p) => p.category == _selectedCategory).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildSearchBar(),
                  SizedBox(height: 20.h),
                  const HeroSlider(),
                  SizedBox(height: 20.h),
                  CategoryFilter(
                    categories: _places
                        .map((p) => p.category)
                        .toSet()
                        .toList(),
                    onSelected: (selected) {
                      setState(() => _selectedCategory = selected);
                    },
                  ),
                  SizedBox(height: 28.h),
                  _buildHeroTitle(),
                  SizedBox(height: 28.h),
                  ..._filteredPlaces.map(
                    (place) => Padding(
                      padding: EdgeInsets.only(bottom: 32.h),
                      child: _buildLandmarkCard(place),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top App Bar ───────────────────────────────────────────
  Widget _buildTopAppBar() {
    return Container(
      color: AppColors.screenBackground.withOpacity(0.8),
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
              border: Border.all(color: AppColors.mainGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mainGold.withOpacity(0.2),
                  blurRadius: 15,
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
              fontSize: 20.sp,
              color: AppColors.mainGold,
              letterSpacing: 4,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: AppColors.mainGold,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(Icons.search, color: AppColors.textSecondary, size: 22.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                style:
                    TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
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

  // ─── Hero Title ────────────────────────────────────────────
  Widget _buildHeroTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.cormorant(
            fontSize: 52.sp,
            height: 1.0,
            letterSpacing: -2,
          ),
          children: [
            TextSpan(
              text: 'Iconic\n',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: 'Landmarks',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.mainGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Landmark Card ─────────────────────────────────────────
  Widget _buildLandmarkCard(Place place) {
    final isFav = _favourites[place.title] ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.subtleGoldBorder.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Image.asset(
                    place.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cardBackground,
                      child: const Center(
                        child: Icon(Icons.landscape,
                            color: AppColors.mainGold, size: 60),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.screenBackground.withOpacity(0.6),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16.h,
                  right: 16.w,
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
                        color: AppColors.cardBackground.withOpacity(0.7),
                        border: Border.all(
                          color: AppColors.mainGold.withOpacity(0.08),
                        ),
                      ),
                      child: Icon(
                       
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.mainGold,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14.h,
                  left: 14.w,
                  right: 14.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.darkGold.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: AppColors.mainGold.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          place.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.title,
                          style: GoogleFonts.cormorant(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.mainGold.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: AppColors.mainGold.withOpacity(0.20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: AppColors.mainGold, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              place.rating,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mainGold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${place.reviews})',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: AppColors.textSecondary, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        place.location,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 45.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF96703D),
                            Color(0xFFDAAB5F),
                            Color(0xFF96703D),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF96703D).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'VIEW DETAILS',
                        style: GoogleFonts.cinzel(
                          color: AppColors.textDarkOnGold,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
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