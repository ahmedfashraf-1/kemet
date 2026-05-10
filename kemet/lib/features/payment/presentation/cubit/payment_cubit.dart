// features/payment/presentation/cubit/payment_cubit.dart
//
// Calls the 5 use cases in sequence and maps Failure → message
// using YOUR strings/failures.dart constants.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/utils/order_id_generator.dart';

import '../../../../core/constants/paymob_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/strings/failures.dart'; // YOUR string constants
import '../../domain/entities/payment_entities.dart';
import '../../domain/usecases/payment_usecases.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final AuthenticateUseCase     _authenticate;
  final RegisterOrderUseCase    _registerOrder;
  final GetPaymentKeyUseCase    _getPaymentKey;
  final PayWithWalletUseCase    _payWithWallet;
  final VerifyTransactionUseCase _verifyTransaction;

  PaymentCubit({
    required AuthenticateUseCase     authenticate,
    required RegisterOrderUseCase    registerOrder,
    required GetPaymentKeyUseCase    getPaymentKey,
    required PayWithWalletUseCase    payWithWallet,
    required VerifyTransactionUseCase verifyTransaction,
  })  : _authenticate     = authenticate,
        _registerOrder    = registerOrder,
        _getPaymentKey    = getPaymentKey,
        _payWithWallet    = payWithWallet,
        _verifyTransaction = verifyTransaction,
        super(const PaymentInitial());

  // ─────────────────────────────────────────────────────────────────────────
  // Card payment: authenticate → registerOrder → getPaymentKey → CardReady
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initiateCardPayment({
    required double amount,
    required BillingDataEntity billingData,
  }) async {
    final amountCents      = _toCents(amount);
    final merchantOrderId  = generateMerchantOrderId();

    // Step 1 — Auth
    emit(const PaymentAuthenticating());
    final authResult = await _authenticate();
    final authToken = authResult.fold(
      (f) { emit(PaymentError(message: _mapFailure(f))); return null; },
      (e) => e.token,
    );
    if (authToken == null || isClosed) return;

    // Step 2 — Register order
    emit(const PaymentRegisteringOrder());
    final orderResult = await _registerOrder(RegisterOrderParams(
      authToken: authToken,
      amountCents: amountCents,
      currency: PaymobConstants.currency,
      merchantOrderId: merchantOrderId,
    ));
    final orderId = orderResult.fold(
      (f) { emit(PaymentError(message: _mapFailure(f))); return null; },
      (e) => e.orderId,
    );
    if (orderId == null || isClosed) return;

    // Step 3 — Payment key (card integration)
    emit(const PaymentGettingKey());
    final keyResult = await _getPaymentKey(GetPaymentKeyParams(
      authToken: authToken,
      orderId: orderId,
      amountCents: amountCents,
      currency: PaymobConstants.currency,
      integrationId: PaymobConstants.cardIntegrationId,
      billingData: billingData,
    ));

    keyResult.fold(
      (f) => emit(PaymentError(message: _mapFailure(f))),
      (e) => emit(PaymentCardReady(
        iframeUrl: PaymobConstants.iframeUrl(e.paymentKey),
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Wallet payment: auth → registerOrder → getPaymentKey → payWithWallet → WalletReady
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initiateWalletPayment({
    required double amount,
    required BillingDataEntity billingData,
    required String walletPhone,
  }) async {
    final amountCents     = _toCents(amount);
    final merchantOrderId = generateMerchantOrderId();

    // Step 1 — Auth
    emit(const PaymentAuthenticating());
    final authResult = await _authenticate();
    final authToken = authResult.fold(
      (f) { emit(PaymentError(message: _mapFailure(f))); return null; },
      (e) => e.token,
    );
    if (authToken == null || isClosed) return;

    // Step 2 — Register order
    emit(const PaymentRegisteringOrder());
    final orderResult = await _registerOrder(RegisterOrderParams(
      authToken: authToken,
      amountCents: amountCents,
      currency: PaymobConstants.currency,
      merchantOrderId: merchantOrderId,
    ));
    final orderId = orderResult.fold(
      (f) { emit(PaymentError(message: _mapFailure(f))); return null; },
      (e) => e.orderId,
    );
    if (orderId == null || isClosed) return;

    // Step 3 — Payment key (wallet integration id)
    emit(const PaymentGettingKey());
    final keyResult = await _getPaymentKey(GetPaymentKeyParams(
      authToken: authToken,
      orderId: orderId,
      amountCents: amountCents,
      currency: PaymobConstants.currency,
      integrationId: PaymobConstants.walletIntegrationId, // ← wallet id
      billingData: billingData,
    ));
    final paymentKey = keyResult.fold(
      (f) { emit(PaymentError(message: _mapFailure(f))); return null; },
      (e) => e.paymentKey,
    );
    if (paymentKey == null || isClosed) return;

    // Step 4 — Wallet pay
    emit(const PaymentWalletLoading());
    final walletResult = await _payWithWallet(WalletPayParams(
      paymentKey: paymentKey,
      walletPhone: walletPhone,
    ));

    walletResult.fold(
      (f) => emit(PaymentError(message: _mapFailure(f))),
      (e) => emit(PaymentWalletReady(redirectUrl: e.redirectUrl)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Verify — called by WebView after it intercepts the Paymob callback URL
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> verifyPayment(String transactionId) async {
    emit(const PaymentVerifying());

    final result = await _verifyTransaction(transactionId);

    result.fold(
      (f) => emit(PaymentFailed(message: _mapFailure(f))),
      (tx) {
        if (tx.success) {
          emit(PaymentSuccess(transaction: tx));
        } else if (tx.isPending) {
          emit(const PaymentVerifying()); // caller should poll again
        } else {
          emit(PaymentFailed(
            message: tx.errorMessage ?? paymentDeclinedMessage,
          ));
        }
      },
    );
  }

  // ─── User closed the WebView ──────────────────────────────────────────────
  void cancelPayment() => emit(const PaymentCancelled());

  /// Reset between payment sessions.
  void reset() => emit(const PaymentInitial());

  // ─── Failure → user-readable string ──────────────────────────────────────
  // Maps YOUR failures to YOUR string constants from strings/failures.dart

  String _mapFailure(Failure f) {
    if (f is OfflineFailure)          return offlineFailureMessage;
    if (f is PaymobAuthFailure)       return f.message.isNotEmpty ? f.message : paymobAuthFailureMessage;
    if (f is PaymobTimeoutFailure)    return paymobTimeoutFailureMessage;
    if (f is PaymobServerFailure)     return f.message.isNotEmpty ? f.message : serverFailureMessage;
    if (f is PaymobParseFailure)      return paymobParseFailureMessage;
    if (f is PaymentDeclinedFailure)  return f.message;
    if (f is ServerFailure)           return serverFailureMessage;
    return unknownFailureMessage;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// EGP → piasters (Paymob always expects cents/piasters, not decimals)
  int _toCents(double amount) => (amount * 100).round();
}
