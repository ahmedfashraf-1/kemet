import 'dart:math';

String generateMerchantOrderId() {
  final ts   = DateTime.now().millisecondsSinceEpoch;
  final rand = Random().nextInt(99999).toString().padLeft(5, '0');
  return 'ORD-$ts-$rand';
}