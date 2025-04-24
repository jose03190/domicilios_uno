import 'package:domicilios_uno/screens/auth/UserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:domicilios_uno/screens/business/businesscardhome.dart';
import 'package:domicilios_uno/screens/business/carritoscreen.dart';
import 'package:domicilios_uno/screens/business/user_orders_screen.dart';
import 'package:provider/provider.dart';
import 'package:domicilios_uno/screens/business/cart_provider.dart';

class BusinessCard extends StatefulWidget {
  const BusinessCard({super.key});

  @override
  _BusinessCardState createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const UserProfileScreen(), // 0 - Perfil
    const BusinessCardHome(), // 1 - Inicio (Negocios)
    const CarritoScreen(), // 2 - Carrito
    const UserOrdersScreen(), // 3 - Mis pedidos
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartProvider.totalItems > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cartProvider.totalItems}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.receipt),
                if (cartProvider.pendingOrders > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cartProvider.pendingOrders}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Pedidos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
