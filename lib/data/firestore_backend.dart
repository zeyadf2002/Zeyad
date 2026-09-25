import 'package:cloud_firestore/cloud_firestore.dart';

import 'backend.dart';
import 'models.dart';

/// حفظ البيانات في Firestore. المجموعات: companies و requests و quotes.
class FirestoreBackend implements Backend {
  FirestoreBackend([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _companies => _db.collection('companies');
  CollectionReference<Map<String, dynamic>> get _requests => _db.collection('requests');
  CollectionReference<Map<String, dynamic>> get _quotes => _db.collection('quotes');
  CollectionReference<Map<String, dynamic>> get _ratings => _db.collection('ratings');

  @override
  String newId() => _requests.doc().id;

  @override
  Stream<List<Company>> watchCompanies() => _companies
      .where('verified', isEqualTo: true)
      .snapshots()
      .map((s) => [for (final d in s.docs) Company.fromMap(d.id, d.data())]);

  @override
  Stream<List<Company>> watchOwnedCompanies(String uid) => _companies
      .where('ownerUid', isEqualTo: uid)
      .snapshots()
      .map((s) => [for (final d in s.docs) Company.fromMap(d.id, d.data())]);

  @override
  Stream<List<Rating>> watchRatings() => _ratings
      .orderBy('createdAt', descending: true)
      .limit(500)
      .snapshots()
      .map((s) => [for (final d in s.docs) Rating.fromMap(d.id, d.data())]);

  @override
  Stream<List<TransportRequest>> watchRequests() => _requests
      .orderBy('createdAt', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => [for (final d in s.docs) TransportRequest.fromMap(d.id, d.data())]);

  @override
  Stream<List<Quote>> watchQuotesForCustomer(String uid) => _quotes
      .where('customerId', isEqualTo: uid)
      .snapshots()
      .map((s) => [for (final d in s.docs) Quote.fromMap(d.id, d.data())]);

  @override
  Stream<List<Quote>> watchQuotesForCompany(String companyId) => _quotes
      .where('companyId', isEqualTo: companyId)
      .snapshots()
      .map((s) => [for (final d in s.docs) Quote.fromMap(d.id, d.data())]);

  @override
  Future<void> saveRequest(TransportRequest request) =>
      _requests.doc(request.id).set(request.toMap());

  @override
  Future<void> saveQuote(Quote quote) => _quotes.doc(quote.id).set(quote.toMap());

  @override
  Future<void> saveCompany(Company company) => _companies.doc(company.id).set(company.toMap());

  @override
  Future<void> saveRating(Rating rating) => _ratings.doc(rating.requestId).set(rating.toMap());
}
