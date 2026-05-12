import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/services/validation_service.dart';
import 'package:kemet/features/payment/domain/entities/payment_entities.dart';
import 'package:kemet/features/store/domain/entities/cart.dart';
import 'package:kemet/features/store/presentation/cubit/cart_cubit.dart';
import 'package:kemet/features/payment/presentation/screens/payment_methods_screen.dart';
import 'package:kemet/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:kemet/features/order/domain/entities/order.dart'
    as order_entity;
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _postalCtrl;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _streetCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _postalCtrl = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;

    final billingData = BillingDataEntity(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
    );

    context.read<CheckoutCubit>().createOrderFromCart(
      cart: widget.cart,
      billingData: billingData,
    );
  }

  Future<void> _handlePaymentSuccess(
    TransactionEntity transaction,
    order_entity.Order order,
  ) async {
    // Mark payment as successful in the order
    context.read<CheckoutCubit>().markPaymentSuccess(
      orderId: order.orderId,
      transactionId: transaction.transactionId,
    );

    // Clear the cart
    context.read<CartCubit>().clearCart();

    // Navigate to order confirmation
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        Routes.orderConfirmation,
        arguments: order,
      );
    }
  }

  void _handlePaymentFailed(String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Payment failed: $error')));
  }

  void _handlePaymentCancelled() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (ctx, state) {
        if (state is OrderCreated) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PaymentCubit>(),
                child: PaymentMethodsScreen(
                  amount: state.order.totalPrice,
                  billingData: BillingDataEntity(
                    firstName: _firstNameCtrl.text.trim(),
                    lastName: _lastNameCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    street: _streetCtrl.text.trim(),
                    city: _cityCtrl.text.trim(),
                    postalCode: _postalCtrl.text.trim(),
                  ),
                  orderDescription: 'Order #${state.order.orderId}',
                  onSuccess: (transaction) =>
                      _handlePaymentSuccess(transaction, state.order),
                  onFailed: _handlePaymentFailed,
                  onCancelled: _handlePaymentCancelled,
                ),
              ),
            ),
          );
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: AppBar(
          backgroundColor: AppColors.screenBackground,
          elevation: 0,
          title: Text(
            'Checkout',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.mainGold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (ctx, state) {
            final isLoading = state is CheckoutLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(),
                  const SizedBox(height: 32),

                  // Billing Form
                  Text(
                    'Billing Information',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _firstNameCtrl,
                          label: 'First Name',
                          validator: ValidationService.validateName,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _lastNameCtrl,
                          label: 'Last Name',
                          validator: ValidationService.validateName,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: ValidationService.validateEmail,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _phoneCtrl,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: ValidationService.validatePhone,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _streetCtrl,
                          label: 'Street Address',
                          validator: ValidationService.validateAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _cityCtrl,
                          label: 'City',
                          validator: ValidationService.validateCity,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _postalCtrl,
                          label: 'Postal Code',
                          keyboardType: TextInputType.number,
                          validator: ValidationService.validatePostalCode,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Proceed to Payment',
                              style: GoogleFonts.cinzel(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDarkOnGold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleGoldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Items (${widget.cart.itemCount})',
            '${widget.cart.subtotal.toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            'Shipping',
            '${widget.cart.shippingFee.toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: 8),
          _summaryRow('Tax (14%)', '${widget.cart.tax.toStringAsFixed(2)} EGP'),
          const SizedBox(height: 12),
          const Divider(color: AppColors.subtleGoldBorder),
          const SizedBox(height: 12),
          _summaryRow(
            'Total',
            '${widget.cart.total.toStringAsFixed(2)} EGP',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.mainGold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.subtleGoldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.subtleGoldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mainGold),
        ),
      ),
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      validator: validator,
    );
  }
}
