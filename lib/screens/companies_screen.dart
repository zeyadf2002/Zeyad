import 'package:flutter/material.dart';

import '../main.dart';
import 'company_profile_screen.dart';
import 'widgets.dart';

/// دليل الشركات.
class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final companies = [...AppScope.of(context).companies]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('شركات النقل', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        for (final c in companies) ...[
          CompanyTile(
            company: c,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CompanyProfileScreen(company: c)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
