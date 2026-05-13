import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';

class LandmarkGallery extends StatefulWidget {
  const LandmarkGallery({super.key, required this.photos});

  final List<LandmarkPhoto> photos;

  @override
  State<LandmarkGallery> createState() => _LandmarkGalleryState();
}

class _LandmarkGalleryState extends State<LandmarkGallery> {
  late final List<String> _validPhotos;
  final Set<String> _failedPhotos = {};

  @override
  void initState() {
    super.initState();
    _validPhotos = widget.photos
        .map((photo) => LandmarkModel.normalizePhotoUrl(photo.url))
        .whereType<String>()
        .toList(growable: true);
    assert(() {
      if (widget.photos.isNotEmpty) {
        debugPrint('LandmarkGallery raw photo[0]: ${widget.photos.first.url}');
      }
      debugPrint('LandmarkGallery normalized photos: $_validPhotos');
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    final displayPhotos = _validPhotos
        .where((url) => !_failedPhotos.contains(url))
        .toList(growable: false);

    if (displayPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  context.tr('gallery_of_antiquity'),
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
              itemCount: displayPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _galleryCard(context, displayPhotos[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryCard(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 220,
        child: CachedNetworkImage(
          imageUrl: url,
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
                  _failedPhotos.add(url);
                });
              }
            });
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  int _cacheWidth(BuildContext context) {
    return (220 * MediaQuery.of(context).devicePixelRatio).round();
  }

  int _cacheHeight(BuildContext context) {
    return (260 * MediaQuery.of(context).devicePixelRatio).round();
  }
}
