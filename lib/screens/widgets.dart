import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';

class CityDropdown extends StatelessWidget {
  const CityDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onDark = false,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: onDark ? const Color(0xFFCFE3E1) : AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: onDark ? BorderSide.none : const BorderSide(color: AppColors.line),
            ),
          ),
          items: [
            for (final c in AppState.cities) DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ],
    );
  }
}

class RatingText extends StatelessWidget {
  const RatingText({super.key, required this.rating, this.count});

  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final text = count == null
        ? '★ ${rating.toStringAsFixed(1)}'
        : '★ ${rating.toStringAsFixed(1)} ($count)';
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.amberDeep),
    );
  }
}

class CompanyTile extends StatelessWidget {
  const CompanyTile({super.key, required this.company, required this.onTap});

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CompanyAvatar(letter: company.initial, warm: company.carrier == CarrierType.open),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      'ناقلة ${company.carrier.label} · ${company.cities.length} مدن',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              RatingText(rating: company.rating),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDate(DateTime d) {
  const days = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
}
