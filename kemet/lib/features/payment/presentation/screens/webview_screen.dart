// features/payment/presentation/screens/webview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/strings/failures.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'success_screen.dart';
import 'failed_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final bool isCard; // true = card iFrame, false = wallet redirect

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.isCard,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _pageLoading = true;
  bool _handled = false; // prevents double-handling a redirect

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8FAFC))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted:   (_) => setState(() => _pageLoading = true),
        onPageFinished:  (_) => setState(() => _pageLoading = false),
        onWebResourceError: (e) {
          if (e.isForMainFrame ?? true) _showError(e.description);
        },
        onNavigationRequest: _intercept,
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  // ── URL Interception ──────────────────────────────────────────────────────
  // Paymob redirects to its own domain with ?success=true/false&id=TXN_ID
  // We parse those query params and let the Cubit do the verification.

  NavigationDecision _intercept(NavigationRequest req) {
    if (_handled) return NavigationDecision.prevent;

    final uri = Uri.tryParse(req.url);
    if (uri == null) return NavigationDecision.navigate;

    final isCallback = req.url.contains('accept.paymob.com') &&
        (req.url.contains('success=') || req.url.contains('transaction_id='));

    if (!isCallback) return NavigationDecision.navigate;

    final params        = uri.queryParameters;
    final successParam  = params['success'];
    final transactionId = params['id'] ?? params['transaction_id'];
    final isError       = params['error_occured'] == 'true';

    if (successParam == null && transactionId == null) {
      _cancel();
      return NavigationDecision.prevent;
    }

    if (successParam == 'true' && transactionId != null) {
      _handled = true;
      context.read<PaymentCubit>().verifyPayment(transactionId);
      return NavigationDecision.prevent;
    }

    if (!isError && successParam == 'false' || isError) {
      final msg = params['data.message']
          ?? params['txn_response_code']
          ?? paymentDeclinedMessage;
      _fail(msg);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _fail(String msg) {
    if (_handled) return;
    _handled = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentFailedScreen(
          message: msg,
          onRetry: () {
            context.read<PaymentCubit>().reset();
            Navigator.popUntil(context, (r) => r.isFirst);
          },
        ),
      ),
    );
  }

  void _cancel() {
    if (_handled) return;
    _handled = true;
    context.read<PaymentCubit>().cancelPayment();
    Navigator.pop(context);
  }

  void _showError(String desc) {
    if (_handled) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Page error: $desc'),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (ctx, state) {
        if (state is PaymentSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(transaction: state.transaction),
            ),
            (r) => r.isFirst,
          );
        } else if (state is PaymentFailed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentFailedScreen(
                message: state.message,
                onRetry: () {
                  ctx.read<PaymentCubit>().reset();
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
              ),
            ),
          );
        }
      },
      child: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (ctx, state) {
          final verifying = state is PaymentVerifying;
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                widget.isCard ? 'Card Payment' : 'Wallet Payment',
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
                onPressed: () => _showCancelDialog(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: Color(0xFF64748B)),
                  onPressed: () => _controller.reload(),
                ),
              ],
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            body: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_pageLoading)
                  const LinearProgressIndicator(
                    color: Color(0xFF1A56DB),
                    backgroundColor: Color(0xFFEBF2FF),
                  ),
                if (verifying)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(stepVerifying,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(labelCancelPayment),
        content: const Text(labelCancelBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(labelContinuePaying)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancel();
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text(labelYesCancel),
          ),
        ],
      ),
    );
  }
}
