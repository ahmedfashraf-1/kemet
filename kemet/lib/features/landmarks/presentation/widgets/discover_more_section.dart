import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class DiscoverMoreSection extends StatelessWidget {
  const DiscoverMoreSection({
    super.key,
    required this.landmark,
    required this.photos,
  });

  final Landmark landmark;
  final List<LandmarkPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final displayPhotos = photos.isEmpty ? <LandmarkPhoto>[] : photos;

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Discover More in ${landmark.city}',
                  style: GoogleFonts.notoSerif(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.mainGold.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal cards.
          SizedBox(
            height: 230,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: displayPhotos.isEmpty ? 1 : displayPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (displayPhotos.isEmpty) {
                  return _discoverCard(null);
                }
                return _discoverCard(displayPhotos[index].url);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _discoverCard(String? url) {
    final hasValidUrl = url != null && _isValidNetworkUrl(url);
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.subtleGoldBorder.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: hasValidUrl
                ? CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _photoPlaceholder(),
                    errorWidget: (context, url, error) => _photoPlaceholder(),
                  )
                : _photoPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  landmark.category.name.toUpperCase(),
                  style: GoogleFonts.notoSerif(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: AppColors.mainGold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  landmark.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerif(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Icon(Icons.photo, color: AppColors.mainGold, size: 40),
    );
  }

  bool _isValidNetworkUrl(String url) {
    final parsed = Uri.tryParse(url);
    return parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https');
  }
}
