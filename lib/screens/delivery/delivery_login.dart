import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'delivery_home.dart';

class DeliveryLogin extends StatefulWidget {
  const DeliveryLogin({super.key});

  @override
  State<DeliveryLogin> createState() => _DeliveryLoginState();
}

class _DeliveryLoginState extends State<DeliveryLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController(
    text: "+573008523744",
  ); // Número fijo por defecto
  final TextEditingController _otpController = TextEditingController();

  String _verificationId = '';
  bool _codeSent = false;
  String? _errorMessage;

  Future<void> _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _checkIfRepartidor(_phoneController.text);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _errorMessage = e.message;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _signInWithOTP() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);
      _checkIfRepartidor(_phoneController.text);
    } catch (e) {
      setState(() {
        _errorMessage = "Error al verificar el código. Intenta de nuevo.";
      });
    }
  }

  Future<void> _checkIfRepartidor(String numero) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('repartidores')
            .where('teléfono', isEqualTo: numero)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DeliveryHome(repartidorData: data)),
      );
    } else {
      setState(() {
        _errorMessage = "Este número no está registrado como repartidor.";
      });
      _auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso Repartidor'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Número de teléfono',
              ),
              keyboardType: TextInputType.phone,
              enabled: !_codeSent, // deshabilita cuando se envía el código
            ),
            if (_codeSent)
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Código SMS'),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _codeSent ? _signInWithOTP : _verifyPhoneNumber,
              child: Text(_codeSent ? 'Verificar Código' : 'Enviar Código'),
            ),
          ],
        ),
      ),
    );
  }
}
