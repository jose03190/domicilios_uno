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
      }, "Kike's Pizza");
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
          "Kike's Pizza",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800, // 👈 Borde más grueso
            fontSize: 20, // 👈 Puedes ajustar el tamaño si quieres
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 Ícono de retroceso blanco
        ),
        backgroundColor: Colors.redAccent,
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
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: const Text(
                'Agregar al carrito',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
