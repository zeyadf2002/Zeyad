import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_state.dart';
import 'data/firestore_backend.dart';
import 'firebase_options.dart';
import 'screens/company_mode_screen.dart';
import 'screens/customer_shell.dart';
import 'screens/phone_login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const NaqlApp());
  } catch (e) {
    // Firebase غير مُعدّ: نشغّل وضع التجربة ببيانات في الذاكرة.
    debugPrint('وضع التجربة: $e');
    runApp(NaqlApp(demoState: AppState()));
  }
}

/// يوفر حالة التطبيق لكل الشاشات.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

/// التطبيق. مع [demoState] يعمل بدون Firebase، وإلا يطلب تسجيل الدخول
/// ويقرأ البيانات من Firestore.
class NaqlApp extends StatefulWidget {
  const NaqlApp({super.key, this.demoState});

  final AppState? demoState;

  @override
  State<NaqlApp> createState() => _NaqlAppState();
}

class _NaqlAppState extends State<NaqlApp> {
  AppState? _state;
  StreamSubscription<User?>? _authSub;
  bool _authKnown = false;
  bool _companyMode = false;

  bool get _isDemo => widget.demoState != null;

  @override
  void initState() {
    super.initState();
    if (_isDemo) {
      _state = widget.demoState;
      _authKnown = true;
    } else {
      _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUser);
    }
  }

  void _onUser(User? user) {
    if (user?.uid == _state?.uid && _authKnown) return;
    _state?.dispose();
    setState(() {
      _authKnown = true;
      _companyMode = false;
      _state = user == null ? null : AppState(backend: FirestoreBackend(), uid: user.uid);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    if (!_isDemo) _state?.dispose();
    super.dispose();
  }

  void _toggleMode() => setState(() => _companyMode = !_companyMode);

  Future<void> _signOut() => FirebaseAuth.instance.signOut();

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final Widget home;
    if (!_authKnown) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (state == null) {
      home = const PhoneLoginScreen();
    } else if (_companyMode) {
      home = CompanyModeScreen(key: ValueKey(state.uid), onSwitchMode: _toggleMode);
    } else {
      home = CustomerShell(
        key: ValueKey(state.uid),
        onSwitchMode: _toggleMode,
        onSignOut: _isDemo ? null : _signOut,
      );
    }

    return MaterialApp(
      title: 'نقل',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          state == null ? child! : AppScope(state: state, child: child!),
      home: home,
    );
  }
}
