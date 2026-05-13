import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkHeroSection extends StatefulWidget {
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
  State<LandmarkHeroSection> createState() => _LandmarkHeroSectionState();
}

class _LandmarkHeroSectionState extends State<LandmarkHeroSection> {
  bool _imageFailed = false;

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.of(context).size.height * 0.68;
    final imageUrl = _firstValidPhotoUrl(widget.landmark);

    assert(() {
      if (widget.landmark.photos.isNotEmpty) {
        debugPrint(
          'LandmarkHero raw photo[0]: ${widget.landmark.photos.first.url} for id=${widget.landmark.id}',
        );
      }
      debugPrint('LandmarkHero resolved imageUrl: $imageUrl for id=${widget.landmark.id}');
      return true;
    }());

    if (imageUrl == null || _imageFailed) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          // Hero image with gradient overlay.
          Positioned.fill(
            child: Hero(
              tag: _heroTag(widget.landmark.id),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                httpHeaders: const {
                  'User-Agent': 'KEMET/1.0 (+https://kemet.app)',
                  'Referer': 'https://commons.wikimedia.org/',
                  'Accept': 'image/avif,image/webp,image/*,*/*;q=0.8',
                },
                fit: BoxFit.cover,
                memCacheWidth: _cacheWidth(context),
                memCacheHeight: _cacheHeight(context),
                maxWidthDiskCache: _cacheWidth(context),
                maxHeightDiskCache: _cacheHeight(context),
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                useOldImageOnUrlChange: false,
                errorWidget: (context, url, error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _imageFailed = true;
                      });
                    }
                  });
                  return const SizedBox.shrink();
                },
              ),
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
                   _circleIcon(icon: Icons.arrow_back, onTap: widget.onBack),
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
                        icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border, 
                        onTap: widget.onFavorite,
                        filled: widget.isFavorite, 
                      ),
                      const SizedBox(width: 6),
                      _circleIcon(icon: Icons.share, onTapWithContext: widget.onShare),
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
                    widget.landmark.category.name.toUpperCase(),
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
                  widget.landmark.name,
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
                      widget.landmark.city.toUpperCase(),
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

  int _cacheWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return (size.width * MediaQuery.of(context).devicePixelRatio).round();
  }

  int _cacheHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * 0.68;
    return (heroHeight * MediaQuery.of(context).devicePixelRatio).round();
  }

  String? _firstValidPhotoUrl(Landmark landmark) {
    return LandmarkModel.firstValidPhotoUrl(landmark);
  }

  String _heroTag(String id) => 'landmark-hero-$id';
}
