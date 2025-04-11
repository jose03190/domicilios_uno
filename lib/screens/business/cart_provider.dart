import 'package:flutter/material.dart';

class CartItem {
  final String productName;
  final int price;
  final int quantity;
  final String businessName;

  CartItem({
    required this.productName,
    required this.price,
    this.quantity = 1,
    required this.businessName,
  });
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get cartItems => _items;

  int get total => totalPrice;

  int get totalPrice =>
      _items.fold(0, (total, item) => total + (item.price * item.quantity));

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // ✅ Ahora recibe el nombre del restaurante como parámetro
  void addToCart(Map<String, dynamic> producto, String businessName) {
    final item = CartItem(
      productName: producto['nombre'],
      price: producto['precio'],
      quantity: 1,
      businessName: businessName,
    );
    _items.add(item);
    notifyListeners();
  }
}
