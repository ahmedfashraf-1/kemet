const String serverFailureMessage = 'A server error occurred. Please try again later.';
const String offlineFailureMessage = 'No internet connection. Showing cached Data.';
const String emptyCacheFailureMessage = 'No Data available. Please connect to the internet.';
const String unknownFailureMessage = 'An unexpected error occurred.';

// Error messages
const String paymobAuthFailureMessage =
    'Payment authentication failed. Please try again.';
const String paymobTimeoutFailureMessage =
    'Payment request timed out. Check your connection and retry.';
const String paymobParseFailureMessage =
    'Could not process payment response. Please contact support.';
const String paymentCancelledMessage =
    'Payment was cancelled.';
const String paymentDeclinedMessage =
    'Payment was declined. Please check your details and try again.';

// Loading step messages (shown in the overlay while API calls are in flight)
const String stepAuthenticating = 'Authenticating…';
const String stepCreatingOrder  = 'Creating order…';
const String stepPreparingKey   = 'Preparing payment…';
const String stepInitWallet     = 'Initiating wallet payment…';
const String stepVerifying      = 'Verifying payment…';
const String stepProcessing     = 'Processing payment…';

// UI labels
const String labelChoosePayment   = 'Choose Payment Method';
const String labelPayByCard       = 'Credit / Debit Card';
const String labelPayByCardSub    = 'Visa, Mastercard, Meeza';
const String labelPayByWallet     = 'Mobile Wallet';
const String labelPayByWalletSub  = 'Vodafone Cash, Orange Money, Etisalat Cash';
const String labelPaymentSuccess  = 'Payment Successful!';
const String labelPaymentFailed   = 'Payment Failed';
const String labelTryAgain        = 'Try Again';
const String labelBackToHome      = 'Back to Home';
const String labelSecuredByPaymob = 'Secured by Paymob · 256-bit SSL';
const String labelTransactionId   = 'Transaction ID';
const String labelOrderAmount     = 'Amount';
const String labelStatus          = 'Status';
const String labelPaid            = 'Paid';
const String labelEnterWallet     = 'Enter your wallet number';
const String labelWalletHint      = '010xxxxxxxx';
const String labelCancelPayment   = 'Cancel Payment?';
const String labelCancelBody      =
    'Are you sure? Your payment has not been processed.';
const String labelContinuePaying  = 'Continue Paying';
const String labelYesCancel       = 'Yes, Cancel';
