// lib/models/service_booking.dart

class ServiceBooking {
  final String id;
  final String serviceId;
  final String serviceName;
  final double price;
  final String userEmail;
  final DateTime date;

  ServiceBooking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.userEmail,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'price': price,
    'userEmail': userEmail,
    'date': date.toIso8601String(),
  };

  factory ServiceBooking.fromJson(Map<String, dynamic> json) => ServiceBooking(
    id: json['id'],
    serviceId: json['serviceId'],
    serviceName: json['serviceName'],
    price: (json['price'] as num).toDouble(),
    userEmail: json['userEmail'],
    date: DateTime.parse(json['date']),
  );
}