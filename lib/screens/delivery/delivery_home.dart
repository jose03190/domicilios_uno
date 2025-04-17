import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'delivery_order_list.dart';
import 'delivery_assigned_orders.dart';
import 'delivery_history.dart';

class DeliveryHome extends StatefulWidget {
  final Map<String, dynamic> repartidorData;

  const DeliveryHome({super.key, required this.repartidorData});

  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  late String nombre;
  late String telefono;
  late String zona;
  late bool disponible;
  late String uid;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    nombre = widget.repartidorData['nombre'] ?? 'Sin nombre';
    telefono = widget.repartidorData['telefono'] ?? 'Sin teléfono';
    zona = widget.repartidorData['zona'] ?? 'Sin zona';
    disponible = widget.repartidorData['disponible'] ?? false;
    uid = widget.repartidorData['uid'] ?? '';
  }

  void _toggleDisponibilidad() async {
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UID inválido para actualizar')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('repartidores')
          .doc(uid)
          .update({'disponible': !disponible});

      setState(() {
        disponible = !disponible;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            disponible
                ? 'Marcado como disponible'
                : 'Marcado como NO disponible',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
    }
  }

  List<Widget> get _screens => [
    _buildPerfil(),
    const DeliveryOrderList(),
    DeliveryAssignedOrders(uid: uid),
    DeliveryHistory(uid: uid),
  ];

  Widget _buildPerfil() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre: $nombre', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text('Teléfono: $telefono', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Zona: $zona', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Disponible: ', style: TextStyle(fontSize: 18)),
              Icon(
                disponible ? Icons.check_circle : Icons.cancel,
                color: disponible ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.sync),
            label: Text(
              disponible
                  ? 'Marcar como NO disponible'
                  : 'Marcar como disponible',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
            ),
            onPressed: _toggleDisponibilidad,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repartidor'),
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Pedidos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Mis pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}
