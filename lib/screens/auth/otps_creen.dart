import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'userregistrationscreen.dart';
import '../delivery/delivery_home.dart';
import '../delivery/delivery_registration.dart';
import '../business/businesscard.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  const OTPScreen({super.key, required this.verificationId});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  void _verifyCode() async {
    setState(() => _isLoading = true);
    String smsCode = _otpController.text.trim();

    if (smsCode.isEmpty || smsCode.length < 6) {
      Fluttertoast.showToast(msg: "Ingrese un código válido de 6 dígitos");
      setState(() => _isLoading = false);
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        final phone = user.phoneNumber;
        final uid = user.uid;

        // Verificar si es repartidor
        final repartidorDoc =
            await _firestore
                .collection('repartidores')
                .where('telefono', isEqualTo: phone)
                .limit(1)
                .get();

        if (repartidorDoc.docs.isNotEmpty) {
          final doc = repartidorDoc.docs.first;
          final data = doc.data();

          if (data['uid'] == null || data['uid'].toString().isEmpty) {
            await doc.reference.update({'uid': uid});
            data['uid'] = uid;
          }

          if (data.containsKey('nombre') &&
              data.containsKey('zona') &&
              data['nombre'] != null &&
              data['zona'] != null &&
              data['nombre'].toString().isNotEmpty &&
              data['zona'].toString().isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DeliveryHome(repartidorData: data),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const DeliveryRegistrationScreen(),
              ),
            );
          }
          return;
        }

        // Si no es repartidor, buscar si ya existe en la colección users
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BusinessCard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserRegistrationScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Código incorrecto, intenta de nuevo";
      if (e.code == 'invalid-verification-code') {
        errorMessage =
            "Código inválido, revisa el mensaje y vuelve a intentarlo";
      }
      Fluttertoast.showToast(msg: errorMessage);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verificación OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Ingrese el código',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _verifyCode(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _verifyCode,
                  child: const Text('Verificar'),
                ),
          ],
        ),
      ),
    );
  }
}
