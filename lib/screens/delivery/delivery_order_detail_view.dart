import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryOrderDetailView extends StatelessWidget {
  final String pedidoId;

  const DeliveryOrderDetailView({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Pedido')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('pedidos')
                .doc(pedidoId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el pedido'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedido = snapshot.data!;
          final cliente = pedido['cliente'] ?? 'Cliente';
          final direccion = pedido['direccion'] ?? 'Sin dirección';
          final total = pedido['total'] ?? 0;
          final productos = List<Map<String, dynamic>>.from(
            pedido['productos'] ?? [],
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Cliente: $cliente', style: const TextStyle(fontSize: 18)),
                Text('Dirección: $direccion'),
                const SizedBox(height: 16),
                const Text(
                  'Productos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...productos.map((producto) {
                  final nombre = producto['nombre'] ?? 'Producto';
                  final cantidad = producto['cantidad'] ?? 1;
                  return Text('- $nombre x$cantidad');
                }),
                const SizedBox(height: 16),
                Text(
                  'Total: \$${total.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
