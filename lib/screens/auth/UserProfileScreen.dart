import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No se encontraron datos del usuario.'),
            );
          }

          final userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Nombre'),
                  subtitle: Text(userData['name'] ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Teléfono'),
                  subtitle: Text(userData['phone'] ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('Barrio'),
                  subtitle: Text(userData['neighborhood'] ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Dirección'),
                  subtitle: Text(userData['address'] ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Descripción'),
                  subtitle: Text(userData['description'] ?? 'No especificada'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
