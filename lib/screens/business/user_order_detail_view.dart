import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserOrderDetailView extends StatelessWidget {
  final String pedidoId;

  const UserOrderDetailView({super.key, required this.pedidoId});

  Future<void> _cancelarPedido(BuildContext context) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cancelar pedido'),
            content: const Text(
              '¿Estás seguro de que deseas cancelar este pedido?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );

    if (confirmacion != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .update({'estado': 'cancelado'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar el pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del pedido'),
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
            return const Center(child: Text('Error al cargar el pedido'));
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
          final productos = pedido['productos'] as List<dynamic>? ?? [];

          String fecha = 'Sin fecha';
          try {
            final timestamp = pedido['timestamp'] as Timestamp?;
            if (timestamp != null) {
              fecha = timestamp.toDate().toString().substring(0, 16);
            }
          } catch (_) {
            fecha = 'Sin fecha';
          }

          final telefonoRepartidor = pedido['telefonoRepartidor'] ?? '';
          final nombreRepartidor =
              pedido['nombreRepartidor'] ?? 'No registrado';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Cliente: $cliente', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text('Dirección: $direccion'),
                if (descripcion.isNotEmpty) Text('Referencia: $descripcion'),
                Text('Fecha: $fecha'),
                const SizedBox(height: 10),
                if (estado != 'pendiente de repartidor') ...[
                  Text('📦 Repartidor: $nombreRepartidor'),
                  Text('📞 Teléfono: $telefonoRepartidor'),
                ],
                const SizedBox(height: 16),
                Text(
                  'Estado: $estado',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Productos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                if (estado == 'pendiente de repartidor')
                  ElevatedButton.icon(
                    onPressed: () => _cancelarPedido(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar Pedido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
