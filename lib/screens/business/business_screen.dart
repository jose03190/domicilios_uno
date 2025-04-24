import 'package:flutter/material.dart';
import 'package:domicilios_uno/screens/business/kikes_pizza_screen.dart';
import 'package:domicilios_uno/screens/business/parrilla_artesanal_screen.dart';

class BusinessScreen extends StatelessWidget {
  final String businessName;

  const BusinessScreen({super.key, required this.businessName});

  @override
  Widget build(BuildContext context) {
    Widget businessPage = Center(
      child: Text(
        'Aquí se mostrará el menú de $businessName con productos y precios.',
        style: const TextStyle(fontSize: 18, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );

    switch (businessName) {
      case 'Parrilla Artesanal':
        businessPage = const ParrillaArtesanalScreen();
        break;
      case 'Kike’s Pizza':
        businessPage = const KikesPizzaScreen();
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[850], // Fondo oscuro
      body: businessPage, // ❌ Ya no hay AppBar aquí
    );
  }
}
