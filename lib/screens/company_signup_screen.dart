import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../main.dart';
import '../theme.dart';

/// يظهر في "وضع الشركة" لمن لا يملك شركة موثّقة: نموذج التسجيل،
/// أو حالة "بانتظار التوثيق" بعد الإرسال.
class CompanySignupScreen extends StatefulWidget {
  const CompanySignupScreen({super.key, required this.onSwitchMode});

  final VoidCallback onSwitchMode;

  @override
  State<CompanySignupScreen> createState() => _CompanySignupScreenState();
}

class _CompanySignupScreenState extends State<CompanySignupScreen> {
  final _name = TextEditingController();
  CarrierType _carrier = CarrierType.enclosed;
  final Set<String> _cities = {};
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'اكتب اسم الشركة');
      return;
    }
    if (_cities.isEmpty) {
      setState(() => _error = 'اختر مدينة واحدة على الأقل');
      return;
    }
    AppScope.of(context).registerCompany(
      name: name,
      carrier: _carrier,
      cities: [for (final c in AppState.cities) if (_cities.contains(c)) c],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = AppScope.of(context).pendingCompany;
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجّل شركتك'),
        actions: [
          TextButton(onPressed: widget.onSwitchMode, child: const Text('وضع العميل')),
        ],
      ),
      body: pending != null ? _Pending(company: pending) : _form(),
    );
  }

  Widget _form() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'سجّل شركة النقل لتستقبل طلبات العملاء وترسل عروضك. نراجع الطلب ثم نوثّق الشركة.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        const Text('اسم الشركة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(controller: _name, decoration: const InputDecoration(hintText: 'مثال: الناقل السريع')),
        const SizedBox(height: 16),
        const Text('نوع الناقلة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SegmentedButton<CarrierType>(
          segments: [
            for (final t in CarrierType.values) ButtonSegment(value: t, label: Text(t.label)),
          ],
          selected: {_carrier},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _carrier = s.first),
        ),
        const SizedBox(height: 16),
        const Text('المدن التي تخدمها', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in AppState.cities)
              FilterChip(
                label: Text(c),
                selected: _cities.contains(c),
                onSelected: (on) => setState(() => on ? _cities.add(c) : _cities.remove(c)),
              ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          Text(_error!, style: const TextStyle(color: Color(0xFFB3261E), fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 24),
        FilledButton(onPressed: _submit, child: const Text('أرسل طلب التسجيل')),
      ],
    );
  }
}

class _Pending extends StatelessWidget {
  const _Pending({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_top, size: 56, color: AppColors.amberDeep),
          const SizedBox(height: 16),
          Text(
            'تم استلام طلب تسجيل ${company.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'الطلب بانتظار التوثيق. بعد الموافقة يفتح لك هذا الوضع لاستقبال الطلبات وإرسال العروض.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
