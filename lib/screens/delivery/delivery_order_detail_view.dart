import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryOrderDetailView extends StatelessWidget {
  final String pedidoId;

  const DeliveryOrderDetailView({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('pedidos')
                .doc(pedidoId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('❌ Error al cargar el pedido'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedido = snapshot.data!;
          final cliente = pedido['cliente'] ?? 'Cliente';
          final direccion = pedido['direccion'] ?? 'Sin dirección';
          final descripcion = pedido['descripcion'] ?? '';
          final estado = pedido['estado'] ?? 'Sin estado';
          final total = pedido['total'] ?? 0;
          final telefono = pedido['telefono'] ?? 'Sin número';
          final productos = List<Map<String, dynamic>>.from(
            pedido['productos'] ?? [],
          );

          String fecha = 'Sin fecha';
          try {
            final timestamp = pedido['timestamp'] as Timestamp?;
            if (timestamp != null) {
              fecha = timestamp.toDate().toString().substring(0, 16);
            }
          } catch (_) {
            fecha = 'Sin fecha';
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Cliente: $cliente', style: const TextStyle(fontSize: 18)),
                Text('📍 Dirección: $direccion'),
                if (descripcion.isNotEmpty)
                  Text('📝 Descripción: $descripcion'),
                const SizedBox(height: 8),
                Text('📞 Teléfono: $telefono'),
                Text('📅 Fecha: $fecha'),
                const SizedBox(height: 12),
                Text(
                  'Estado: $estado',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Divider(height: 30),
                const Text(
                  'Productos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...productos.map((producto) {
                  final nombre = producto['nombre'] ?? 'Producto';
                  final cantidad = producto['cantidad'] ?? 1;
                  final restaurante = producto['restaurante'] ?? 'Restaurante';
                  return Text('- $nombre x$cantidad ($restaurante)');
                }),
                const Divider(height: 30),
                Text(
                  'Total: \$${total.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
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
