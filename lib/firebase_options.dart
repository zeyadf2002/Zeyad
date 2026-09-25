// هذا الملف مؤقت. يُستبدل تلقائيًا عند تشغيل:
//   flutterfire configure
// (راجع docs/firebase-setup.md). ما دام مؤقتًا يعمل التطبيق في وضع التجربة.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      throw UnsupportedError('Firebase غير مُعدّ بعد: شغّل flutterfire configure');
}
