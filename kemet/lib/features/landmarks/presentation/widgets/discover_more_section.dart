import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';

class DiscoverMoreSection extends StatefulWidget {
  const DiscoverMoreSection({super.key, required this.landmark});

  final Landmark landmark;

  @override
  State<DiscoverMoreSection> createState() => _DiscoverMoreSectionState();
}

class _DiscoverMoreSectionState extends State<DiscoverMoreSection> {
  late Future<List<Landmark>> _suggestionsFuture;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _suggestionsFuture = _fetchSuggestions(context);
      _didLoad = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityLabel = _resolvedCityLabel(widget.landmark.city);

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
                  cityLabel == null
                      ? context.tr('discover_more_nearby')
                      : context.tr(
                          'discover_more_in',
                          args: {'city': cityLabel},
                        ),
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
          FutureBuilder<List<Landmark>>(
            future: _suggestionsFuture,
            builder: (context, snapshot) {
              final suggestions = snapshot.data ?? <Landmark>[];
              final displayItems = _buildDisplayItems(suggestions);
              return SizedBox(
                height: 230,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: displayItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final card = _discoverCard(
                      displayItems[index],
                      isLoading:
                          snapshot.connectionState == ConnectionState.waiting,
                    );
                    return _wrapClickableCard(
                      context,
                      displayItems[index],
                      card,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Landmark>> _fetchSuggestions(BuildContext context) async {
    final city = widget.landmark.city.trim();
    if (city.isEmpty || city.toLowerCase() == 'unknown') {
      return [];
    }

    final repository = context.read<LandmarksRepository>();
    final languageCode = Localizations.localeOf(context).languageCode;
    final firstBatch = await repository.getAllLandmarks(
      page: 1,
      limit: 12,
      city: city,
      languageCode: languageCode,
    );

    final collected = <Landmark>[];
    collected.addAll(_filterUnique(firstBatch, collected));

    if (collected.length < 4) {
      final secondBatch = await repository.getAllLandmarks(
        page: 2,
        limit: 12,
        city: city,
        languageCode: languageCode,
      );
      collected.addAll(_filterUnique(secondBatch, collected));
    }

    return collected.take(4).toList();
  }

  List<Landmark> _filterUnique(dynamic response, List<Landmark> existing) {
    if (response == null) {
      return [];
    }

    final existingIds = existing.map((item) => item.id).toSet();
    final currentId = widget.landmark.id;

    final List<Landmark> newItems = response.fold(
      (_) => <Landmark>[],
      (landmarks) => landmarks,
    );

    return newItems.where((landmark) {
      return landmark.id != currentId && !existingIds.contains(landmark.id);
    }).toList();
  }

  List<Landmark?> _buildDisplayItems(List<Landmark> suggestions) {
    final items = suggestions.take(4).toList();
    return items;
  }

  String? _resolvedCityLabel(String rawCity) {
    final trimmed = rawCity.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'unknown') {
      return null;
    }
    return trimmed;
  }

  Widget _discoverCard(Landmark? suggestion, {required bool isLoading}) {
    final url = suggestion?.photos.isNotEmpty == true
        ? suggestion!.photos.first.url
        : null;
    final hasValidUrl = url != null && _isValidNetworkUrl(url);
    final isPlaceholder = suggestion == null;
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
                  isPlaceholder
                      ? (isLoading
                            ? context.tr('loading').toUpperCase()
                            : context.tr('suggestion').toUpperCase())
                      : suggestion.category.name.toUpperCase(),
                  style: GoogleFonts.notoSerif(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: AppColors.mainGold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPlaceholder
                      ? (isLoading
                            ? context.tr('loading_ellipsis')
                            : context.tr('more_to_explore'))
                      : suggestion.name,
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

  Widget _wrapClickableCard(
    BuildContext context,
    Landmark? suggestion,
    Widget card,
  ) {
    if (suggestion == null) {
      return card;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(Routes.landmarkDetails, arguments: suggestion);
      },
      child: card,
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
