import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'delivery_order_detail.dart';

class DeliveryOrderList extends StatelessWidget {
  const DeliveryOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos disponibles'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pedidos')
                .where('estado', isEqualTo: 'pendiente de repartidor')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar pedidos'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!.docs;

          if (pedidos.isEmpty) {
            return const Center(child: Text('No hay pedidos pendientes.'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final cliente = pedido['cliente'] ?? 'Sin nombre';
              final direccion = pedido['direccion'] ?? 'Sin dirección';
              final total = pedido['total'] ?? 0;

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  title: Text('Cliente: $cliente'),
                  subtitle: Text(
                    'Dirección: $direccion\nTotal: \$${total.toInt()}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => DeliveryOrderDetail(pedidoId: pedido.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Ver'),
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
