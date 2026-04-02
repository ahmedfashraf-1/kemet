// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kemet/core/constants/colors.dart';
// import 'package:kemet/core/utils/extensions.dart';

// import '../cubit/profile_cubit.dart';
// import '../widgets/profile_cover_widget.dart';
// import '../widgets/profile_stats_widget.dart';
// import '../widgets/profile_widgets.dart';

// // why StatefulWidget ? initState()
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   static const Color _bgColor = Color(0xFF0E0E0E);
//   static const Color _goldColor = Color(0xFFD4AF37);

//   // 1 loadprofile
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ProfileCubit>().loadProfile();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bgColor,
//       body: BlocConsumer<ProfileCubit, ProfileState>(
//         listener: (context, state) {
//           if (state is ProfileLoggedOut) {
//                 context.pushNamedAndRemoveUntil(
//                   '/login',
//                   predicate: (route) => false,
//                 );          
//           }
//           if (state is ProfileError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 backgroundColor: const Color(0xFF1A0E0E),
//                 content: Text(
//                   state.message,
//                   style: const TextStyle(color: Colors.redAccent),
//                 ),
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is ProfileLoading || state is ProfileInitial) {
//             return const Center(
//               child: CircularProgressIndicator(color: _goldColor),
//             );
//           }

//           if (state is ProfileError) {
//             return _buildErrorView(context, state.message);
//           }

//           if (state is ProfileLoaded) {
//             return _buildLoadedView(context, state);
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // Error View
//   // ─────────────────────────────────────────
//   Widget _buildErrorView(BuildContext context, String message) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             '𓂀',
//             style: TextStyle(fontSize: 48, color: Color(0xFF333333)),
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             message,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.45),
//               fontSize: 13.sp,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           GestureDetector(
//             onTap: () => context.read<ProfileCubit>().loadProfile(),
//             child: Container(
//               padding:
//                   EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: _goldColor.withOpacity(0.4),
//                 ),
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               child: Text(
//                 'RETRY',
//                 style: GoogleFonts.cinzel(
//                   color: _goldColor,
//                   fontSize: 12.sp,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // Loaded View
//   // ─────────────────────────────────────────
//   Widget _buildLoadedView(BuildContext context, ProfileLoaded state) {
//     final profile = state.profile;

//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Column(
//         children: [
//           // ── Cover + Avatar
//           ProfileCoverWidget(
//             name: profile.name,
//             location: profile.location,
//           ),

//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 50.h),

//                 // ── Name & Badge
//                 _buildNameSection(profile.name, profile.location),

//                 SizedBox(height: 20.h),

//                 // ── Stats
//                 ProfileStatsWidget(
//                   trips: profile.tripsCount,
//                   saved: profile.savedCount,
//                   reviews: profile.reviewsCount,
//                 ),

//                 // ── Recent Trips
//                 const ProfileSectionLabel(label: 'RECENT TRIPS'),
//                 _buildTripsRow(state),

//                 // ── My Reviews
//                 const ProfileSectionLabel(label: 'MY REVIEWS'),
//                 ...state.reviews.map(
//                   (r) => Padding(
//                     padding: EdgeInsets.only(bottom: 6.h),
//                     child: ProfileReviewItem(
//                       icon: r.placeIcon,
//                       place: r.placeName,
//                       rating: r.rating,
//                       date: r.date,
//                     ),
//                   ),
//                 ),

//                 // ── Saved Places
//                 const ProfileSectionLabel(label: 'SAVED PLACES'),
//                 ...state.savedPlaces.map(
//                   (s) => Padding(
//                     padding: EdgeInsets.only(bottom: 6.h),
//                     child: ProfileSavedItem(
//                       icon: s.icon,
//                       name: s.name,
//                       location: s.location,
//                     ),
//                   ),
//                 ),

//                 // ── Sign Out
//                 SizedBox(height: 16.h),
//                 GestureDetector(
//                   onTap: () => context.read<ProfileCubit>().logout(),
//                   child: const ProfileSignOutButton(),
//                 ),
//                 SizedBox(height: 24.h),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // Name Section
//   // ─────────────────────────────────────────
//   Widget _buildNameSection(String name, String location) {
//     return Center(
//       child: Column(
//         children: [
//           Text(
//             name,
//             style: GoogleFonts.cormorant(
//               color: Colors.white,
//               fontSize: 24.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             location,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.45),
//               fontSize: 11.sp,
//               letterSpacing: 2,
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Container(
//             padding:
//                 EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: AppColors.mainGold.withOpacity(0.4),
//               ),
//               borderRadius: BorderRadius.circular(20.r),
//             ),
//             child: Text(
//               '✦  KEMET MEMBER',
//               style: GoogleFonts.cinzel(
//                 color: AppColors.mainGold,
//                 fontSize: 10.sp,
//                 letterSpacing: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // Trips horizontal scroll
//   // ─────────────────────────────────────────
//   Widget _buildTripsRow(ProfileLoaded state) {
//     const gradients = [
//       [Color(0xFF2A1800), Color(0xFF0E0800)],
//       [Color(0xFF001822), Color(0xFF000A0F)],
//       [Color(0xFF1A001A), Color(0xFF0A000A)],
//       [Color(0xFF001A0A), Color(0xFF000A05)],
//     ];

//     return SizedBox(
//       height: 76.h,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: state.trips.length,
//         separatorBuilder: (_, __) => SizedBox(width: 8.w),
//         itemBuilder: (_, i) => ProfileTripCard(
//           name: state.trips[i].name,
//           city: state.trips[i].city,
//           gradientColors: gradients[i % gradients.length],
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/utils/extensions.dart';

import '../cubit/profile_cubit.dart';
import '../widgets/profile_cover_widget.dart';
import '../widgets/profile_stats_widget.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  /// userId بيجي من AuthCubit أو SharedPrefs لما بتفتح الصفحة
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _bgColor   = Color(0xFF0E0E0E);
  static const Color _goldColor = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ بنمرر الـ userId
      context.read<ProfileCubit>().loadProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoggedOut) {
            context.pushNamedAndRemoveUntil(
              '/login',
              predicate: (route) => false,
            );
          }
        //  if (state is ProfileError) {
          //  ScaffoldMessenger.of(context).showSnackBar(
            //  SnackBar(
            //    backgroundColor: const Color(0xFF1A0E0E),
              //  content: Text(
                  //state.message,
                //  style: const TextStyle(color: Colors.redAccent),
              //  ),
          //    ),
          //  );
        //  }
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
    );
  }

  // ─────────────────────────────────────────
  // Error View
  // ─────────────────────────────────────────
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
            // ✅ retry بالـ userId
            onTap: () =>
                context.read<ProfileCubit>().loadProfile(widget.userId),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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

  // ─────────────────────────────────────────
  // Loaded View
  // ─────────────────────────────────────────
  Widget _buildLoadedView(BuildContext context, ProfileLoaded state) {
    final profile = state.profile;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ✅ profile.fullName — مفيش name أو location في الـ entity
          ProfileCoverWidget(name: profile.fullName),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),

                _buildNameSection(profile.fullName, profile.email),

                SizedBox(height: 20.h),

                ProfileStatsWidget(
                  trips: profile.tripsCount,
                  saved: profile.savedCount,
                  reviews: profile.reviewsCount,
                ),

                // ── Recent Places
                const ProfileSectionLabel(label: 'RECENT PLACES'),
                // ✅ recentPlaces بدل trips
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
                        place: r.placeName,
                        rating: r.rating,
                        date: r.date,
                      ),
                    ),
                  ),

                // ── Favorite Places
                const ProfileSectionLabel(label: 'FAVORITE PLACES'),
                // ✅ favoritePlaces بدل savedPlaces
                if (state.favoritePlaces.isEmpty)
                  _buildEmptyHint('No favorites yet.')
                else
                  ...state.favoritePlaces.map(
                    (f) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: ProfileSavedItem(
                        // ✅ Favorite entity: icon, name, location
                        //icon: f.icon,
                        name: f.name,
                        location: f.location, icon: '',
                      ),
                    ),
                  ),

                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => context.read<ProfileCubit>().logout(),
                  child: const ProfileSignOutButton(),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Name Section
  // ─────────────────────────────────────────
  Widget _buildNameSection(String fullName, String email) {
    return Center(
      child: Column(
        children: [
          Text(
            fullName,
            style: GoogleFonts.cormorant(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          // ✅ email بدل location اللي مش موجودة في Firebase
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 11.sp,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.mainGold.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(20.r),
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

  // ─────────────────────────────────────────
  // Recent Places horizontal scroll
  // ─────────────────────────────────────────
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
          // ✅ Landmark entity: name + city
          name: state.recentTrips[i].name,
          city: state.recentTrips[i].city,
          gradientColors: gradients[i % gradients.length],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Empty state hint
  // ─────────────────────────────────────────
  Widget _buildEmptyHint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 12.sp,
        ),
      ),
    );
  }
}