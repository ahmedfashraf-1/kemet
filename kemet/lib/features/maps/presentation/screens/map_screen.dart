import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/presentation/screens/landmark_details_screen.dart';
import 'package:kemet/features/maps/presentation/cubit/map_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/map_cubit.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color _bgColor   = Color(0xFF0E0E0E);
  static const Color _goldColor = Color(0xFFD4AF37);

  // move , zoom in/out
  final MapController _mapController = MapController();

  static const double _egyptLat = 26.8206;
  static const double _egyptLng = 30.8025;

  @override
  void initState() {
    super.initState();
    // wait for frame ,then execute code
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapCubit>().loadMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          if (state is MapLoading || state is MapInitial) {
            return const Center(
              child: CircularProgressIndicator(color: _goldColor),
            );
          }
          if (state is MapError) {
            return _buildError(context, state.message);
          }
          if (state is MapLoaded) {
            return _buildMap(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Map
  Widget _buildMap(BuildContext context, MapLoaded state) {
    final centerLat = state.userLat ?? _egyptLat;
    final centerLng = state.userLng ?? _egyptLng;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLng),
            initialZoom: state.userLat != null ? 10.0 : 6.0,
            minZoom: 4.0,
            maxZoom: 18.0,
            onTap: (_,_) => context.read<MapCubit>().clearSelection(),
          ),
          children: [
            // OpenStreetMap tiles
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kemet.app',
            ),

            // Markers
            MarkerLayer(
              markers: [
                // Landmark markers
                ...state.landmarks.map(
                  (l) => _landmarkMarker(context, l, state),
                ),
                // User location marker
                if (state.userLat != null && state.userLng != null)
                  _userMarker(state.userLat!, state.userLng!),
              ],
            ),
          ],
        ),

        // Selected landmark card
        if (state.selectedLandmark != null)
          Positioned(
            bottom: 24.h,
            left: 16.w,
            right: 16.w,
            child: _buildLandmarkCard(context, state.selectedLandmark!),
          ),

        // My location button
        Positioned(
          bottom: state.selectedLandmark != null ? 160.h : 24.h,
          right: 16.w,
          child: _buildMyLocationBtn(state),
        ),
      ],
    );
  }


  // Landmark Marker
  Marker _landmarkMarker(
      BuildContext context, Landmark l, MapLoaded state) {
    final isSelected = state.selectedLandmark?.id == l.id;

    return Marker(
      point: LatLng(l.latitude!, l.longitude!),
      width: isSelected ? 44 : 36,
      height: isSelected ? 44 : 36,
      child: GestureDetector(
        onTap: () {
          context.read<MapCubit>().selectLandmark(l);
          _mapController.move(LatLng(l.latitude!, l.longitude!), 12.0);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? _goldColor : _goldColor.withOpacity(0.85),
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _goldColor.withOpacity(isSelected ? 0.6 : 0.3),
                blurRadius: isSelected ? 12 : 6,
                spreadRadius: isSelected ? 3 : 1,
              ),
            ],
          ),
          child: Icon(
            _categoryIcon(l.category.id),
            color: Colors.black87,
            size: isSelected ? 22 : 18,
          ),
        ),
      ),
    );
  }

  // User Marker
  Marker _userMarker(double lat, double lng) {
    return Marker(
      point: LatLng(lat, lng),
      width: 20,
      height: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.9),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }


  // Selected Landmark Card
  Widget _buildLandmarkCard(BuildContext context, Landmark l) {
    final imageUrl = l.photos.isNotEmpty ? l.photos.first.url : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LandmarkDetailsScreen(landmark: l),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF141108),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _goldColor.withOpacity(0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── صورة أو أيقونة
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 54.w,
                      height: 54.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _iconBox(l),
                    )
                  : _iconBox(l),
            ),

            SizedBox(width: 12.w),

            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.name,
                    style: GoogleFonts.cormorant(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: _goldColor, size: 12.sp),
                      SizedBox(width: 3.w),
                      Text(
                        l.city,
                        style: TextStyle(
                            color: Colors.white54, fontSize: 11.sp),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _goldColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                              color: _goldColor.withOpacity(0.3),
                              width: 0.5),
                        ),
                        child: Text(
                          l.category.name.toUpperCase(),
                          style: TextStyle(
                              color: _goldColor, fontSize: 9.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Navigate button
            GestureDetector(
              onTap: () => _navigate(l),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _goldColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.navigation_outlined,
                        color: Colors.black, size: 14),
                    SizedBox(width: 3.w),
                    Text(
                      'GO',
                      style: GoogleFonts.cinzel(
                        color: Colors.black,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(Landmark l) {
    return Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        color: _goldColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border:
            Border.all(color: _goldColor.withOpacity(0.3), width: 0.5),
      ),
      child: Icon(_categoryIcon(l.category.id), color: _goldColor, size: 24),
    );
  }

  // My Location Button
  Widget _buildMyLocationBtn(MapLoaded state) {
    return GestureDetector(
      onTap: () {
        if (state.userLat != null && state.userLng != null) {
          _mapController.move(
            LatLng(state.userLat!, state.userLng!),
            14.0,
          );
        }
      },
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF141108),
          border: Border.all(
            color: _goldColor.withOpacity(0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location_outlined,
          color: _goldColor,
          size: 20,
        ),
      ),
    );
  }

  // Error View
  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('𓂀',
              style: TextStyle(fontSize: 48, color: Color(0xFF333333))),
          SizedBox(height: 12.h),
          Text(message,
              style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => context.read<MapCubit>().loadMap(),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                border:
                    Border.all(color: _goldColor.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text('RETRY',
                  style: GoogleFonts.cinzel(
                      color: _goldColor,
                      fontSize: 12.sp,
                      letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  
  IconData _categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'temple':   return Icons.temple_buddhist_outlined;
      case 'historic': return Icons.account_balance_outlined;
      case 'museum':   return Icons.museum_outlined;
      case 'nature':   return Icons.park_outlined;
      case 'island':   return Icons.water_outlined;
      default:         return Icons.place_outlined;
    }
  }

  Future<void> _navigate(Landmark l) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${l.latitude},${l.longitude}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}