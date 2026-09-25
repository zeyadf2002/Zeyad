import 'package:flutter/foundation.dart';

import 'models.dart';

/// حالة التطبيق في الذاكرة. لاحقًا تُستبدل بقاعدة بيانات (Firebase)،
/// وتبقى الشاشات كما هي.
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  static const cities = [
    'الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة', 'أبها', 'تبوك', 'القصيم',
  ];

  /// نسبة عمولة المنصة من كل حجز.
  static const commissionRate = 0.10;

  final List<Company> companies = const [
    Company(
      id: 'c1',
      name: 'الناقل السريع',
      carrier: CarrierType.enclosed,
      cities: ['الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة', 'أبها'],
      rating: 4.8,
      reviewCount: 340,
    ),
    Company(
      id: 'c2',
      name: 'درب للنقل',
      carrier: CarrierType.open,
      cities: ['الرياض', 'جدة', 'الدمام', 'القصيم'],
      rating: 4.6,
      reviewCount: 210,
    ),
    Company(
      id: 'c3',
      name: 'سطحة الخليج',
      carrier: CarrierType.flatbed,
      cities: ['الدمام', 'الرياض', 'تبوك'],
      rating: 4.5,
      reviewCount: 98,
    ),
  ];

  final List<TransportRequest> requests = [];
  final List<Quote> quotes = [];

  /// الشركة التي يعمل بها "وضع الشركة" في هذه النسخة التجريبية.
  String activeCompanyId = 'c1';

  int _nextId = 1;
  String _id(String prefix) => '$prefix${_nextId++}';

  Company companyById(String id) => companies.firstWhere((c) => c.id == id);

  Quote quoteById(String id) => quotes.firstWhere((q) => q.id == id);

  List<Quote> quotesFor(String requestId) =>
      quotes.where((q) => q.requestId == requestId).toList();

  List<TransportRequest> get myRequests => requests.reversed.toList();

  /// الطلبات المفتوحة التي لم ترسل لها الشركة الحالية عرضًا بعد.
  List<TransportRequest> get openRequestsForActiveCompany => requests
      .where((r) =>
          r.status == OrderStatus.open &&
          !quotes.any((q) => q.requestId == r.id && q.companyId == activeCompanyId))
      .toList()
      .reversed
      .toList();

  List<TransportRequest> get activeCompanyTrips => requests
      .where((r) =>
          r.bookedQuoteId != null &&
          quoteById(r.bookedQuoteId!).companyId == activeCompanyId &&
          r.status != OrderStatus.delivered)
      .toList();

  double get activeCompanyCommissionDue => requests
      .where((r) =>
          r.bookedQuoteId != null &&
          quoteById(r.bookedQuoteId!).companyId == activeCompanyId)
      .fold(0, (sum, r) => sum + quoteById(r.bookedQuoteId!).price * commissionRate);

  TransportRequest submitRequest({
    required String from,
    required String to,
    required String car,
    required CarrierType carrier,
    required DateTime pickupDate,
  }) {
    final request = TransportRequest(
      id: _id('r'),
      from: from,
      to: to,
      car: car,
      carrier: carrier,
      pickupDate: pickupDate,
      createdAt: DateTime.now(),
    );
    requests.add(request);
    // في النسخة التجريبية: شركتان ترسلان عروضًا فورًا حتى تظهر المقارنة.
    quotes.add(Quote(id: _id('q'), requestId: request.id, companyId: 'c2', price: 950, days: 3));
    quotes.add(Quote(id: _id('q'), requestId: request.id, companyId: 'c3', price: 1100, days: 4));
    notifyListeners();
    return request;
  }

  void sendQuote({required String requestId, required int price, required int days}) {
    quotes.add(Quote(
      id: _id('q'),
      requestId: requestId,
      companyId: activeCompanyId,
      price: price,
      days: days,
    ));
    notifyListeners();
  }

  void book(TransportRequest request, Quote quote) {
    request
      ..bookedQuoteId = quote.id
      ..status = OrderStatus.booked;
    notifyListeners();
  }

  void advance(TransportRequest request) {
    final next = request.status.index + 1;
    if (next < OrderStatus.values.length) {
      request.status = OrderStatus.values[next];
      notifyListeners();
    }
  }

  void _seed() {
    final r = TransportRequest(
      id: _id('r'),
      from: 'الدمام',
      to: 'الرياض',
      car: 'هيونداي سوناتا',
      carrier: CarrierType.open,
      pickupDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    requests.add(r);
  }
}
