// lib/models/models.dart

class Room {
  final String id;
  final String number;
  final String type; // Simple, Double, Suite
  final double pricePerNight;
  bool isAvailable;

  Room({
    required this.id,
    required this.number,
    required this.type,
    required this.pricePerNight,
    this.isAvailable = true,
  });
}

class ServiceItem {
  final String id;
  final String name;
  final double price;
  final String category; // 'room_service' ou 'activity'
  final int maxCapacity; // Pour les activités
  int currentBookings;

  ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.maxCapacity = 0,
    this.currentBookings = 0,
  });

  bool get isAvailable => currentBookings < maxCapacity || maxCapacity == 0;
}

class InvoiceLine {
  final String description;
  final double amount;

  InvoiceLine({required this.description, required this.amount});
}

class Invoice {
  final String id;
  final List<InvoiceLine> lines;

  Invoice({required this.id, required this.lines});

  double get total => lines.fold(0.0, (sum, line) => sum + line.amount);
}