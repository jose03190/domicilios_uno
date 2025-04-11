import 'package:flutter/material.dart';
import 'package:domicilios_uno/screens/business/business_screen.dart';

class BusinessCardHome extends StatelessWidget {
  const BusinessCardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> businesses = [
      'Parrilla Artesanal',
      'Kike’s Pizza',
      'Sandra Comidas Rapidas',
      'Hierros Palestina',
      'Mirador de la Colina',
      'Estanquillo viña del sol',
      'Servicios Personalizados',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Negocios Aliados'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: businesses.length,
          itemBuilder: (context, index) {
            return _BusinessCardItem(
              key: ValueKey(businesses[index]),
              businessName: businesses[index],
            );
          },
        ),
      ),
    );
  }
}

class _BusinessCardItem extends StatelessWidget {
  final String businessName;
  const _BusinessCardItem({super.key, required this.businessName});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              businessName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => BusinessScreen(businessName: businessName),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ver menú'),
            ),
          ],
        ),
      ),
    );
  }
}
