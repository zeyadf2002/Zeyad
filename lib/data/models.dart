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

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.carrier,
    required this.cities,
    required this.rating,
    required this.reviewCount,
    this.verified = true,
  });

  final String id;
  final String name;
  final CarrierType carrier;
  final List<String> cities;
  final double rating;
  final int reviewCount;
  final bool verified;

  String get initial => name.substring(0, 1);
}

class TransportRequest {
  TransportRequest({
    required this.id,
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
  final String from;
  final String to;
  final String car;
  final CarrierType carrier;
  final DateTime pickupDate;
  final DateTime createdAt;
  OrderStatus status;
  String? bookedQuoteId;

  String get route => '$from ← $to';
}

class Quote {
  const Quote({
    required this.id,
    required this.requestId,
    required this.companyId,
    required this.price,
    required this.days,
  });

  final String id;
  final String requestId;
  final String companyId;
  final int price;
  final int days;
}
