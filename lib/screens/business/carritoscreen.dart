import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:domicilios_uno/screens/business/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  Future<void> _confirmarPedido(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final carrito = cartProvider.cartItems;

    if (carrito.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El carrito está vacío')));
      return;
    }

    // 🟠 Mostrar advertencia tipo factura
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar pedido'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalle del pedido:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...carrito.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${item.quantity} x ${item.productName} (\$${item.price} c/u) = \$${item.quantity * item.price}',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total: \$${cartProvider.total}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirmar pedido'),
            ),
          ],
        );
      },
    );

    if (confirmacion != true) {
      return; // El usuario canceló la compra
    }

    // ✅ Guardar el pedido en Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró información del usuario')),
      );
      return;
    }

    final userData = userDoc.data()!;
    final pedido = {
      'uid': user.uid,
      'cliente': userData['name'],
      'telefono': user.phoneNumber,
      'direccion': userData['address'],
      'descripcion': userData['description'] ?? '',
      'total': cartProvider.total,
      'productos':
          carrito
              .map(
                (item) => {
                  'nombre': item.productName,
                  'cantidad': item.quantity,
                  'precio': item.price,
                  'restaurante': item.businessName,
                },
              )
              .toList(),
      'estado': 'pendiente de repartidor',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('pedidos').add(pedido);
      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar el pedido: $e')));
    }
  }

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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(producto.productName),
                        subtitle: Text(
                          'Cantidad: ${producto.quantity} - Restaurante: ${producto.businessName}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (producto.quantity > 1) {
                                  cartProvider.updateQuantity(
                                    producto,
                                    producto.quantity - 1,
                                  );
                                } else {
                                  cartProvider.removeItem(producto);
                                }
                              },
                            ),
                            Text(
                              '${producto.quantity}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider.updateQuantity(
                                  producto,
                                  producto.quantity + 1,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cartProvider.removeItem(producto);
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
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Row(
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
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _confirmarPedido(context),
                      icon: const Icon(Icons.send),
                      label: const Text('Confirmar Pedido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
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
