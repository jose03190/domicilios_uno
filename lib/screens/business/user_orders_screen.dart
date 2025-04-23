import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_order_detail_view.dart';

class UserOrdersScreen extends StatelessWidget {
  const UserOrdersScreen({super.key});

  Icon _getEstadoIcon(String estado) {
    switch (estado) {
      case 'pendiente de repartidor':
        return const Icon(Icons.access_time, color: Colors.orange);
      case 'preparando':
        return const Icon(Icons.local_dining, color: Colors.amber);
      case 'en ruta':
        return const Icon(Icons.delivery_dining, color: Colors.blue);
      case 'entregado':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'cancelado':
        return const Icon(Icons.cancel, color: Colors.redAccent);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  String _estadoMensaje(String estado) {
    switch (estado) {
      case 'pendiente de repartidor':
        return 'Esperando asignación del repartidor';
      case 'preparando':
        return 'Tu pedido se está preparando';
      case 'en ruta':
        return 'Tu pedido viene en camino';
      case 'entregado':
        return 'Pedido entregado con éxito';
      case 'cancelado':
        return 'Pedido cancelado por el usuario';
      default:
        return 'Estado desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    final uid = user.uid;
    print('🧩 UID autenticado: $uid');

    // 🔍 Verificar qué UID tienen los pedidos guardados
    FirebaseFirestore.instance.collection('pedidos').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        print('📦 Pedido: ${doc.id} | UID almacenado: ${doc['uid']}');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pedidos')
                .where('uid', isEqualTo: uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('❌ Error al cargar los pedidos.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!.docs;

          if (pedidos.isEmpty) {
            return const Center(child: Text('No tienes pedidos registrados.'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];

              final estado = pedido['estado'] ?? 'pendiente de repartidor';
              final total = pedido['total'] ?? 0;
              final direccion = pedido['direccion'] ?? 'Sin dirección';

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  leading: _getEstadoIcon(estado),
                  title: Text(
                    _estadoMensaje(estado),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dirección: $direccion\nTotal: \$${total.toInt()}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => UserOrderDetailView(pedidoId: pedido.id),
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
