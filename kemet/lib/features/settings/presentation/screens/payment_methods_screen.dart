import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/features/settings/presentation/cubit/payment_methods_cubit.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: SettingsVisuals.pageBackground,
          appBar: AppBar(
            backgroundColor: SettingsVisuals.pageBackground,
            elevation: 0,
            centerTitle: true,
            title: PremiumHeader(title: context.tr('payment_methods').toUpperCase()),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              children: [
                PremiumCard(
                  children: [
                    ...state.cards.asMap().entries.expand((entry) {
                      final index = entry.key;
                      final card = entry.value;
                      return [
                        _paymentCardTile(
                          context,
                          brand: card.brand,
                          last4: card.last4,
                          holderName: card.holderName,
                          expiry: card.expiry,
                          isDefault: card.isDefault,
                          onDefaultTap: () => context.read<PaymentMethodsCubit>().setDefault(card.id),
                          onDeleteTap: () => _confirmDelete(context, card.id),
                        ),
                        if (index != state.cards.length - 1) const PremiumDivider(),
                      ];
                    }),
                  ],
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCardDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A34E),
                      foregroundColor: const Color(0xFF151008),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    icon: const Icon(Icons.add_card_outlined),
                    label: Text(context.tr('add_new_card')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paymentCardTile(
    BuildContext context, {
    required String brand,
    required String last4,
    required String holderName,
    required String expiry,
    required bool isDefault,
    required VoidCallback onDefaultTap,
    required VoidCallback onDeleteTap,
  }) {
    return PremiumTileShell(
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: const Color(0x22C9A34E)),
            ),
            child: Icon(Icons.credit_card_outlined, color: AppColors.mainGold, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$brand •••• $last4',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$holderName · Exp $expiry',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: onDefaultTap,
                  child: Text(
                    isDefault ? context.tr('default_card') : context.tr('set_default_card'),
                    style: TextStyle(
                      color: isDefault ? AppColors.mainGold : Colors.white70,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDeleteTap,
            icon: const Icon(Icons.delete_outline, color: SettingsVisuals.dangerColor),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SettingsVisuals.cardBackground,
        title: Text(context.tr('delete_card_title')),
        content: Text(context.tr('delete_card_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: SettingsVisuals.dangerColor),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (shouldDelete == true && context.mounted) {
      await context.read<PaymentMethodsCubit>().deleteCard(id);
    }
  }

  Future<void> _showAddCardDialog(BuildContext context) async {
    final brand = TextEditingController(text: 'Visa');
    final last4 = TextEditingController();
    final holder = TextEditingController();
    final expiry = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SettingsVisuals.cardBackground,
        title: Text(context.tr('add_card_title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(brand, context.tr('brand')),
              SizedBox(height: 10.h),
              _field(last4, context.tr('last4'), keyboardType: TextInputType.number),
              SizedBox(height: 10.h),
              _field(holder, context.tr('cardholder_name')),
              SizedBox(height: 10.h),
              _field(expiry, context.tr('expiry')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.tr('cancel'))),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(context.tr('save'))), 
        ],
      ),
    );

    if (added == true && context.mounted) {
      await context.read<PaymentMethodsCubit>().addCard(
            brand: brand.text.trim().isEmpty ? context.tr('brand_default') : brand.text.trim(),
            last4: last4.text.trim().padLeft(4, '0').substring(0, 4),
            holderName: holder.text.trim().isEmpty ? context.tr('holder_default') : holder.text.trim(),
            expiry: expiry.text.trim().isEmpty ? context.tr('expiry_default') : expiry.text.trim(),
          );
    }
  }

  Widget _field(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
      ),
    );
  }
}

