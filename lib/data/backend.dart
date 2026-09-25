import 'models.dart';

/// مصدر البيانات. في وضع التجربة لا يوجد مصدر وتبقى البيانات في الذاكرة،
/// وفي التشغيل الفعلي يكون Firestore.
abstract class Backend {
  String newId();
  Stream<List<Company>> watchCompanies();
  Stream<List<TransportRequest>> watchRequests();
  Stream<List<Quote>> watchQuotesForCustomer(String uid);
  Stream<List<Quote>> watchQuotesForCompany(String companyId);
  Future<void> saveRequest(TransportRequest request);
  Future<void> saveQuote(Quote quote);
}
