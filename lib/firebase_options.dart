import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDFDWwX4DGhoxelZqQ3L-80AJQyl2t9ggw',
      appId: '1:437902386839:android:0003ecdfd3a5583c83ebd2',
      messagingSenderId: '437902386839',
      projectId: 'expisave',
      authDomain: 'expisave.firebaseapp.com',
      storageBucket: 'expisave.appspot.com',
    );
  }
}
