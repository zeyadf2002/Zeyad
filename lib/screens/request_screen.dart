import 'package:flutter/material.dart';

import '../data/models.dart';
import '../main.dart';
import '../theme.dart';
import 'quotes_screen.dart';
import 'widgets.dart';

/// الشاشة ٢: طلب نقل سيارة.
class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key, required this.from, required this.to});

  final String from;
  final String to;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  late String _from = widget.from;
  late String _to = widget.to;
  final _car = TextEditingController();
  CarrierType _carrier = CarrierType.enclosed;
  DateTime _date = DateTime.now().add(const Duration(days: 2));
  String? _error;

  @override
  void dispose() {
    _car.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (_from == _to) {
      setState(() => _error = 'مدينة الانطلاق والوصول متشابهتان');
      return;
    }
    if (_car.text.trim().isEmpty) {
      setState(() => _error = 'اكتب نوع السيارة وموديلها');
      return;
    }
    final request = AppScope.of(context).submitRequest(
      from: _from,
      to: _to,
      car: _car.text.trim(),
      carrier: _carrier,
      pickupDate: _date,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => QuotesScreen(requestId: request.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب نقل سيارة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CityDropdown(label: 'من', value: _from, onChanged: (v) => setState(() => _from = v)),
          const SizedBox(height: 14),
          CityDropdown(label: 'إلى', value: _to, onChanged: (v) => setState(() => _to = v)),
          const SizedBox(height: 14),
          const Text('السيارة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _car,
            decoration: const InputDecoration(hintText: 'مثال: تويوتا كامري ٢٠٢٤'),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          const Text('تاريخ الاستلام', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.line),
              backgroundColor: Colors.white,
              alignment: AlignmentDirectional.centerStart,
            ),
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(formatDate(_date)),
          ),
          const SizedBox(height: 14),
          const Text('صور السيارة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('رفع الصور يُضاف مع ربط قاعدة البيانات')),
              ),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('إضافة صور'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: Color(0xFFB3261E), fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('أرسل الطلب للشركات')),
        ],
      ),
    );
  }
}
