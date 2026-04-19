import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkHeroSection extends StatelessWidget {
  const LandmarkHeroSection({
    super.key,
    required this.landmark,
    required this.onBack,
    required this.isFavorite,
    this.onFavorite,
    this.onShare,
  });

  final Landmark landmark;
  final VoidCallback onBack;
  final bool isFavorite;
  final VoidCallback? onFavorite;  final Future<void> Function(BuildContext context)? onShare;

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.of(context).size.height * 0.68;
    final imageUrl = landmark.photos.isNotEmpty
        ? landmark.photos.first.url
        : '';
    final isAsset = _isAssetPath(imageUrl);
    final isAppUrl = _isAppStorageUrl(imageUrl);

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          // Hero image with gradient overlay.
          Positioned.fill(
            child: Hero(
              tag: _heroTag(landmark.id),
              child: isAsset
                  ? Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, url, error) => _buildPlaceholder(),
                    )
                  : isAppUrl
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildPlaceholder(),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x1A000000),
                    Color(0x66000000),
                    Color(0xFF131313),
                  ],
                  stops: [0.1, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Top navigation shell.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIcon(icon: Icons.arrow_back, onTap: onBack),
                  Text(
                    'THE CURATOR',
                    style: GoogleFonts.notoSerif(
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      color: AppColors.mainGold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      _circleIcon(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border, 
                        onTap: onFavorite,
                        filled: isFavorite, 
                      ),
                      const SizedBox(width: 6),
                      _circleIcon(icon: Icons.share, onTapWithContext: onShare),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Title and location overlay.
          Positioned(
            left: 18,
            right: 18,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.subtleGoldBorder.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    landmark.category.name.toUpperCase(),
                    style: GoogleFonts.notoSerif(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.mainGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  landmark.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerif(
                    fontSize: 38,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      landmark.city.toUpperCase(),
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon({
    required IconData icon,
    VoidCallback? onTap,
    Future<void> Function(BuildContext context)? onTapWithContext,
    bool filled = false,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap:
            onTap ??
            (onTapWithContext == null ? null : () => onTapWithContext(context)),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? AppColors.mainGold.withOpacity(0.15)
                : AppColors.screenBackground.withOpacity(0.5),
            border: Border.all(color: AppColors.subtleGoldBorder),
          ),
          child: Icon(icon, color: AppColors.mainGold, size: 20),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'images/heroScreen.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF161616),
        child: Icon(Icons.landscape, color: AppColors.mainGold, size: 64),
      ),
    );
  }

  bool _isAssetPath(String url) {
    return url.startsWith('images/') || url.startsWith('assets/');
  }

  bool _isAppStorageUrl(String url) {
    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      return false;
    }
    if (parsed.scheme == 'gs') {
      return true;
    }
    final host = parsed.host.toLowerCase();
    return host.contains('firebasestorage.googleapis.com') ||
        host.contains('storage.googleapis.com');
  }

  String _heroTag(String id) => 'landmark-hero-$id';
}
