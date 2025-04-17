import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveryAssignedOrders extends StatelessWidget {
  final String uid;

  const DeliveryAssignedOrders({super.key, required this.uid});

  Icon _getEstadoIcon(String estado) {
    switch (estado) {
      case 'preparando':
        return const Icon(Icons.local_dining, color: Colors.orange);
      case 'en ruta':
        return const Icon(Icons.delivery_dining, color: Colors.blue);
      case 'entregado':
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'preparando':
        return 'Preparando pedido';
      case 'en ruta':
        return 'Pedido en ruta';
      case 'entregado':
        return 'Pedido entregado';
      default:
        return 'Estado desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Scaffold(body: Center(child: Text('UID no disponible')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pedidos en proceso'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pedidos')
                .where('repartidorId', isEqualTo: uid)
                .where('estado', whereIn: ['preparando', 'en ruta'])
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los pedidos.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data?.docs ?? [];

          if (pedidos.isEmpty) {
            return const Center(
              child: Text('No tienes pedidos activos actualmente.'),
            );
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final cliente = pedido['cliente'] ?? 'Cliente';
              final direccion = pedido['direccion'] ?? 'Sin dirección';
              final total = pedido['total'] ?? 0;
              final estado = pedido['estado'] ?? 'preparando';

              String siguienteEstado = '';
              String textoBoton = '';

              if (estado == 'preparando') {
                siguienteEstado = 'en ruta';
                textoBoton = 'Marcar como en ruta';
              } else if (estado == 'en ruta') {
                siguienteEstado = 'entregado';
                textoBoton = 'Marcar como entregado';
              }

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  leading: _getEstadoIcon(estado),
                  title: Text(
                    _getEstadoTexto(estado),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Cliente: $cliente\nDirección: $direccion\nTotal: \$${total.toInt()}',
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('pedidos')
                            .doc(pedido.id)
                            .update({'estado': siguienteEstado});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pedido actualizado a: $siguienteEstado',
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar estado: $e'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(textoBoton),
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
