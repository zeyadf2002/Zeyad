import 'dart:async';

import 'package:flutter/foundation.dart';

import 'backend.dart';
import 'models.dart';

/// حالة التطبيق التي تقرأ منها الشاشات.
///
/// بدون [backend] تعمل في وضع التجربة ببيانات في الذاكرة. مع [backend]
/// تتابع قاعدة البيانات وتحفظ فيها كل طلب وعرض وتحديث حالة.
class AppState extends ChangeNotifier {
  AppState({this.backend, this.uid = demoUid}) {
    if (backend == null) {
      _verified = _demoCompanies(uid);
      _seedDemo();
    } else {
      _listen();
    }
  }

  static const demoUid = 'demo-user';

  static const cities = [
    'الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة', 'أبها', 'تبوك', 'القصيم',
  ];

  /// نسبة عمولة المنصة من كل حجز.
  static const commissionRate = 0.10;

  final Backend? backend;

  /// المستخدم الحالي.
  final String uid;

  bool get isDemo => backend == null;

  List<Company> _verified = [];
  List<Company> _owned = [];
  List<Rating> ratings = [];

  /// الشركات الموثّقة، وتقييمها يشمل تقييمات العملاء الجديدة.
  List<Company> get companies => [for (final c in _verified) _withRatings(c)];

  Company _withRatings(Company c) {
    final mine = ratingsFor(c.id);
    if (mine.isEmpty) return c;
    final total = c.rating * c.reviewCount + mine.fold<int>(0, (s, r) => s + r.stars);
    final count = c.reviewCount + mine.length;
    return c.copyWith(rating: total / count, reviewCount: count);
  }

  List<Rating> ratingsFor(String companyId) =>
      ratings.where((r) => r.companyId == companyId).toList();

  Rating? ratingForRequest(String requestId) {
    for (final r in ratings) {
      if (r.requestId == requestId) return r;
    }
    return null;
  }

  /// شركة سجّلها المستخدم وما زالت بانتظار التوثيق.
  Company? get pendingCompany {
    for (final c in _owned) {
      if (!c.verified) return c;
    }
    return null;
  }

  /// الأحدث أولًا.
  List<TransportRequest> requests = [];

  final Map<String, Quote> _quotes = {};
  List<Quote> get quotes => _quotes.values.toList();

  final List<StreamSubscription<dynamic>> _subs = [];
  StreamSubscription<dynamic>? _companyQuotesSub;
  String? _watchedCompanyId;

  int _nextId = 1;
  String _id(String prefix) => backend?.newId() ?? '$prefix${_nextId++}';

  /// الشركة التي يملكها المستخدم الحالي، وتفتح له "وضع الشركة".
  Company? get myCompany {
    for (final c in companies) {
      if (c.ownerUid == uid) return c;
    }
    return null;
  }

  String? get activeCompanyId => myCompany?.id;

  Company companyById(String id) => [...companies, ..._owned].firstWhere(
        (c) => c.id == id,
        orElse: () => Company(
          id: id,
          name: 'شركة نقل',
          carrier: CarrierType.open,
          cities: const [],
          rating: 0,
          reviewCount: 0,
        ),
      );

  Quote? quoteById(String id) => _quotes[id];

  List<Quote> quotesFor(String requestId) =>
      _quotes.values.where((q) => q.requestId == requestId).toList();

  List<TransportRequest> get myRequests =>
      requests.where((r) => r.customerId == uid).toList();

  bool _bookedWithMe(TransportRequest r) {
    final id = r.bookedQuoteId;
    return id != null && activeCompanyId != null && _quotes[id]?.companyId == activeCompanyId;
  }

  /// الطلبات المفتوحة التي لم ترسل لها الشركة الحالية عرضًا بعد.
  List<TransportRequest> get openRequestsForActiveCompany => requests
      .where((r) =>
          r.status == OrderStatus.open &&
          r.customerId != uid &&
          !_quotes.values.any((q) => q.requestId == r.id && q.companyId == activeCompanyId))
      .toList();

  List<TransportRequest> get activeCompanyTrips =>
      requests.where((r) => _bookedWithMe(r) && r.status != OrderStatus.delivered).toList();

  double get activeCompanyCommissionDue => requests
      .where(_bookedWithMe)
      .fold(0, (sum, r) => sum + _quotes[r.bookedQuoteId]!.price * commissionRate);

  TransportRequest submitRequest({
    required String from,
    required String to,
    required String car,
    required CarrierType carrier,
    required DateTime pickupDate,
  }) {
    final request = TransportRequest(
      id: _id('r'),
      customerId: uid,
      from: from,
      to: to,
      car: car,
      carrier: carrier,
      pickupDate: pickupDate,
      createdAt: DateTime.now(),
    );
    requests.insert(0, request);
    if (isDemo) {
      // في وضع التجربة: شركتان ترسلان عروضًا فورًا حتى تظهر المقارنة.
      for (final (companyId, price, days) in [('c2', 950, 3), ('c3', 1100, 4)]) {
        final q = Quote(
          id: _id('q'),
          requestId: request.id,
          customerId: uid,
          companyId: companyId,
          price: price,
          days: days,
        );
        _quotes[q.id] = q;
      }
    }
    backend?.saveRequest(request);
    notifyListeners();
    return request;
  }

  void sendQuote({required String requestId, required int price, required int days}) {
    final companyId = activeCompanyId;
    if (companyId == null) return;
    final request = requests.firstWhere((r) => r.id == requestId);
    final quote = Quote(
      id: _id('q'),
      requestId: requestId,
      customerId: request.customerId,
      companyId: companyId,
      price: price,
      days: days,
    );
    _quotes[quote.id] = quote;
    backend?.saveQuote(quote);
    notifyListeners();
  }

  void book(TransportRequest request, Quote quote) {
    request
      ..bookedQuoteId = quote.id
      ..status = OrderStatus.booked;
    backend?.saveRequest(request);
    notifyListeners();
  }

  /// طلب تسجيل شركة نقل. تبقى غير موثّقة حتى تراجعها الإدارة.
  Company registerCompany({
    required String name,
    required CarrierType carrier,
    required List<String> cities,
  }) {
    final company = Company(
      id: _id('c'),
      name: name,
      carrier: carrier,
      cities: cities,
      rating: 0,
      reviewCount: 0,
      verified: false,
      ownerUid: uid,
    );
    _owned = [..._owned, company];
    backend?.saveCompany(company);
    notifyListeners();
    return company;
  }

  /// تقييم الشركة بعد تسليم السيارة. مرة واحدة لكل طلب.
  void rate(TransportRequest request, {required int stars, String comment = ''}) {
    final quote = request.bookedQuoteId == null ? null : _quotes[request.bookedQuoteId];
    if (quote == null ||
        request.status != OrderStatus.delivered ||
        request.customerId != uid ||
        ratingForRequest(request.id) != null ||
        stars < 1 ||
        stars > 5) {
      return;
    }
    final rating = Rating(
      requestId: request.id,
      companyId: quote.companyId,
      customerId: uid,
      stars: stars,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );
    ratings = [rating, ...ratings];
    backend?.saveRating(rating);
    notifyListeners();
  }

  void advance(TransportRequest request) {
    final next = request.status.index + 1;
    if (next < OrderStatus.values.length) {
      request.status = OrderStatus.values[next];
      backend?.saveRequest(request);
      notifyListeners();
    }
  }

  void _listen() {
    final b = backend!;
    _subs.add(b.watchCompanies().listen((list) {
      _verified = list;
      _watchCompanyQuotes();
      notifyListeners();
    }));
    _subs.add(b.watchRequests().listen((list) {
      requests = list;
      notifyListeners();
    }));
    _subs.add(b.watchQuotesForCustomer(uid).listen(_mergeQuotes));
    _subs.add(b.watchOwnedCompanies(uid).listen((list) {
      _owned = list;
      notifyListeners();
    }));
    _subs.add(b.watchRatings().listen((list) {
      ratings = list;
      notifyListeners();
    }));
  }

  void _watchCompanyQuotes() {
    final companyId = activeCompanyId;
    if (companyId == _watchedCompanyId) return;
    _watchedCompanyId = companyId;
    _companyQuotesSub?.cancel();
    _companyQuotesSub =
        companyId == null ? null : backend!.watchQuotesForCompany(companyId).listen(_mergeQuotes);
  }

  void _mergeQuotes(List<Quote> list) {
    for (final q in list) {
      _quotes[q.id] = q;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _companyQuotesSub?.cancel();
    super.dispose();
  }

  static List<Company> _demoCompanies(String ownerUid) => [
        Company(
          id: 'c1',
          name: 'الناقل السريع',
          carrier: CarrierType.enclosed,
          cities: const ['الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة', 'أبها'],
          rating: 4.8,
          reviewCount: 340,
          ownerUid: ownerUid,
        ),
        const Company(
          id: 'c2',
          name: 'درب للنقل',
          carrier: CarrierType.open,
          cities: ['الرياض', 'جدة', 'الدمام', 'القصيم'],
          rating: 4.6,
          reviewCount: 210,
        ),
        const Company(
          id: 'c3',
          name: 'سطحة الخليج',
          carrier: CarrierType.flatbed,
          cities: ['الدمام', 'الرياض', 'تبوك'],
          rating: 4.5,
          reviewCount: 98,
        ),
      ];

  void _seedDemo() {
    requests.add(TransportRequest(
      id: _id('r'),
      customerId: 'demo-other-customer',
      from: 'الدمام',
      to: 'الرياض',
      car: 'هيونداي سوناتا',
      carrier: CarrierType.open,
      pickupDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ));
  }
}
