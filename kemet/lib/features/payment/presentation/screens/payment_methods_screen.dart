// features/payment/presentation/screens/payment_methods_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/strings/failures.dart';
import '../../domain/entities/payment_entities.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/payment_widgets.dart';
import 'webview_screen.dart';
import 'success_screen.dart';
import 'failed_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final double amount;
  final BillingDataEntity billingData;
  final String? orderDescription;
  final void Function(TransactionEntity)? onSuccess;
  final void Function(String)? onFailed;
  final VoidCallback? onCancelled;

  const PaymentMethodsScreen({
    super.key,
    required this.amount,
    required this.billingData,
    this.orderDescription,
    this.onSuccess,
    this.onFailed,
    this.onCancelled,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _walletKey    = GlobalKey<FormState>();
  final _walletCtrl   = TextEditingController();
  bool  _showWallet   = false;

  @override
  void dispose() {
    _walletCtrl.dispose();
    super.dispose();
  }

  void _payCard() {
    setState(() => _showWallet = false);
    context.read<PaymentCubit>().initiateCardPayment(
      amount: widget.amount,
      billingData: widget.billingData,
    );
  }

  void _payWallet() {
    if (!_walletKey.currentState!.validate()) return;
    context.read<PaymentCubit>().initiateWalletPayment(
      amount: widget.amount,
      billingData: widget.billingData,
      walletPhone: _walletCtrl.text.trim(),
    );
  }

  void _openWebView(String url, bool isCard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PaymentCubit>(),
          child: PaymentWebViewScreen(url: url, isCard: isCard),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (ctx, state) {
        if (state is PaymentCardReady)   _openWebView(state.iframeUrl,   true);
        if (state is PaymentWalletReady) _openWebView(state.redirectUrl, false);
        if (state is PaymentSuccess) {
          widget.onSuccess?.call(state.transaction);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(transaction: state.transaction),
            ),
            (r) => r.isFirst,
          );
        }
        if (state is PaymentFailed) {
          widget.onFailed?.call(state.message);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentFailedScreen(
                message: state.message,
                onRetry: () {
                  context.read<PaymentCubit>().reset();
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
        if (state is PaymentCancelled) {
          widget.onCancelled?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(paymentCancelledMessage)),
          );
        }
      },
      child: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (ctx, state) {
          final busy = state is PaymentAuthenticating ||
              state is PaymentRegisteringOrder ||
              state is PaymentGettingKey ||
              state is PaymentWalletLoading;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: const Text(
                    labelChoosePayment,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Summary card ──────────────────────────────────
                      PaymentSummaryCard(
                        amount: widget.amount,
                        description: widget.orderDescription,
                      ),
                      const SizedBox(height: 28),

                      // ── Error banner ──────────────────────────────────
                      if (state is PaymentError) ...[
                        PaymentErrorBanner(
                          message: state.message,
                          onRetry: _showWallet ? _payWallet : _payCard,
                        ),
                        const SizedBox(height: 16),
                      ],

                      const _SectionLabel('SELECT PAYMENT METHOD'),

                      // ── Card ──────────────────────────────────────────
                      _MethodTile(
                        icon: Icons.credit_card_rounded,
                        color: const Color(0xFF1A56DB),
                        title: labelPayByCard,
                        subtitle: labelPayByCardSub,
                        isLoading: busy && !_showWallet,
                        onTap: _payCard,
                      ),
                      const SizedBox(height: 12),

                      // ── Wallet ────────────────────────────────────────
                      _MethodTile(
                        icon: Icons.phone_android_rounded,
                        color: const Color(0xFFE60000),
                        title: labelPayByWallet,
                        subtitle: labelPayByWalletSub,
                        isLoading: busy && _showWallet,
                        onTap: () => setState(() => _showWallet = true),
                      ),

                      // ── Wallet phone input ────────────────────────────
                      if (_showWallet) ...[
                        const SizedBox(height: 20),
                        _WalletForm(
                          formKey: _walletKey,
                          controller: _walletCtrl,
                          busy: busy,
                          onPay: _payWallet,
                        ),
                      ],

                      const SizedBox(height: 32),
                      const _SecureFooter(),
                    ],
                  ),
                ),
              ),
              if (busy) _LoadingOverlay(_loadingMsg(state)),
            ],
          );
        },
      ),
    );
  }

  String _loadingMsg(PaymentState s) {
    if (s is PaymentAuthenticating)   return stepAuthenticating;
    if (s is PaymentRegisteringOrder) return stepCreatingOrder;
    if (s is PaymentGettingKey)       return stepPreparingKey;
    if (s is PaymentWalletLoading)    return stepInitWallet;
    return stepProcessing;
  }
}

// ─── Reusable sub-widgets (local to this screen file) ────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
      );
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: color),
                  )
                : const Icon(Icons.arrow_forward_ios_rounded,
                    size: 15, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _WalletForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onPay;

  const _WalletForm({
    required this.formKey,
    required this.controller,
    required this.busy,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(labelEnterWallet,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 11,
              decoration: InputDecoration(
                labelText: 'Mobile Wallet Number',
                hintText: labelWalletHint,
                counterText: '',
                prefixIcon: const Icon(Icons.phone_android_rounded,
                    color: Color(0xFF64748B), size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1A56DB), width: 1.5)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEF4444))),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final d = v.replaceAll(RegExp(r'\D'), '');
                if (d.length != 11) return 'Must be 11 digits';
                if (!d.startsWith('01')) return 'Must start with 01';
                if (!['010','011','012','015'].contains(d.substring(0,3))) {
                  return 'Enter a valid wallet number';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: busy ? null : onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60000),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.phone_android_rounded, size: 18),
                label: const Text('Pay with Wallet',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecureFooter extends StatelessWidget {
  const _SecureFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.security_rounded, size: 13, color: Color(0xFF94A3B8)),
          SizedBox(width: 5),
          Text(labelSecuredByPaymob,
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ]),
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final String message;
  const _LoadingOverlay(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1A56DB)),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
