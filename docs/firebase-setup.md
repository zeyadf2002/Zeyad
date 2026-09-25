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

## ٤. إضافة شركة نقل
الشركات لا تسجّل نفسها بعد؛ تُضاف يدويًا من لوحة Firestore:
- المجموعة: `companies`، ومستند جديد بالحقول:

| الحقل | النوع | مثال |
|---|---|---|
| name | string | الناقل السريع |
| carrier | string | `enclosed` أو `open` أو `flatbed` |
| cities | array | الرياض، جدة |
| rating | number | 0 |
| reviewCount | number | 0 |
| verified | boolean | true |
| ownerUid | string | معرّف حساب صاحب الشركة من **Authentication ← Users** |

صاحب الشركة يسجّل دخوله برقمه أولًا، ثم تنسخ الـ UID الخاص به من صفحة Users وتضعه في `ownerUid`. بعدها يفتح له "وضع الشركة".

## ٥. للتجربة بدون رسائل SMS حقيقية
في **Authentication ← Sign-in method ← Phone ← Phone numbers for testing** أضف رقمًا مثل `+966500000000` مع رمز `123456`.
