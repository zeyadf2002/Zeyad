import 'package:flutter/material.dart';

import '../main.dart';
import '../theme.dart';
import 'company_profile_screen.dart';
import 'request_screen.dart';
import 'widgets.dart';

/// الشاشة ١: الرئيسية.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _from = 'الرياض';
  String _to = 'جدة';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        const Text('مرحبًا', style: TextStyle(color: AppColors.muted, fontSize: 14)),
        const SizedBox(height: 4),
        const Text('وين تبي تنقل سيارتك؟', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CityDropdown(
                label: 'من',
                value: _from,
                onDark: true,
                onChanged: (v) => setState(() => _from = v),
              ),
              const SizedBox(height: 12),
              CityDropdown(
                label: 'إلى',
                value: _to,
                onDark: true,
                onChanged: (v) => setState(() => _to = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: AppColors.ink,
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RequestScreen(from: _from, to: _to),
                )),
                child: const Text('اطلب عروض أسعار'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('شركات موثوقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final c in state.companies) ...[
          CompanyTile(
            company: c,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CompanyProfileScreen(company: c, from: _from, to: _to),
            )),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
