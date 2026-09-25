enum CarrierType { enclosed, open, flatbed }

extension CarrierTypeLabel on CarrierType {
  String get label => switch (this) {
        CarrierType.enclosed => 'مغلقة',
        CarrierType.open => 'مفتوحة',
        CarrierType.flatbed => 'سطحة',
      };
}

enum OrderStatus { open, booked, pickedUp, inTransit, delivered }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.open => 'بانتظار العروض',
        OrderStatus.booked => 'تم تأكيد الحجز',
        OrderStatus.pickedUp => 'تم استلام السيارة',
        OrderStatus.inTransit => 'في الطريق',
        OrderStatus.delivered => 'تم التسليم',
      };
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((v) => v.name == name, orElse: () => fallback);

DateTime _date(Object? millis) =>
    DateTime.fromMillisecondsSinceEpoch((millis as num?)?.toInt() ?? 0);

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.carrier,
    required this.cities,
    required this.rating,
    required this.reviewCount,
    this.verified = true,
    this.ownerUid,
  });

  final String id;
  final String name;
  final CarrierType carrier;
  final List<String> cities;
  final double rating;
  final int reviewCount;
  final bool verified;

  /// حساب صاحب الشركة، يفتح له "وضع الشركة".
  final String? ownerUid;

  String get initial => name.substring(0, 1);

  Company copyWith({double? rating, int? reviewCount}) => Company(
        id: id,
        name: name,
        carrier: carrier,
        cities: cities,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        verified: verified,
        ownerUid: ownerUid,
      );

  factory Company.fromMap(String id, Map<String, dynamic> m) => Company(
        id: id,
        name: m['name'] as String? ?? '',
        carrier: _enumByName(CarrierType.values, m['carrier'], CarrierType.open),
        cities: List<String>.from(m['cities'] as List? ?? const []),
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
        verified: m['verified'] as bool? ?? false,
        ownerUid: m['ownerUid'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'carrier': carrier.name,
        'cities': cities,
        'rating': rating,
        'reviewCount': reviewCount,
        'verified': verified,
        'ownerUid': ownerUid,
      };
}

class TransportRequest {
  TransportRequest({
    required this.id,
    required this.customerId,
    required this.from,
    required this.to,
    required this.car,
    required this.carrier,
    required this.pickupDate,
    required this.createdAt,
    this.status = OrderStatus.open,
    this.bookedQuoteId,
  });

  final String id;
  final String customerId;
  final String from;
  final String to;
  final String car;
  final CarrierType carrier;
  final DateTime pickupDate;
  final DateTime createdAt;
  OrderStatus status;
  String? bookedQuoteId;

  String get route => '$from ← $to';

  factory TransportRequest.fromMap(String id, Map<String, dynamic> m) => TransportRequest(
        id: id,
        customerId: m['customerId'] as String? ?? '',
        from: m['from'] as String? ?? '',
        to: m['to'] as String? ?? '',
        car: m['car'] as String? ?? '',
        carrier: _enumByName(CarrierType.values, m['carrier'], CarrierType.open),
        pickupDate: _date(m['pickupDate']),
        createdAt: _date(m['createdAt']),
        status: _enumByName(OrderStatus.values, m['status'], OrderStatus.open),
        bookedQuoteId: m['bookedQuoteId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'from': from,
        'to': to,
        'car': car,
        'carrier': carrier.name,
        'pickupDate': pickupDate.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'status': status.name,
        'bookedQuoteId': bookedQuoteId,
      };
}

class Quote {
  const Quote({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.companyId,
    required this.price,
    required this.days,
  });

  final String id;
  final String requestId;

  /// صاحب الطلب، حتى يقرأ العروض المرسلة له فقط.
  final String customerId;
  final String companyId;
  final int price;
  final int days;

  factory Quote.fromMap(String id, Map<String, dynamic> m) => Quote(
        id: id,
        requestId: m['requestId'] as String? ?? '',
        customerId: m['customerId'] as String? ?? '',
        companyId: m['companyId'] as String? ?? '',
        price: (m['price'] as num?)?.toInt() ?? 0,
        days: (m['days'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'customerId': customerId,
        'companyId': companyId,
        'price': price,
        'days': days,
      };
}

/// تقييم العميل للشركة بعد التسليم. معرّفه هو معرّف الطلب، فلكل طلب تقييم واحد.
class Rating {
  const Rating({
    required this.requestId,
    required this.companyId,
    required this.customerId,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  final String requestId;
  final String companyId;
  final String customerId;
  final int stars;
  final String comment;
  final DateTime createdAt;

  factory Rating.fromMap(String id, Map<String, dynamic> m) => Rating(
        requestId: id,
        companyId: m['companyId'] as String? ?? '',
        customerId: m['customerId'] as String? ?? '',
        stars: (m['stars'] as num?)?.toInt() ?? 0,
        comment: m['comment'] as String? ?? '',
        createdAt: _date(m['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'companyId': companyId,
        'customerId': customerId,
        'stars': stars,
        'comment': comment,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
