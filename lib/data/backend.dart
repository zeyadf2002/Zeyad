import 'models.dart';

/// مصدر البيانات. في وضع التجربة لا يوجد مصدر وتبقى البيانات في الذاكرة،
/// وفي التشغيل الفعلي يكون Firestore.
abstract class Backend {
  String newId();
  /// الشركات الموثّقة فقط.
  Stream<List<Company>> watchCompanies();

  /// شركات المستخدم، الموثّقة وغير الموثّقة.
  Stream<List<Company>> watchOwnedCompanies(String uid);
  Stream<List<Rating>> watchRatings();
  Stream<List<TransportRequest>> watchRequests();
  Stream<List<Quote>> watchQuotesForCustomer(String uid);
  Stream<List<Quote>> watchQuotesForCompany(String companyId);
  Future<void> saveRequest(TransportRequest request);
  Future<void> saveQuote(Quote quote);
  Future<void> saveCompany(Company company);
  Future<void> saveRating(Rating rating);
}
