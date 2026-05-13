import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_cubit.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_state.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.4,
            colors: [Color(0xFF1C1B1B), Color(0xFF131313)],
            stops: [0.0, 0.7],
          ),
        ),
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              );
            }

            if (state is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Color(0xFFD0C5AF),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: const TextStyle(color: Color(0xFFD0C5AF)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          context.read<FavoritesCubit>().loadFavorites(),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is FavoritesLoaded && state.favorites.isEmpty) {
              return const _EmptyState();
            }

            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return const _EmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 120, 24, 32),
                itemCount: state.favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final landmark = state.favorites[index];
                  return LandmarkCard(
                    key: ValueKey(landmark.id),
                    landmark: landmark,
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.landmarkDetails,
                      arguments: landmark,
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFD4AF37),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Favorites',
                      style: TextStyle(
                        fontFamily: 'Noto Serif',
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(width: 48), // نفس عرض الـ IconButton
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Color(0xFFD4AF37)),
          const SizedBox(height: 16),
          const Text(
            'No saved places yet',
            style: TextStyle(
              fontFamily: 'Noto Serif',
              fontSize: 20,
              color: Color(0xFFE5E2E1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any landmark\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: const Color(0xFFD0C5AF).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
