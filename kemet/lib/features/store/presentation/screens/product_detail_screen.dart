import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_photo.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/product_detail_cubit.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailCubit(),
      child: _ProductDetailView(product: product),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final Product product;
  const _ProductDetailView({required this.product});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _btn(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? AppColors.mainGold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.textDarkOnGold : AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, state, product),
              SliverToBoxAdapter(
                child: _buildContent(context, state, product),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) => _buildBottomBar(context, state, product),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ProductDetailState state,
    Product product,
  ) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.screenBackground,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.subtleGoldBorder, width: 0.5),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.mainGold),
        ),
      ),
        actions: [
         Padding(
           padding: const EdgeInsetsDirectional.only(end: 16),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final count =
                  cartState is CartLoaded ? cartState.cart.items.length : 0;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CartCubit>(),
                      child: const CartScreen(),
                    ),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.subtleGoldBorder, width: 0.5),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.mainGold, size: 22),
                    ),
                         if (count > 0)
                                 PositionedDirectional(
                                   end: -4,
                                   top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _ImageSlider(
          photos: product.photos,
          currentIndex: state.selectedImageIndex,
          controller: _pageController,
          onPageChanged: (i) =>
              context.read<ProductDetailCubit>().selectImage(i),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductDetailState state,
    Product product,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.photos.length > 1)
            _DotsIndicator(
              count: product.photos.length,
              current: state.selectedImageIndex,
            ),
          const SizedBox(height: 20),
          Builder(builder: (ctx) {
            final isAr = Localizations.localeOf(ctx).languageCode == 'ar';
            final catLabel = product.category.localizedName(isAr ? 'ar' : 'en');
            return _CategoryChip(catLabel);
          }),
          const SizedBox(height: 12),
          Builder(builder: (ctx) {
            final isAr = Localizations.localeOf(ctx).languageCode == 'ar';
            final title = product.localizedName(isAr ? 'ar' : 'en');
            return Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          }),
          const SizedBox(height: 16),
          Text(
            '${product.price.toStringAsFixed(2)} ${context.tr('currency')}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.mainGold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: product.stock > 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: product.stock > 0
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Text(
              product.stock > 0
                  ? '${context.tr('in_stock')} (${product.stock})'
                  : context.tr('out_of_stock'),
              style: TextStyle(
                color: product.stock > 0 ? Colors.green : Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.subtleGoldBorder),
          const SizedBox(height: 20),
           Text(
             context.tr('description'),
             style: const TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: AppColors.textPrimary,
             ),
           ),
          const SizedBox(height: 10),
          Builder(builder: (ctx) {
            final isAr = Localizations.localeOf(ctx).languageCode == 'ar';
            final desc = product.localizedDescription(isAr ? 'ar' : 'en');
            return Text(
              desc,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ProductDetailState state,
    Product product,
  ) {
    final isOutOfStock = product.stock <= 0;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _btn(
                  Icons.remove_rounded,
                  () => context.read<ProductDetailCubit>().decrement(),
                  state.quantity > 1,
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${state.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _btn(
                  Icons.add_rounded,
                  () => context
                      .read<ProductDetailCubit>()
                      .increment(product.stock),
                  true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BlocConsumer<CartCubit, CartState>(
              listener: (context, cartState) {
                if (cartState is CartLoaded) {
                  _showAddedSnackBar(context);
                }
              },
              listenWhen: (prev, curr) =>
                  prev is CartLoading && curr is CartLoaded,
              builder: (context, cartState) {
                final isLoading = cartState is CartLoading;

                return ElevatedButton(
                   onPressed: isOutOfStock || isLoading
                       ? null
                       : () {
                           context.read<CartCubit>().add(product, state.quantity);
                           context.read<ProductDetailCubit>().reset();
                         },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isOutOfStock ? Colors.grey : AppColors.mainGold,
                    foregroundColor: AppColors.textDarkOnGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textDarkOnGold,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                               isOutOfStock ? context.tr('out_of_stock') : context.tr('add_to_cart'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr('added_to_cart'),
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.textDarkOnGold),
        ),
        backgroundColor: AppColors.mainGold,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Sub Widgets ───────────────────────────────────────────────────────────────

class _ImageSlider extends StatelessWidget {
  final List<ProductPhoto> photos;
  final int currentIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  const _ImageSlider({
    required this.photos,
    required this.currentIndex,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        color: AppColors.inputBackground,
        child: const Icon(Icons.image_outlined,
            size: 64, color: AppColors.subtleGoldBorder),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: controller,
          onPageChanged: onPageChanged,
          itemCount: photos.length,
          itemBuilder: (_, i) => Image.network(
            photos[i].photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.inputBackground,
              child: const Icon(Icons.image_outlined,
                  size: 64, color: AppColors.subtleGoldBorder),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 0,
          start: 0,
          end: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.screenBackground.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.mainGold : AppColors.subtleGoldBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip(this.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mainGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.mainGold.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.mainGold,
        ),
      ),
    );
  }
}