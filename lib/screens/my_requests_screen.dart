import 'package:flutter/material.dart';

import '../data/models.dart';
import '../main.dart';
import '../theme.dart';
import 'quotes_screen.dart';
import 'tracking_screen.dart';

/// طلباتي.
class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final requests = state.myRequests;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('طلباتي', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          const AppCard(child: Text('لا توجد طلبات بعد.')),
        for (final r in requests) ...[
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: Text(r.route, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${r.car} · ${r.status.label}'),
              trailing: r.status == OrderStatus.open
                  ? Text('${state.quotesFor(r.id).length} عروض',
                      style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600))
                  : const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => r.status == OrderStatus.open
                    ? QuotesScreen(requestId: r.id)
                    : TrackingScreen(requestId: r.id),
              )),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
