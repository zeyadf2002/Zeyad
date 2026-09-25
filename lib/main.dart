import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_state.dart';
import 'screens/company_mode_screen.dart';
import 'screens/customer_shell.dart';
import 'theme.dart';

void main() {
  runApp(NaqlApp(state: AppState()));
}

/// يوفر حالة التطبيق لكل الشاشات.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class NaqlApp extends StatefulWidget {
  const NaqlApp({super.key, required this.state});

  final AppState state;

  @override
  State<NaqlApp> createState() => _NaqlAppState();
}

class _NaqlAppState extends State<NaqlApp> {
  bool _companyMode = false;

  void _toggleMode() => setState(() => _companyMode = !_companyMode);

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.state,
      child: MaterialApp(
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
        home: _companyMode
            ? CompanyModeScreen(onSwitchMode: _toggleMode)
            : CustomerShell(onSwitchMode: _toggleMode),
      ),
    );
  }
}
