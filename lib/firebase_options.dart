import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAoR-d5zsxHh_mk9ZlvA6vnsVOQPlVewe8',
    appId: '1:1024603054765:web:f4638108dd897c99691c24',
    messagingSenderId: '1024603054765',
    projectId: 'authentication-e3bf4',
    authDomain: 'authentication-e3bf4.firebaseapp.com',
    storageBucket: 'authentication-e3bf4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAoR-d5zsxHh_mk9ZlvA6vnsVOQPlVewe8',
    appId: '1:1024603054765:android:f4638108dd897c99691c24',
    messagingSenderId: '1024603054765',
    projectId: 'authentication-e3bf4',
    storageBucket: 'authentication-e3bf4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAoR-d5zsxHh_mk9ZlvA6vnsVOQPlVewe8',
    appId: '1:1024603054765:ios:f4638108dd897c99691c24',
    messagingSenderId: '1024603054765',
    projectId: 'authentication-e3bf4',
    storageBucket: 'authentication-e3bf4.firebasestorage.app',
    iosBundleId: 'com.example.drycleaning_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAoR-d5zsxHh_mk9ZlvA6vnsVOQPlVewe8',
    appId: '1:1024603054765:ios:f4638108dd897c99691c24',
    messagingSenderId: '1024603054765',
    projectId: 'authentication-e3bf4',
    storageBucket: 'authentication-e3bf4.firebasestorage.app',
    iosBundleId: 'com.example.drycleaning_app',
  );
}
