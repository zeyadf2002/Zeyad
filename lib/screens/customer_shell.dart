import 'package:flutter/material.dart';

import '../theme.dart';
import 'companies_screen.dart';
import 'home_screen.dart';
import 'my_requests_screen.dart';

/// واجهة العميل مع الشريط السفلي.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key, required this.onSwitchMode, this.onSignOut});

  final VoidCallback onSwitchMode;

  /// غير متاح في وضع التجربة.
  final VoidCallback? onSignOut;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const MyRequestsScreen(),
      const CompaniesScreen(),
      _AccountPage(onSwitchMode: widget.onSwitchMode, onSignOut: widget.onSignOut),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.tealSoft,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'طلباتي'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: 'الشركات'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({required this.onSwitchMode, this.onSignOut});

  final VoidCallback onSwitchMode;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('حسابي', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.swap_horiz, color: AppColors.teal),
            title: const Text('التحويل إلى وضع الشركة', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('لأصحاب شركات النقل: استقبل الطلبات وأرسل عروضك'),
            onTap: onSwitchMode,
          ),
        ),
        if (onSignOut != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: AppColors.muted),
              title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: onSignOut,
            ),
          ),
        ],
      ],
    );
  }
}
