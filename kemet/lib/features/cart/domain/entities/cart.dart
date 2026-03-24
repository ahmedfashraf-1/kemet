class CartItem {
  final String cartItemId;   
  final String userId;      
  final String productId;    
  final int quantity;

  const CartItem({
    required this.cartItemId,
    required this.userId,
    required this.productId,
    required this.quantity,
  });
}