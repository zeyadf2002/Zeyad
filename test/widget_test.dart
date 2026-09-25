import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:naql/data/app_state.dart';
import 'package:naql/data/backend.dart';
import 'package:naql/data/models.dart';
import 'package:naql/main.dart';
import 'package:naql/screens/phone_login_screen.dart';

void main() {
  testWidgets('الرئيسية تعرض الشركات وزر طلب العروض', (tester) async {
    await tester.pumpWidget(NaqlApp(demoState: AppState()));
    await tester.pumpAndSettle();
    expect(find.text('اطلب عروض أسعار'), findsOneWidget);
    expect(find.text('الناقل السريع'), findsOneWidget);
  });

  test('وضع التجربة: طلب جديد يستقبل عروضًا ثم يُحجز ويُسلّم', () {
    final state = AppState();
    final other = state.openRequestsForActiveCompany.single;
    state.sendQuote(requestId: other.id, price: 1000, days: 2);
    expect(state.openRequestsForActiveCompany, isEmpty);

    final mine = state.quotesFor(other.id).single;
    state.book(other, mine);
    expect(state.activeCompanyCommissionDue, 100);
    expect(state.activeCompanyTrips, [other]);

    final r = state.submitRequest(
      from: 'الرياض',
      to: 'جدة',
      car: 'كامري',
      carrier: CarrierType.enclosed,
      pickupDate: DateTime.now(),
    );
    expect(state.myRequests, [r]);
    expect(state.quotesFor(r.id).length, 2);
    for (var i = 0; i < 4; i++) {
      state.advance(r);
    }
    expect(r.status, OrderStatus.delivered);
  });

  test('مع قاعدة البيانات: يقرأ منها ويحفظ فيها بدون عروض وهمية', () async {
    final backend = FakeBackend();
    final state = AppState(backend: backend, uid: 'u1');
    backend.companies.add([
      const Company(
        id: 'c9',
        name: 'شركتي',
        carrier: CarrierType.open,
        cities: ['الرياض'],
        rating: 5,
        reviewCount: 1,
        ownerUid: 'u1',
      ),
    ]);
    await pumpEventQueue();
    expect(state.activeCompanyId, 'c9');
    expect(backend.watchedCompanyQuotes, ['c9']);

    final r = state.submitRequest(
      from: 'الرياض',
      to: 'جدة',
      car: 'كامري',
      carrier: CarrierType.open,
      pickupDate: DateTime(2026, 10, 1),
    );
    expect(state.quotesFor(r.id), isEmpty);
    expect(backend.savedRequests.single.customerId, 'u1');

    final incoming = TransportRequest(
      id: 'r2',
      customerId: 'u2',
      from: 'جدة',
      to: 'الدمام',
      car: 'سوناتا',
      carrier: CarrierType.open,
      pickupDate: DateTime(2026, 10, 2),
      createdAt: DateTime(2026, 9, 25),
    );
    backend.requests.add([incoming, r]);
    await pumpEventQueue();
    expect(state.openRequestsForActiveCompany.map((x) => x.id), ['r2']);

    state.sendQuote(requestId: 'r2', price: 800, days: 2);
    final sent = backend.savedQuotes.single;
    expect(sent.customerId, 'u2');
    expect(sent.companyId, 'c9');
    state.dispose();
  });

  test('تحويل الرقم إلى الصيغة الدولية', () {
    const n = normalizeSaudiPhone;
    expect(n('0512345678'), '+966512345678');
    expect(n('512345678'), '+966512345678');
    expect(n('+966 51 234 5678'), '+966512345678');
    expect(n('٠٥١٢٣٤٥٦٧٨'), '+966512345678');
    expect(n('0412345678'), isNull);
    expect(n('05123'), isNull);
  });

  test('تحويل البيانات إلى خريطة والعكس', () {
    final r = TransportRequest(
      id: 'x',
      customerId: 'u',
      from: 'أ',
      to: 'ب',
      car: 'ج',
      carrier: CarrierType.flatbed,
      pickupDate: DateTime(2026, 1, 2),
      createdAt: DateTime(2026, 1, 1),
      status: OrderStatus.inTransit,
      bookedQuoteId: 'q',
    );
    final back = TransportRequest.fromMap('x', r.toMap());
    expect(back.toMap(), r.toMap());
  });
}

class FakeBackend implements Backend {
  final companies = StreamController<List<Company>>.broadcast();
  final requests = StreamController<List<TransportRequest>>.broadcast();
  final savedRequests = <TransportRequest>[];
  final savedQuotes = <Quote>[];
  final watchedCompanyQuotes = <String>[];
  int _n = 0;

  @override
  String newId() => 'id${_n++}';

  @override
  Stream<List<Company>> watchCompanies() => companies.stream;

  @override
  Stream<List<TransportRequest>> watchRequests() => requests.stream;

  @override
  Stream<List<Quote>> watchQuotesForCustomer(String uid) => const Stream.empty();

  @override
  Stream<List<Quote>> watchQuotesForCompany(String companyId) {
    watchedCompanyQuotes.add(companyId);
    return const Stream.empty();
  }

  @override
  Future<void> saveRequest(TransportRequest request) async => savedRequests.add(request);

  @override
  Future<void> saveQuote(Quote quote) async => savedQuotes.add(quote);
}
