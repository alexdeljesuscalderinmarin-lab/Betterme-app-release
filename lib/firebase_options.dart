// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web no está configurado aún. Usa la app en Android.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCM79sMDjD5gb2tKYcm2EsXmFtGnTBGsXA', 
    appId: '1:713175508078:android:667c5dc51326270d66727f',
    messagingSenderId: '713175508078',
    projectId: 'better-me-app-164d5',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: ' ',
    appId: ' ',
    messagingSenderId: ' ',
    projectId: ' ',
  );
}