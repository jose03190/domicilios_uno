import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:domicilios_uno/screens/business/cart_provider.dart';

class ParrillaArtesanalScreen extends StatefulWidget {
  const ParrillaArtesanalScreen({super.key});

  @override
  State<ParrillaArtesanalScreen> createState() =>
      _ParrillaArtesanalScreenState();
}

class _ParrillaArtesanalScreenState extends State<ParrillaArtesanalScreen> {
  final List<Map<String, dynamic>> productos = [
    {'nombre': 'Hamburguesa tropical', 'precio': 16000},
    {'nombre': 'Hamburguesa mediterranea', 'precio': 20000},
    {'nombre': 'Salchipapa', 'precio': 14000},
    {'nombre': 'Picada mediana', 'precio': 45000},
  ];

  void agregarAlCarrito(Map<String, dynamic> producto) {
    // ✅ Ahora pasamos el nombre del negocio como argumento
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).addToCart(producto, 'Parrilla Artesanal');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto['nombre']} agregado al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parrilla Artesanal'),
        backgroundColor: Colors.green,
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
                  backgroundColor: Colors.green,
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
