import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_cubit.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_state.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkCard extends StatefulWidget {
  final Landmark landmark;
  final VoidCallback onTap;

  const LandmarkCard({
    super.key,
    required this.landmark,
    required this.onTap,
  });

  @override
  State<LandmarkCard> createState() => _LandmarkCardState();
}

class _LandmarkCardState extends State<LandmarkCard> {
  bool _imageFailed = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _firstValidPhotoUrl(widget.landmark);
    assert(() {
      if (widget.landmark.photos.isNotEmpty) {
        debugPrint(
          'LandmarkCard raw photo[0]: ${widget.landmark.photos.first.url} for id=${widget.landmark.id}',
        );
      }
      debugPrint('LandmarkCard resolved imageUrl: $imageUrl for id=${widget.landmark.id}');
      return true;
    }());
    if (imageUrl == null) {
      return const SizedBox.shrink();
    }

    if (_imageFailed) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x66353535),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33D4AF37)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Thumbnail ─────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 112,
                  height: 112,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    httpHeaders: const {
                      'User-Agent': 'KEMET/1.0 (+https://kemet.app)',
                      'Referer': 'https://commons.wikimedia.org/',
                      'Accept': 'image/avif,image/webp,image/*,*/*;q=0.8',
                    },
                    fit: BoxFit.cover,
                    memCacheWidth: 224,
                    memCacheHeight: 224,
                    maxWidthDiskCache: 224,
                    maxHeightDiskCache: 224,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    useOldImageOnUrlChange: false,
                    errorWidget: (_, __, ___) {
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

              const SizedBox(width: 16),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: ConstrainedBox (
                constraints: const BoxConstraints(minHeight: 112),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.landmark.name,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: Color(0xFFE5E2E1),
                              ),
                            ),
                          ),

                          // ── Heart button ──────────────────────────────
                          BlocBuilder<FavoritesCubit, FavoritesState>(
                            builder: (context, state) {
                              final isFav = state is FavoritesLoaded
                                  ? state.isFavorite(widget.landmark.id)
                                  : false;

                              return GestureDetector(
                                onTap: () => context
                                    .read<FavoritesCubit>()
                                    .toggle(widget.landmark.id),
                                child: AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                          scale: anim, child: child),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    key: ValueKey(isFav),
                                    color: const Color(0xFFD4AF37),
                                    size: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      Text(
                        widget.landmark.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: Color(0xFFD0C5AF),
                          height: 1.5,
                        ),
                      ),

                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: Color(0xFFF2CA50)),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.landmark.city}, Egypt',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              color: Color(0xFFF2CA50),
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _firstValidPhotoUrl(Landmark landmark) {
    return LandmarkModel.firstValidPhotoUrl(landmark);
  }
}