import 'package:get/get.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartController extends GetxController {
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  
  List<CartItem> get cartItems => _cartItems;
  
  int get itemCount => _cartItems.length;
  
  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) {
      // Use calculated total, then fall back to total, then calculate from price and quantity
      final itemTotal = item.calculatedTotal ?? 
                       item.total ?? 
                       ((item.price ?? 0.0) * (item.quantity ?? 1));
      return sum + itemTotal;
    });
  }
  
  void addToCart(Product product, String size, int quantity) {
    // Check if item already exists in cart
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id && item.size == size,
    );
    
    if (existingItemIndex >= 0) {
      // Update quantity of existing item
      final currentQuantity = _cartItems[existingItemIndex].quantity ?? 0;
      final newQuantity = currentQuantity + quantity;
      // Correctly calculate the total price
      final totalPrice = (product.price ?? 0.0) * newQuantity;
      final updatedItem = _cartItems[existingItemIndex].copyWith(
        quantity: newQuantity,
        total: totalPrice
      );
      _cartItems[existingItemIndex] = updatedItem;
      _cartItems.refresh();
    } else {
      // Add new item to cart with calculated total
      final price = product.price ?? 0.0;
      final total = price * quantity;
      final cartItem = CartItem(
        productId: product.id,
        size: size,
        quantity: quantity,
        price: price,
        total: total,  // Set total price based on price * quantity
        productName: product.name,
        productImage: product.images?.first,
      );
      _cartItems.add(cartItem);
    }
    
    update();
  }
  
  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      update();
    }
  }
  
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        removeFromCart(index);
      } else {
        final updatedItem = _cartItems[index].copyWith(quantity: newQuantity);
        _cartItems[index] = updatedItem;
        _cartItems.refresh();
        update();
      }
    }
  }
  
  void clearCart() {
    _cartItems.clear();
    update();
  }
  
  bool isInCart(String productId, String size) {
    return _cartItems.any(
      (item) => item.productId == productId && item.size == size,
    );
  }
  
  int getQuantityInCart(String productId, String size) {
    final item = _cartItems.firstWhereOrNull(
      (item) => item.productId == productId && item.size == size,
    );
    return item?.quantity ?? 0;
  }
}
