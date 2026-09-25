import 'package:flutter/material.dart';

import '../data/models.dart';
import '../main.dart';
import '../theme.dart';
import 'widgets.dart';

/// الشاشة ٤: تتبع الطلب.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.requestId});

  final String requestId;

  static const _steps = [
    OrderStatus.booked,
    OrderStatus.pickedUp,
    OrderStatus.inTransit,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final request = state.requests.firstWhere((r) => r.id == requestId);
    final quote = request.bookedQuoteId == null ? null : state.quoteById(request.bookedQuoteId!);
    final company = quote == null ? null : state.companyById(quote.companyId);

    return Scaffold(
      appBar: AppBar(title: Text(request.status.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text('طلب رقم ${request.id}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 12),
          if (company != null)
            AppCard(
              child: Row(
                children: [
                  CompanyAvatar(letter: company.initial, warm: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(company.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${request.route} · ${request.car}',
                            style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Text('${quote!.price} ر.س', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                for (var i = 0; i < _steps.length; i++)
                  _StepRow(
                    status: _steps[i],
                    done: request.status.index > _steps[i].index ||
                        request.status == OrderStatus.delivered,
                    current: request.status == _steps[i] && request.status != OrderStatus.delivered,
                    last: i == _steps.length - 1,
                    subtitle: switch (_steps[i]) {
                      OrderStatus.booked => 'الاستلام ${formatDate(request.pickupDate)}',
                      OrderStatus.pickedUp => 'مع صور حالة السيارة عند الاستلام',
                      OrderStatus.inTransit => 'الوصول خلال ${quote?.days ?? '-'} أيام',
                      _ => 'بعدها تقيّم الشركة',
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (request.status == OrderStatus.delivered)
            const AppCard(child: Text('تم تسليم سيارتك. شكرًا لاستخدامك التطبيق!'))
          else
            FilledButton(
              onPressed: () => state.advance(request),
              child: Text(request.status == OrderStatus.inTransit
                  ? 'أكّد الاستلام'
                  : 'تحديث الحالة (تجريبي)'),
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.status,
    required this.done,
    required this.current,
    required this.last,
    required this.subtitle,
  });

  final OrderStatus status;
  final bool done;
  final bool current;
  final bool last;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final dot = done
        ? const CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.teal,
            child: Icon(Icons.check, size: 14, color: Colors.white),
          )
        : Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: current ? const Color(0xFFC8742B) : AppColors.line, width: current ? 3 : 2),
            ),
          );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              dot,
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    constraints: const BoxConstraints(minHeight: 40),
                    color: done ? AppColors.teal : AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: TextStyle(
                      fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                      color: current
                          ? AppColors.amberDeep
                          : done
                              ? AppColors.ink
                              : AppColors.muted,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
