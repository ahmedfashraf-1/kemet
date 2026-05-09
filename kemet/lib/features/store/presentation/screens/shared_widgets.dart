import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            body: Center(child: CircularProgressIndicator(color: AppColors.mainGold)),
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
              size: 18, color: AppColors.mainGold),
        ),
      ),
      title: Column(
        children: [
          const Text(
            'My Cart',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          if (cart.itemCount > 0)
            Text(
              '${cart.itemCount} Items',
              style: const TextStyle(
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
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
              const Text('Clear Cart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Are you sure you want to remove all items?',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.subtleGoldBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Clear All', style: TextStyle(color: Colors.white)),
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
            cart.hasFreeShipping ? 'Free 🎉' : '${cart.shippingFee.toStringAsFixed(2)} EGP',
            valueColor: cart.hasFreeShipping ? Colors.greenAccent : null,
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textDarkOnGold),
                  const SizedBox(width: 8),
                  Text(
                    'Checkout  •  ${cart.total.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
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

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final photoUrl = item.product.photos.isNotEmpty ? item.product.photos.first.photoUrl : '';

    return Dismissible(
      key: Key(item.product.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
      onDismissed: (_) => context.read<CartCubit>().remove(item.product.productId),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.subtleGoldBorder, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      width: 80,
                      height: 80,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    item.product.category.categoryName,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} EGP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mainGold,
                        ),
                      ),
                      _QuantitySelector(
                        quantity: item.quantity,
                        onDecrement: () {
                          if (item.quantity == 1) {
                            context.read<CartCubit>().remove(item.product.productId);
                          } else {
                            context.read<CartCubit>().update(item.product.productId, item.quantity - 1);
                          }
                        },
                        onIncrement: () => context.read<CartCubit>().update(item.product.productId, item.quantity + 1),
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
      width: 80,
      height: 80,
      color: AppColors.inputBackground,
      child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
    );
  }
}

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
        children: [
          _btn(Icons.remove_rounded, onDecrement, quantity > 1),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled ? AppColors.mainGold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: enabled ? AppColors.textDarkOnGold : AppColors.textSecondary.withOpacity(0.3)),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: isBold ? 16 : 14)),
        Text(value, style: TextStyle(color: valueColor ?? (isBold ? AppColors.mainGold : AppColors.textPrimary), 
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, fontSize: isBold ? 18 : 14)),
      ],
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCartView({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.subtleGoldBorder),
          const SizedBox(height: 24),
          const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Looks like you haven\'t added anything yet.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onShop,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainGold,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Shop Now', style: TextStyle(color: AppColors.textDarkOnGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}