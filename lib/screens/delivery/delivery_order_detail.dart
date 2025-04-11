import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryOrderDetail extends StatelessWidget {
  final String pedidoId;

  const DeliveryOrderDetail({super.key, required this.pedidoId});

  Future<void> aceptarPedido(BuildContext context) async {
    final repartidorId =
        '123456'; // Aquí más adelante usaremos el UID real del repartidor logueado

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .update({
            'estado': 'asignado',
            'repartidorId': repartidorId,
            'horaAsignacion': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido aceptado con éxito')),
      );

      Navigator.pop(context); // Volver a la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al aceptar el pedido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del pedido')),
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
          final cliente = pedido['cliente'] ?? 'Sin nombre';
          final direccion = pedido['direccion'] ?? 'Sin dirección';
          final total = pedido['total'] ?? 0;
          final productos = pedido['productos'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Aceptar pedido'),
                    onPressed: () => aceptarPedido(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
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
