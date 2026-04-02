import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';

class LandmarkGallery extends StatelessWidget {
  const LandmarkGallery({super.key, required this.photos});

  final List<LandmarkPhoto> photos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Gallery of Antiquity',
                  style: GoogleFonts.notoSerif(
                    fontSize: 22,
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

          // Horizontal gallery list.
          SizedBox(
            height: 260,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: photos.isEmpty ? 1 : photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                if (photos.isEmpty) {
                  return _placeholderCard();
                }
                return _galleryCard(photos[index].url);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryCard(String url) {
    final hasValidUrl = _isValidNetworkUrl(url);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 220,
        child: hasValidUrl
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => _placeholderCard(),
                errorWidget: (context, url, error) => _placeholderCard(),
              )
            : _placeholderCard(),
      ),
    );
  }

  Widget _placeholderCard() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.landscape, color: AppColors.mainGold, size: 48),
    );
  }

  bool _isValidNetworkUrl(String url) {
    final parsed = Uri.tryParse(url);
    return parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https');
  }
}
