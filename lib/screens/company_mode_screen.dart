import 'package:flutter/material.dart';

import '../data/models.dart';
import '../main.dart';
import '../theme.dart';
import 'widgets.dart';

/// الشاشة ٦: وضع الشركة.
class CompanyModeScreen extends StatelessWidget {
  const CompanyModeScreen({super.key, required this.onSwitchMode});

  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final company = state.companyById(state.activeCompanyId);
    final open = state.openRequestsForActiveCompany;

    return Scaffold(
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('وضع الشركة · ${company.name}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFA8B0B8))),
                      const Text('طلبات جديدة',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(14)),
                  child: Text('${open.length} طلبات',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _DarkStat(label: 'رحلات جارية', value: '${state.activeCompanyTrips.length}'),
                const SizedBox(width: 10),
                _DarkStat(
                  label: 'عمولة المنصة المستحقة',
                  value: '${state.activeCompanyCommissionDue.round()} ر.س',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (open.isEmpty)
              const AppCard(child: Text('لا توجد طلبات جديدة الآن.')),
            for (final r in open) ...[
              _RequestCard(request: r),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onSwitchMode,
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFC9CFD5)),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('العودة إلى وضع العميل'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.nightCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFA8B0B8))),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({required this.request});

  final TransportRequest request;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  final _price = TextEditingController();
  final _days = TextEditingController(text: '3');

  @override
  void dispose() {
    _price.dispose();
    _days.dispose();
    super.dispose();
  }

  void _send() {
    final price = int.tryParse(_price.text.trim());
    final days = int.tryParse(_days.text.trim());
    if (price == null || price <= 0 || days == null || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل السعر وعدد الأيام بالأرقام')),
      );
      return;
    }
    AppScope.of(context).sendQuote(requestId: widget.request.id, price: price, days: days);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال عرضك للعميل')));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.route, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${r.car} · ناقلة ${r.carrier.label} · ${formatDate(r.pickupDate)}',
              style: const TextStyle(fontSize: 14, color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'سعرك (ر.س)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _days,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الأيام'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
            onPressed: _send,
            child: const Text('أرسل العرض'),
          ),
        ],
      ),
    );
  }
}
