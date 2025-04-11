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
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 4));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('🔴 Usuario no autenticado. Redirigiendo al login.');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final userPhone = user.phoneNumber;
    debugPrint('📞 Teléfono autenticado: $userPhone');

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('repartidores')
              .where('telefono', isEqualTo: userPhone)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final repartidorData = snapshot.docs.first.data();
        debugPrint('✅ Repartidor encontrado. Entrando a DeliveryHome');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DeliveryHome(repartidorData: repartidorData),
          ),
        );
        return;
      } else {
        debugPrint('👤 No es repartidor. Entrando a BusinessCard.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BusinessCard()),
        );
      }
    } catch (e) {
      debugPrint('🔥 Error al consultar Firestore: $e');
      // Por seguridad, redirigimos al login
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
