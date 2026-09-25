import 'package:flutter/material.dart';

import '../data/models.dart';
import '../main.dart';
import '../theme.dart';
import 'tracking_screen.dart';
import 'widgets.dart';

enum _Sort { cheapest, fastest, topRated }

/// الشاشة ٣: مقارنة العروض.
class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  _Sort _sort = _Sort.cheapest;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final request = state.requests.firstWhere((r) => r.id == widget.requestId);
    final quotes = state.quotesFor(request.id);
    quotes.sort((a, b) => switch (_sort) {
          _Sort.cheapest => a.price.compareTo(b.price),
          _Sort.fastest => a.days.compareTo(b.days),
          _Sort.topRated =>
            state.companyById(b.companyId).rating.compareTo(state.companyById(a.companyId).rating),
        });
    final cheapest = quotes.isEmpty ? null : quotes.map((q) => q.price).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(title: Text('وصلتك ${quotes.length} عروض')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(
            '${request.route} · ${request.car} · ناقلة ${request.carrier.label}',
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final (s, label) in [
                (_Sort.cheapest, 'الأرخص'),
                (_Sort.fastest, 'الأسرع'),
                (_Sort.topRated, 'الأعلى تقييمًا'),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _sort == s,
                  onSelected: (_) => setState(() => _sort = s),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (quotes.isEmpty)
            const AppCard(child: Text('لم تصل عروض بعد. سننبهك عند وصول أول عرض.')),
          for (final q in quotes) ...[
            _QuoteCard(
              quote: q,
              best: q.price == cheapest,
              onBook: () {
                state.book(request, q);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => TrackingScreen(requestId: request.id)),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
          const Text(
            'الدفع للشركة مباشرة عند الاستلام',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.best, required this.onBook});

  final Quote quote;
  final bool best;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final company = AppScope.of(context).companyById(quote.companyId);
    return AppCard(
      border: best ? Border.all(color: AppColors.teal, width: 2) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(company.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              if (best)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tealSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'أفضل سعر',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingText(rating: company.rating, count: company.reviewCount),
              const SizedBox(width: 16),
              Text('التسليم خلال ${quote.days} أيام',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('${quote.price} ر.س',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              ),
              best
                  ? FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
                      onPressed: onBook,
                      child: const Text('احجز'),
                    )
                  : OutlinedButton(onPressed: onBook, child: const Text('احجز')),
            ],
          ),
        ],
      ),
    );
  }
}
