import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_cubit.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_state.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkCard extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback onTap;

  const LandmarkCard({
    super.key,
    required this.landmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  child: landmark.photos.isNotEmpty
                      ? Image.network(
                          landmark.photos.first.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Color(0xFF20201F),
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey),
                          ),
                        )
                      : const ColoredBox(color: Color(0xFF20201F)),
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
                              landmark.name,
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
                                  ? state.isFavorite(landmark.id)
                                  : false;

                              return GestureDetector(
                                onTap: () => context
                                    .read<FavoritesCubit>()
                                    .toggle(landmark.id),
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
                        landmark.description,
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
                            '${landmark.city}, Egypt',
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
}