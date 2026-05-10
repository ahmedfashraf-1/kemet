import 'package:kemet/features/payment/domain/entities/payment_entities.dart';
import 'package:kemet/features/store/domain/entities/cart.dart';
import '../entities/order.dart';

/// Converts Cart items to Order items for checkout
class CartToOrderConverter {
  /// Convert CartItem list to OrderItem list
  static List<OrderItem> convertItems(List<CartItem> cartItems) {
    return cartItems.map((item) {
      return OrderItem(
        productId: item.product.productId,
        quantity: item.quantity,
        price: item.product.price,
      );
    }).toList();
  }

  /// Convert billing data entity to JSON string
  static String billingDataToJson(BillingDataEntity billingData) {
    return '''{
      "firstName": "${billingData.firstName}",
      "lastName": "${billingData.lastName}",
      "email": "${billingData.email}",
      "phone": "${billingData.phone}",
      "apartment": "${billingData.apartment}",
      "floor": "${billingData.floor}",
      "street": "${billingData.street}",
      "building": "${billingData.building}",
      "shippingMethod": "${billingData.shippingMethod}",
      "postalCode": "${billingData.postalCode}",
      "city": "${billingData.city}",
      "country": "${billingData.country}",
      "state": "${billingData.state}"
    }''';
  }
}
