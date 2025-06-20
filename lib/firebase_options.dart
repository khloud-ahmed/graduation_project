import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDFDWwX4DGhoxelZqQ3L-80AJQyl2t9ggw',
        appId: '1:437902386839:web:9db4181296b4303383ebd2', // ✅ Web App ID الصحيح
        messagingSenderId: '437902386839',
        projectId: 'expisave',
        authDomain: 'expisave.firebaseapp.com',
        storageBucket: 'expisave.appspot.com',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDFDWwX4DGhoxelZqQ3L-80AJQyl2t9ggw',
          appId: '1:437902386839:android:0003ecdfd3a5583c83ebd2',
          messagingSenderId: '437902386839',
          projectId: 'expisave',
          storageBucket: 'expisave.appspot.com',
        );
      default:
        throw UnsupportedError(
          'FirebaseOptions are not configured for this platform.',
        );
    }
  }
}


