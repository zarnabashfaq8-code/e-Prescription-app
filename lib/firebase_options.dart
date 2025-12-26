import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyBNIuyUMbJyMPSdKGrqHzkWZVn0ashhJEo",
      appId: "1:1032363984066:android:0cd7545c70112dc14d275b",
      messagingSenderId: "1032363984066",
      projectId: "e-prescription-app-54a9a",
      storageBucket: "e-prescription-app-54a9a.appspot.com",
      authDomain: "e-prescription-app-54a9a.firebaseapp.com",
      measurementId: "G-XXXXXXXXXX", // optional
    );
  }
}
