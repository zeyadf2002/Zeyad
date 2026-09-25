# إعداد Firebase للتطبيق

التطبيق يعمل الآن في **وضع التجربة** (بيانات في الذاكرة) إلى أن تُكمل الخطوات التالية مرة واحدة. بعدها يطلب تسجيل الدخول برقم الجوال، وتُحفظ الطلبات والعروض في قاعدة البيانات.

## ١. إنشاء مشروع Firebase (من المتصفح)
1. افتح https://console.firebase.google.com وسجّل بحساب Google
2. اضغط **Create a project** وسمّه `naql`
3. من القائمة: **Build ← Authentication ← Get started ← Phone** وفعّله
4. من القائمة: **Build ← Firestore Database ← Create database**، اختر أقرب منطقة (مثل `me-central2` الدمام) وابدأ بـ **production mode**

## ٢. ربط التطبيق بالمشروع (من جهاز فيه Flutter)
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=naql
```
الأمر الأخير يستبدل الملف `lib/firebase_options.dart` بإعدادات مشروعك.

## ٣. نشر قواعد الحماية
```bash
firebase deploy --only firestore:rules
```
القواعد في `firestore.rules`: العميل يرى عروضه فقط، والشركة ترى عروضها فقط، ولا أحد يعدّل طلب غيره.

## ٤. توثيق شركات النقل
صاحب الشركة يسجّل دخوله، ثم من **حسابي ← التحويل إلى وضع الشركة** يملأ نموذج تسجيل الشركة. تُحفظ الشركة في مجموعة `companies` وحقل `verified` فيها `false`، فلا تظهر للعملاء.

للتوثيق: افتح **Firestore Database ← companies**، اختر مستند الشركة، وغيّر `verified` إلى `true`. بعدها تظهر للعملاء ويفتح لصاحبها وضع الشركة.

## ٥. للتجربة بدون رسائل SMS حقيقية
في **Authentication ← Sign-in method ← Phone ← Phone numbers for testing** أضف رقمًا مثل `+966500000000` مع رمز `123456`.
