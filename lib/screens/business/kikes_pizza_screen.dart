import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:domicilios_uno/screens/business/cart_provider.dart';

class KikesPizzaScreen extends StatefulWidget {
  const KikesPizzaScreen({super.key});

  @override
  State<KikesPizzaScreen> createState() => _KikesPizzaScreenState();
}

class _KikesPizzaScreenState extends State<KikesPizzaScreen> {
  final List<Map<String, dynamic>> productos = [
    {'nombre': 'Hamburguesa de la casa', 'precio': 15000},
    {'nombre': 'Chorizo', 'precio': 5000},
    {'nombre': 'Pizza personal', 'precio': 8000},
    {'nombre': 'Gaseosa 1.5L', 'precio': 7000},
  ];

  void agregarAlCarrito(Map<String, dynamic> producto) {
    // ✅ Ahora pasamos el nombre del negocio como argumento
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).addToCart(producto, "Kike's Pizza");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto['nombre']} agregado al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kike's Pizza"),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(producto['nombre']),
              subtitle: Text('\$${producto['precio']}'),
              trailing: ElevatedButton(
                onPressed: () => agregarAlCarrito(producto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Agregar'),
              ),
            ),
          );
        },
      ),
    );
  }
}
