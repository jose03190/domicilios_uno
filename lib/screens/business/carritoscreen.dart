import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:domicilios_uno/screens/business/cart_provider.dart'; // Asegúrate de tener bien la ruta

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final carrito = cartProvider.cartItems;

          if (carrito.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: carrito.length,
                  itemBuilder: (context, index) {
                    final producto = carrito[index];
                    return ListTile(
                      title: Text(producto.productName),
                      subtitle: Text(
                        'Cantidad: ${producto.quantity} - Restaurante: ${producto.businessName}',
                      ),
                      trailing: Text('\$${producto.price * producto.quantity}'),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${cartProvider.total}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
