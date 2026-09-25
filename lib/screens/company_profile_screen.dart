import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme.dart';
import 'request_screen.dart';

/// الشاشة ٥: ملف الشركة.
class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({
    super.key,
    required this.company,
    this.from = 'الرياض',
    this.to = 'جدة',
  });

  final Company company;
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Container(
            color: AppColors.teal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Row(
              children: [
                CompanyAvatar(letter: company.initial, size: 64),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(
                      company.verified ? 'شركة موثّقة · سجل تجاري' : 'بانتظار التوثيق',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFCFE3E1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                child: Row(
                  children: [
                    _Stat(value: company.rating.toStringAsFixed(1), label: 'التقييم'),
                    _Stat(value: '${company.reviewCount}', label: 'تقييم'),
                    _Stat(value: '${company.cities.length}', label: 'مدينة'),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('المدن التي تخدمها', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in company.cities)
                      Chip(label: Text(c), backgroundColor: Colors.white, side: BorderSide.none),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('نوع الناقلة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(company.carrier.label),
                const SizedBox(height: 20),
                const Text('آراء العملاء', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const AppCard(
                  child: Text('تظهر هنا تقييمات العملاء بعد كل عملية تسليم.',
                      style: TextStyle(color: AppColors.muted)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RequestScreen(from: from, to: to),
                  )),
                  child: const Text('اطلب عرض سعر'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}
