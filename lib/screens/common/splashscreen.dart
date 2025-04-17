import 'package:domicilios_uno/screens/business/businesscard.dart';
import 'package:domicilios_uno/screens/delivery/delivery_home.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domicilios_uno/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playSound();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      checkUserRole(); // Nueva función para decidir a dónde va
    });
  }

  Future<void> checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final phoneNumber = user.phoneNumber;

      // Verificamos si ese teléfono está registrado como repartidor
      final repartidorSnapshot =
          await FirebaseFirestore.instance
              .collection('repartidores')
              .where('teléfono', isEqualTo: phoneNumber)
              .get();

      if (repartidorSnapshot.docs.isNotEmpty) {
        // ✅ Es repartidor
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const DeliveryHome(repartidorData: {}),
          ),
        );
      } else {
        // 👤 Es cliente
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BusinessCard()),
        );
      }
    } else {
      // 🔐 No autenticado
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Future<void> playSound() async {
    try {
      await audioPlayer.play(AssetSource('audio/sonido.mp3'));
    } catch (e) {
      debugPrint('Error reproduciendo sonido: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252526),
      body: Center(child: Image.asset('assets/images/logo.png', width: 200)),
    );
  }
}
