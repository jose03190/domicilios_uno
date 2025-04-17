import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'delivery_order_detail_view.dart';

class DeliveryHistory extends StatelessWidget {
  final String uid;

  const DeliveryHistory({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Scaffold(body: Center(child: Text('UID no disponible')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Entregas'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pedidos')
                .where('repartidorId', isEqualTo: uid)
                .where('estado', isEqualTo: 'entregado')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar historial.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!.docs;

          if (pedidos.isEmpty) {
            return const Center(
              child: Text('Aún no hay entregas completadas.'),
            );
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final cliente = pedido['cliente'] ?? 'Cliente';
              final direccion = pedido['direccion'] ?? 'Sin dirección';
              final total = pedido['total'] ?? 0;
              final fecha =
                  pedido['timestamp'] != null
                      ? DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format((pedido['timestamp'] as Timestamp).toDate())
                      : 'Sin fecha';

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Cliente: $cliente'),
                  subtitle: Text(
                    'Dirección: $direccion\nTotal: \$${total.toInt()}\nFecha: $fecha',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  DeliveryOrderDetailView(pedidoId: pedido.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
