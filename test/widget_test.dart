import 'package:flutter_test/flutter_test.dart';
import 'package:naql/data/app_state.dart';
import 'package:naql/data/models.dart';
import 'package:naql/main.dart';

void main() {
  testWidgets('الرئيسية تعرض الشركات وزر طلب العروض', (tester) async {
    await tester.pumpWidget(NaqlApp(state: AppState()));
    await tester.pumpAndSettle();
    expect(find.text('اطلب عروض أسعار'), findsOneWidget);
    expect(find.text('الناقل السريع'), findsOneWidget);
  });

  test('طلب جديد يستقبل عروضًا ثم يُحجز ويُسلّم', () {
    final state = AppState();
    final r = state.submitRequest(
      from: 'الرياض',
      to: 'جدة',
      car: 'كامري',
      carrier: CarrierType.enclosed,
      pickupDate: DateTime.now(),
    );
    expect(state.openRequestsForActiveCompany.map((x) => x.id), contains(r.id));
    state.sendQuote(requestId: r.id, price: 1000, days: 2);
    expect(state.quotesFor(r.id).length, 3);
    expect(state.openRequestsForActiveCompany.map((x) => x.id), isNot(contains(r.id)));

    final mine = state.quotesFor(r.id).firstWhere((q) => q.companyId == state.activeCompanyId);
    state.book(r, mine);
    expect(state.activeCompanyCommissionDue, 100);
    for (var i = 0; i < 3; i++) {
      state.advance(r);
    }
    expect(r.status, OrderStatus.delivered);
  });
}
