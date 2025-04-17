import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveryOrderDetail extends StatefulWidget {
  final String pedidoId;

  const DeliveryOrderDetail({super.key, required this.pedidoId});

  @override
  State<DeliveryOrderDetail> createState() => _DeliveryOrderDetailState();
}

class _DeliveryOrderDetailState extends State<DeliveryOrderDetail> {
  bool _loading = false;

  Future<void> _actualizarEstado(String nuevoEstado) async {
    final repartidor = FirebaseAuth.instance.currentUser;

    if (repartidor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repartidor no autenticado')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(widget.pedidoId)
          .update({
            'estado': nuevoEstado,
            'repartidorId': repartidor.uid,
            'telefonoRepartidor': repartidor.phoneNumber,
            'horaAsignacion': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a: $nuevoEstado')),
      );

      if (nuevoEstado == 'entregado') {
        Navigator.pop(context); // Volver cuando se termine todo
      } else {
        setState(() {}); // Recargar vista si sigue el flujo
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del pedido')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('pedidos')
                .doc(widget.pedidoId)
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
          final estado = pedido['estado'] ?? 'pendiente de repartidor';
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
                ...productos.map(
                  (p) => Text('- ${p['nombre']} x${p['cantidad']}'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: \$${total.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  if (estado == 'pendiente de repartidor')
                    _botonEstado('preparando', 'Aceptar pedido'),
                  if (estado == 'preparando')
                    _botonEstado('en ruta', 'Marcar como en ruta'),
                  if (estado == 'en ruta')
                    _botonEstado('entregado', 'Marcar como entregado'),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _botonEstado(String nuevoEstado, String textoBoton) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check),
        label: Text(textoBoton),
        onPressed: () => _actualizarEstado(nuevoEstado),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
