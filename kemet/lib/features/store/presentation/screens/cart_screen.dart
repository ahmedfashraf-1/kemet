import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

import '../../domain/entities/cart.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const Scaffold(
            backgroundColor: AppColors.screenBackground,
            body: Center(
                child: CircularProgressIndicator(color: AppColors.mainGold)),
          );
        }

        final cart = state is CartLoaded ? state.cart : const Cart();
        final isEmpty = cart.items.isEmpty;

        return Scaffold(
          backgroundColor: AppColors.screenBackground,
          appBar: _buildAppBar(context, cart),
          body: isEmpty
              ? _EmptyCartView(onShop: () => Navigator.pop(context))
              : _CartBody(cart: cart),
          bottomNavigationBar: isEmpty ? null : _buildBottomBar(context, cart),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, Cart cart) {
    return AppBar(
      backgroundColor: AppColors.screenBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.subtleGoldBorder, width: 0.5),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 14, color: AppColors.mainGold),
        ),
      ),
      title: Column(
        children: [
          Text(
            'My Cart',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          if (cart.itemCount > 0)
            Text(
              '${cart.itemCount} Items',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (cart.items.isNotEmpty)
          TextButton(
            onPressed: () => _confirmClear(context),
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  void _confirmClear(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Clear Cart',
                  style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Are you sure you want to remove all items?',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.subtleGoldBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel',
                          style:
                              GoogleFonts.inter(color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(builder: (ctx) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ctx.read<CartCubit>().clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Clear',
                            style: GoogleFonts.inter(color: Colors.white)),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
            top: BorderSide(color: AppColors.subtleGoldBorder, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow('Subtotal', '${cart.subtotal.toStringAsFixed(2)} EGP'),
          const SizedBox(height: 8),
       _SummaryRow(
  'Shipping',
  '${cart.shippingFee.toStringAsFixed(2)} EGP',
),
          const SizedBox(height: 8),
          _SummaryRow('Tax (14%)', '${cart.tax.toStringAsFixed(2)} EGP'),
          const SizedBox(height: 12),
          const Divider(color: AppColors.subtleGoldBorder),
          const SizedBox(height: 12),
          _SummaryRow(
            'Total',
            '${cart.total.toStringAsFixed(2)} EGP',
            isBold: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: navigate to checkout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 18, color: AppColors.textDarkOnGold),
                  const SizedBox(width: 8),
                  Text(
                    'Checkout  •  ${cart.total.toStringAsFixed(2)} EGP',
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDarkOnGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart Body ─────────────────────────────────────────────────────────────────

class _CartBody extends StatelessWidget {
  final Cart cart;
  const _CartBody({required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _CartItemCard(item: cart.items[i]),
    );
  }
}

// ── Cart Item Card ────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final photoUrl = item.product.photos.isNotEmpty
        ? item.product.photos.first.photoUrl
        : '';

    return Dismissible(
      key: Key(item.product.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
        ),
      ),
      onDismissed: (_) =>
          context.read<CartCubit>().remove(item.product.productId),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.subtleGoldBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.product.category.categoryName,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.product.price.toStringAsFixed(2)} EGP',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} EGP',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mainGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QuantitySelector(
                        quantity: item.quantity,
                        onDecrement: () {
                          if (item.quantity == 1) {
                            context
                                .read<CartCubit>()
                                .remove(item.product.productId);
                          } else {
                            context.read<CartCubit>().update(
                                  item.product.productId,
                                  item.quantity - 1,
                                );
                          }
                        },
                        onIncrement: () => context
                            .read<CartCubit>()
                            .update(
                              item.product.productId,
                              item.quantity + 1,
                            ),
                      ),

                      GestureDetector(
                        onTap: () => context
                            .read<CartCubit>()
                            .remove(item.product.productId),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  Colors.redAccent.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: AppColors.inputBackground,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.subtleGoldBorder,
      ),
    );
  }
}

// ── Quantity Selector ─────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded, onDecrement, quantity > 1),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _btn(Icons.add_rounded, onIncrement, true),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: enabled ? AppColors.mainGold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 13,
            color: enabled
                ? AppColors.textDarkOnGold
                : AppColors.textSecondary.withOpacity(0.3)),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value,
      {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ??
                (isBold ? AppColors.mainGold : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ── Empty Cart ────────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCartView({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.subtleGoldBorder),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 56, color: AppColors.subtleGoldBorder),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty!',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping and add some items.',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onShop,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainGold,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Shop Now',
                style: GoogleFonts.cinzel(
                    color: AppColors.textDarkOnGold,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}