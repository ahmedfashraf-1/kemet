// features/payment/presentation/screens/success_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/strings/failures.dart';
import '../../domain/entities/payment_entities.dart';
import '../widgets/payment_widgets.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final TransactionEntity transaction;
  const PaymentSuccessScreen({super.key, required this.transaction});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                // ── Animated check icon ───────────────────────────────
                ScaleTransition(
                  scale: _scale,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Container(
                      width: 100, height: 100,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD1FAE5)),
                      child: const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fade,
                  child: const Text(labelPaymentSuccess,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    '${(tx.amountCents / 100).toStringAsFixed(2)} ${tx.currency}',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Transaction details ───────────────────────────────
                FadeTransition(
                  opacity: _fade,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      children: [
                        TransactionDetailRow(
                            label: labelTransactionId,
                            value: '#${tx.transactionId}',
                            bold: true),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        TransactionDetailRow(
                            label: labelOrderAmount,
                            value: '${(tx.amountCents / 100).toStringAsFixed(2)} ${tx.currency}'),
                        const SizedBox(height: 8),
                        TransactionDetailRow(
                            label: labelStatus,
                            value: labelPaid,
                            valueColor: const Color(0xFF10B981)),
                        const SizedBox(height: 8),
                        TransactionDetailRow(
                            label: 'Date',
                            value: _fmt(tx.createdAt)),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                PayNowButton(
                  label: labelBackToHome,
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(String raw) {
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.day}/${d.month}/${d.year}  '
          '${d.hour.toString().padLeft(2,'0')}:'
          '${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return raw; }
  }
}
