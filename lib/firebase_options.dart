// إعدادات مشروع Firebase (naql-564f1). مفاتيح تطبيقات Firebase ليست سرية؛
// حماية البيانات تتم بقواعد firestore.rules.
// لإضافة الويب شغّل: flutterfire configure --project=naql-564f1

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return android;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return ios;
    throw UnsupportedError('Firebase غير مُعدّ لهذه المنصة بعد: شغّل flutterfire configure');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8FWgsaIxGjT89cDNvJ84atfrl9SqOWpY',
    appId: '1:975237662849:android:44f92807526816c40ba580',
    messagingSenderId: '975237662849',
    projectId: 'naql-564f1',
    storageBucket: 'naql-564f1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZejlgaDnBIpWvnTf776ouTdrOqGptgtM',
    appId: '1:975237662849:ios:8282e538ac126c850ba580',
    messagingSenderId: '975237662849',
    projectId: 'naql-564f1',
    storageBucket: 'naql-564f1.firebasestorage.app',
    iosBundleId: 'naql.sa',
  );
}
