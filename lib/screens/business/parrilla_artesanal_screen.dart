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

  final Map<int, int> cantidades = {};

  void _agregarTodosAlCarrito(BuildContext context) {
    final seleccionados =
        productos.asMap().entries.where((entry) {
          final cantidad = cantidades[entry.key] ?? 0;
          return cantidad > 0;
        }).toList();

    if (seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has seleccionado productos')),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    for (var entry in seleccionados) {
      final index = entry.key;
      final producto = productos[index];
      final cantidad = cantidades[index] ?? 0;

      cartProvider.addToCart({
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'cantidad': cantidad,
      }, 'Parrilla Artesanal');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Productos agregados al carrito')),
    );

    setState(() {
      cantidades.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parrilla Artesanal',
          style: TextStyle(
            color: Colors.white, // 👉 Texto blanco
            fontWeight: FontWeight.w800, // 👉 Borde más grueso
            fontSize: 20, // 👉 Tamaño ajustado
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👉 Ícono (flecha) blanco
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                final cantidad = cantidades[index] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(producto['nombre']),
                    subtitle: Text('\$${producto['precio']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (cantidad > 0) {
                                cantidades[index] = cantidad - 1;
                              }
                            });
                          },
                        ),
                        Text('$cantidad', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              cantidades[index] = cantidad + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _agregarTodosAlCarrito(context),
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white, // 👉 Ícono blanco
              ),
              label: const Text(
                'Agregar al carrito',
                style: TextStyle(color: Colors.white), // 👉 Texto blanco
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
