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
    apiKey: 'AIzaSyAU-AACJK4KDjr5mYpTlFVNzR2o53ki6Qs',
    appId: '1:756489968417:android:f427c1916f48bff1f8fc60',
    messagingSenderId: '756489968417',
    projectId: 'drycleaning-52a74',
    authDomain: 'drycleaning-52a74.firebaseapp.com',
    storageBucket: 'drycleaning-52a74.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAU-AACJK4KDjr5mYpTlFVNzR2o53ki6Qs',
    appId: '1:756489968417:android:f427c1916f48bff1f8fc60',
    messagingSenderId: '756489968417',
    projectId: 'drycleaning-52a74',
    storageBucket: 'drycleaning-52a74.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAU-AACJK4KDjr5mYpTlFVNzR2o53ki6Qs',
    appId: '1:756489968417:android:f427c1916f48bff1f8fc60',
    messagingSenderId: '756489968417',
    projectId: 'drycleaning-52a74',
    storageBucket: 'drycleaning-52a74.firebasestorage.app',
    iosBundleId: 'com.example.drycleaningapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAU-AACJK4KDjr5mYpTlFVNzR2o53ki6Qs',
    appId: '1:756489968417:android:f427c1916f48bff1f8fc60',
    messagingSenderId: '756489968417',
    projectId: 'drycleaning-52a74',
    storageBucket: 'drycleaning-52a74.firebasestorage.app',
    iosBundleId: 'com.example.drycleaningapp',
  );
}
