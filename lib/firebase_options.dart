import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA1U5P-lalDAzYjTjpw6wS0TnYys3X8Nyo',
    appId: '1:260873511667:web:aefd8f1a4153048b62cd86',
    messagingSenderId: '260873511667',
    projectId: 'domidata-bbf33',
    authDomain: 'domidata-bbf33.firebaseapp.com',
    storageBucket: 'domidata-bbf33.firebasestorage.app',
    measurementId: 'G-KGQJBWEKMM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBcDBq9VOAkeVe9kAC0XYDM3UeLleuHJ8',
    appId: '1:260873511667:android:aec5c81707f9b3f462cd86',
    messagingSenderId: '260873511667',
    projectId: 'domidata-bbf33',
    storageBucket: 'domidata-bbf33.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCP3rF5xFJyFZwfdXkFw9q-m3SON9Otoeg',
    appId: '1:260873511667:ios:2c880e9b75cfddb662cd86',
    messagingSenderId: '260873511667',
    projectId: 'domidata-bbf33',
    storageBucket: 'domidata-bbf33.firebasestorage.app',
    iosBundleId: 'com.example.domiciliosUno',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCP3rF5xFJyFZwfdXkFw9q-m3SON9Otoeg',
    appId: '1:260873511667:ios:2c880e9b75cfddb662cd86',
    messagingSenderId: '260873511667',
    projectId: 'domidata-bbf33',
    storageBucket: 'domidata-bbf33.firebasestorage.app',
    iosBundleId: 'com.example.domiciliosUno',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA1U5P-lalDAzYjTjpw6wS0TnYys3X8Nyo',
    appId: '1:260873511667:web:e79c321f68e0d46762cd86',
    messagingSenderId: '260873511667',
    projectId: 'domidata-bbf33',
    authDomain: 'domidata-bbf33.firebaseapp.com',
    storageBucket: 'domidata-bbf33.firebasestorage.app',
    measurementId: 'G-S5CQHFXDDN',
  );
}
