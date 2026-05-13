import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/profile/presentation/cubit/profile_cubit.dart';
import '../widgets/explored_place_card.dart';

class ExploredPage extends StatelessWidget {
  const ExploredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0C0B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0C0B),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: const Text(
          'Explored',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 28,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),

      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {

          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.mainGold,
              ),
            );
          }

          if (state is ProfileError) {
            return const Center(
              child: Text(
                "Unable to load explored places",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is ProfileLoaded) {

            final exploredPlaces = state.recentTrips;

            if (exploredPlaces.isEmpty) {
              return const Center(
                child: Text(
                  "No explored places yet",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [

                const _SectionTitle(
                  title: 'RECENT PLACES',
                ),

                const SizedBox(height: 20),

                ...exploredPlaces.map(
                      (place) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),

                    child: ExploredPlaceCard(

                      name: place.name,

                      location: place.city,

                      dateExplored:
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",

                      icon: Icons.account_balance,

                      onTap: () {

                        Navigator.pushNamed(
                          context,
                          Routes.landmarkDetails,
                          arguments: place,
                        );

                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {

  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFD4AF37).withOpacity(0.2),
          ),
        ),

        const SizedBox(width: 14),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 15,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFD4AF37).withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}