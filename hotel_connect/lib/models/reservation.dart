// lib/models/reservation.dart

class Reservation {
  final String id;
  final String roomId;
  final String userEmail;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;

  Reservation({
    required this.id,
    required this.roomId,
    required this.userEmail,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'userEmail': userEmail,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'totalPrice': totalPrice,
  };

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
    id: json['id'],
    roomId: json['roomId'],
    userEmail: json['userEmail'],
    checkIn: DateTime.parse(json['checkIn']),
    checkOut: DateTime.parse(json['checkOut']),
    totalPrice: (json['totalPrice'] as num).toDouble(),
  );
}