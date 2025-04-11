import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'delivery_home.dart';

class DeliveryRegistrationScreen extends StatefulWidget {
  const DeliveryRegistrationScreen({super.key});

  @override
  State<DeliveryRegistrationScreen> createState() =>
      _DeliveryRegistrationScreenState();
}

class _DeliveryRegistrationScreenState
    extends State<DeliveryRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _saveRepartidorData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado')),
        );
        return;
      }

      final repartidorData = {
        'nombre': _nameController.text.trim(),
        'zona': _zoneController.text.trim(),
        'telefono': user.phoneNumber,
        'disponible': true,
        'uid': user.uid, // para futuras referencias o actualizaciones
      };

      await _firestore
          .collection('repartidores')
          .doc(user.uid)
          .set(repartidorData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DeliveryHome(repartidorData: repartidorData),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPhone = _auth.currentUser?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Repartidor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _zoneController,
              decoration: const InputDecoration(labelText: 'Zona'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: userPhone,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRepartidorData,
              child: const Text('Guardar y Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
