import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// يحوّل 05xxxxxxxx أو 5xxxxxxxx إلى +9665xxxxxxxx.
String? normalizeSaudiPhone(String input) {
  var digits = input.replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x0660}');
  digits = digits.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('+966')) digits = digits.substring(4);
  if (digits.startsWith('00966')) digits = digits.substring(5);
  if (digits.startsWith('966')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (!RegExp(r'^5\d{8}$').hasMatch(digits)) return null;
  return '+966$digits';
}

/// تسجيل الدخول برقم الجوال عبر رمز تحقق (OTP).
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  late final FirebaseAuth _auth = widget.auth ?? FirebaseAuth.instance;
  final _phone = TextEditingController();
  final _code = TextEditingController();
  String? _verificationId;
  ConfirmationResult? _webConfirmation;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = normalizeSaudiPhone(_phone.text);
    if (phone == null) {
      setState(() => _error = 'اكتب رقم جوال سعودي صحيح، مثل 05xxxxxxxx');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS) {
        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (credential) => _auth.signInWithCredential(credential),
          verificationFailed: (e) => _fail(e.message ?? 'تعذّر إرسال الرمز'),
          codeSent: (id, _) => setState(() {
            _verificationId = id;
            _busy = false;
          }),
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        final result = await _auth.signInWithPhoneNumber(phone);
        setState(() {
          _webConfirmation = result;
          _busy = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      _fail(e.message ?? 'تعذّر إرسال الرمز');
    }
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'الرمز مكوّن من ٦ أرقام');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_webConfirmation != null) {
        await _webConfirmation!.confirm(code);
      } else {
        await _auth.signInWithCredential(
          PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: code),
        );
      }
    } on FirebaseAuthException {
      _fail('الرمز غير صحيح، حاول مرة أخرى');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final codeSent = _verificationId != null || _webConfirmation != null;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.local_shipping, size: 56, color: AppColors.teal),
            const SizedBox(height: 16),
            const Text(
              'أهلًا بك في نقل',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              codeSent ? 'أدخل الرمز المرسل إلى جوالك' : 'سجّل دخولك برقم جوالك',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 32),
            if (!codeSent)
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'رقم الجوال', hintText: '05xxxxxxxx'),
              )
            else
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'رمز التحقق'),
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFB3261E), fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : (codeSent ? _verify : _sendCode),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(codeSent ? 'تأكيد' : 'أرسل الرمز'),
            ),
            if (codeSent)
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _verificationId = null;
                          _webConfirmation = null;
                          _code.clear();
                        }),
                child: const Text('تغيير الرقم'),
              ),
          ],
        ),
      ),
    );
  }
}
