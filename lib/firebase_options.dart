// PLACEHOLDER — regenerate this file by running `flutterfire configure`
// from the project root, after creating a Firebase project and running
// `flutterfire configure` (see the Firebase setup steps). The FlutterFire
// CLI overwrites this entire file with your project's real values; it must
// exist with this shape beforehand only so the app compiles until then.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this '
          'platform. Run `flutterfire configure` to generate them.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBebdNwcTIYPJ9b288C7ztn6bjZwe_yag8',
    appId: '1:329351564706:web:c8f6216f0af1f8bb1776fb',
    messagingSenderId: '329351564706',
    projectId: 'taakrak-d9ed0',
    authDomain: 'taakrak-d9ed0.firebaseapp.com',
    storageBucket: 'taakrak-d9ed0.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDc7-SdIyCg_-IXC6N41ADPXfmbmF6d-g8',
    appId: '1:329351564706:android:65cf6f85c08df2c81776fb',
    messagingSenderId: '329351564706',
    projectId: 'taakrak-d9ed0',
    storageBucket: 'taakrak-d9ed0.firebasestorage.app',
  );
}
