import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/store/domain/entities/product.dart';
import 'package:kemet/features/store/presentation/cubit/products_cubit.dart';
import 'package:kemet/features/store/presentation/cubit/products_state.dart';
import 'package:kemet/features/store/presentation/cubit/cart_cubit.dart';
import 'package:kemet/features/store/presentation/screens/product_detail_screen.dart';
import 'package:kemet/features/store/presentation/screens/store_hero_slider.dart';
import 'package:kemet/features/store/presentation/screens/store_categories.dart';
import 'package:kemet/features/notifications/presentation/widgets/notification_bell_button.dart';
import 'package:kemet/features/profile/presentation/widgets/profile_avatar_button.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  String _selectedCategory = 'All';
  static const Color _bgColor = Color(0xFF111111);
  static const Color _goldColor = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().getProducts();
  }

  String? _readPhotoUrl(Map<String, dynamic>? data) {
    if (data == null) return null;
    return data['photoUrl'] ?? data['image'] ?? data['profileImage'];
  }

  Future<void> _openProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    Navigator.of(context).pushNamed(Routes.profileScreen, arguments: user.uid);
  }

  Future<void> _logout() async {
    await context.read<SettingsCubit>().clearProfileAvatar();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/onLoginScreen', (_) => false);
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((p) {
      return _selectedCategory == 'All' ||
          p.category.categoryName == _selectedCategory;
    }).toList();
  }

  List<String> _getCategories(List<Product> products) {
    final cats = products.map((p) => p.category.categoryName).toSet().toList();
    return ['All', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.mainGold),
              );
            }

            if (state is ProductsError) {
              return _buildErrorState(state.message);
            }

            final products =
                state is ProductsSuccess ? state.products : <Product>[];
            final filtered = _filterProducts(products);
            final categories = _getCategories(products);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      const StoreHeroSlider(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoriesHeaderDelegate(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory == 'All'
                              ? 'All Products'
                              : _selectedCategory,
                          style: GoogleFonts.cinzel(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${filtered.length} item${filtered.length != 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                filtered.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 4.h),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14.w,
                            mainAxisSpacing: 14.h,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _ProductCard(
                              product: filtered[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<CartCubit>(),
                                    child: ProductDetailScreen(
                                        product: filtered[index]),
                                  ),
                                ),
                              ),
                            ),
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _bgColor,
      padding: EdgeInsets.only(
        top: 8.h,
        left: 24.w,
        right: 24.w,
        bottom: 12.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
              final isGuest = user == null || user.isAnonymous;
              if (isGuest) {
                return ProfileAvatarButton(
                  name: 'Guest',
                  email: '',
                  isGuest: true,
                  onViewProfile: _openProfile,
                  onLogout: _logout,
                );
              }
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, userDocSnapshot) {
                  final data = userDocSnapshot.data?.data();
                  final photoUrl = _readPhotoUrl(data);
                  return ProfileAvatarButton(
                    name: user.displayName?.trim().isNotEmpty == true
                        ? user.displayName!.trim()
                        : 'User',
                    email: user.email ?? '',
                    photoUrl: photoUrl,
                    isGuest: false,
                    onViewProfile: _openProfile,
                    onLogout: _logout,
                  );
                },
              );
            },
          ),
          Text(
            'KEMET',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
              color: _goldColor,
              letterSpacing: 5,
            ),
          ),
          const NotificationBellButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56.sp, color: AppColors.subtleGoldBorder),
          SizedBox(height: 16.h),
          Text('No products found',
              style: GoogleFonts.cinzel(
                  fontSize: 16.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 56.sp, color: AppColors.subtleGoldBorder),
          SizedBox(height: 16.h),
          Text('Something went wrong',
              style: GoogleFonts.cinzel(
                  fontSize: 16.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  _CategoriesHeaderDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  double get minExtent => 104;
  @override
  double get maxExtent => 104;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF111111),
      child: StoreCategoriesBar(
        categories: categories,
        selectedCategory: selectedCategory,
        onCategorySelected: onCategorySelected,
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoriesHeaderDelegate oldDelegate) =>
      oldDelegate.selectedCategory != selectedCategory ||
      oldDelegate.categories != categories;
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final photoUrl =
        product.photos.isNotEmpty ? product.photos.first.photoUrl : null;

    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) {
        _pressController.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _pressController,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.subtleGoldBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.r)),
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: photoUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.inputBackground,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.mainGold.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.screenBackground.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: AppColors.subtleGoldBorder),
                        ),
                        child: Text(
                          product.category.categoryName.toUpperCase(),
                          style: GoogleFonts.cinzel(
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainGold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        '${product.price.toStringAsFixed(2)} EGP',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mainGold,
                        ),
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

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.inputBackground,
      child: Center(
        child: Icon(Icons.image_outlined,
            size: 36.sp, color: AppColors.subtleGoldBorder),
      ),
    );
  }
}