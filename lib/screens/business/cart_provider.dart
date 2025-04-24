import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productName;
  final int price;
  int quantity;
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
  int _pendingOrders = 0; // 🟢 Nuevo campo para los pedidos pendientes

  List<CartItem> get cartItems => _items;
  int get totalPrice =>
      _items.fold(0, (total, item) => total + (item.price * item.quantity));
  int get total => totalPrice;
  int get totalItems => _items.fold(0, (total, item) => total + item.quantity);

  int get pendingOrders => _pendingOrders; // 🟢 Getter de pedidos pendientes

  CartProvider() {
    _listenToPendingOrders(); // 🟢 Activamos el listener al crear el Provider
  }

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void addToCart(Map<String, dynamic> producto, String businessName) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.productName == producto['nombre'] &&
          item.businessName == businessName,
    );

    int cantidad =
        producto['cantidad'] is int
            ? producto['cantidad']
            : (producto['cantidad'] as num).toInt();

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += cantidad;
    } else {
      _items.add(
        CartItem(
          productName: producto['nombre'],
          price:
              producto['precio'] is int
                  ? producto['precio']
                  : (producto['precio'] as num).toInt(),
          quantity: cantidad,
          businessName: businessName,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    final index = _items.indexOf(item);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // 🟢 FUNCIONALIDAD NUEVA: Escuchar los pedidos pendientes desde Firestore
  void _listenToPendingOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('pedidos')
          .where('uid', isEqualTo: user.uid)
          .where(
            'estado',
            whereIn: ['pendiente de repartidor', 'preparando', 'en ruta'],
          )
          .snapshots()
          .listen((snapshot) {
            _pendingOrders = snapshot.docs.length;
            notifyListeners();
          });
    }
  }
}
