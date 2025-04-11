import 'package:domicilios_uno/screens/auth/UserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:domicilios_uno/screens/business/businesscardhome.dart';
import 'package:domicilios_uno/screens/business/carritoscreen.dart';

class BusinessCard extends StatefulWidget {
  const BusinessCard({super.key});

  @override
  _BusinessCardState createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const UserProfileScreen(), // Perfil
    const BusinessCardHome(), // Inicio (Negocios)
    const CarritoScreen(), // Carrito
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
