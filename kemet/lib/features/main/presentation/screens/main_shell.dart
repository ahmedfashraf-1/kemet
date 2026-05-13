import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/extensions.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:kemet/features/store/presentation/cubit/cart_cubit.dart';
import 'package:kemet/features/store/presentation/screens/cart_screen.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final int activeIndex;
  const MainShell({super.key, required this.child, this.activeIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Map<String, dynamic>> _items = const [
    {'icon': Icons.home_rounded, 'label': 'home'},
    {'icon': Icons.explore_outlined, 'label': 'maps'},
    {'icon': Icons.local_mall_outlined, 'label': 'store'},
    {'icon': Icons.shopping_cart_outlined, 'label': 'cart'},
    {'icon': Icons.miscellaneous_services_outlined, 'label': 'settings'},
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.activeIndex;
  }

  Future<void> _onItemTap(int index) async {
  if (index == _currentIndex) return;

  switch (index) {
    case 0:
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.HomeScreen,
        (route) => false,
      );
      break;

    case 1:
      context.pushNamed(Routes.map);
      break;

    case 2:
      Navigator.of(context).pushReplacementNamed(
        Routes.storeHome,
      );
      break;

    case 3:
      setState(() => _currentIndex = index);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<CartCubit>(),
            child: const CartScreen(),
          ),
        ),
      );

      if (!mounted) return;

      setState(() => _currentIndex = widget.activeIndex);
      break;

    case 4:
      setState(() => _currentIndex = index);

      await Navigator.of(context).pushNamed(
        Routes.settingsScreen,
      );

      if (!mounted) return;

      setState(() => _currentIndex = widget.activeIndex);
      break;

  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: widget.child,
      // Kemet AI is now available from the bottom navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.screenBackground.withOpacity(0.92),
          border: Border(
            top: BorderSide(
              color: AppColors.subtleGoldBorder.withOpacity(0.15),
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
          top: 12.h,
          bottom: MediaQuery.of(context).padding.bottom + 12.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (index) {
            final isActive = _currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _items[index]['icon'] as IconData,
                      color: isActive
                          ? AppColors.mainGold
                          : AppColors.textSecondary,
                      size: 24.sp,
                    ),
                    SizedBox(height: 4.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.tr(_items[index]['label'] as String),
                        style: GoogleFonts.cinzel(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: isActive
                              ? AppColors.mainGold
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}