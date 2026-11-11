// lib/data/service_booking_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_booking.dart';
import '../models/models.dart';
import 'reservation_service.dart';

class ServiceBookingService {
  static const String _bookingsKey = 'service_bookings_list';
  static List<ServiceBooking> _bookings = [];

  // Compteur de places par activité (simulation, stocké en mémoire pour la session)
  static Map<String, int> _activityCounters = {};

  static List<ServiceBooking> get allBookings => _bookings;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_bookingsKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _bookings = decoded.map((json) => ServiceBooking.fromJson(json)).toList();

      // Recalculer les compteurs d'activités à partir des réservations existantes
      _activityCounters.clear();
      for (var b in _bookings) {
        _activityCounters[b.serviceId] = (_activityCounters[b.serviceId] ?? 0) + 1;
      }
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_bookings.map((b) => b.toJson()).toList());
    await prefs.setString(_bookingsKey, encoded);
  }

  // Vérifier si une activité a encore des places
  static bool hasAvailableSpots(ServiceItem service) {
    if (service.category != 'activity') return true;
    final currentBookings = _activityCounters[service.id] ?? 0;
    return currentBookings < service.maxCapacity;
  }

  static int getRemainingSpots(ServiceItem service) {
    if (service.category != 'activity') return -1; // Non applicable
    final currentBookings = _activityCounters[service.id] ?? 0;
    return service.maxCapacity - currentBookings;
  }

  // Ajouter un service (règle métier + validations)
  static Future<String?> bookService({
    required ServiceItem service,
    required String userEmail,
  }) async {
    // Validation 1 : places disponibles pour les activités
    if (!hasAvailableSpots(service)) {
      return "Plus de places disponibles pour cette activité.";
    }

    // Validation 2 : (optionnel) éviter les doublons pour les activités
    if (service.category == 'activity') {
      final alreadyBooked = _bookings.any(
            (b) => b.serviceId == service.id && b.userEmail == userEmail,
      );
      if (alreadyBooked) {
        return "Vous avez déjà réservé cette activité.";
      }
    }

    final newBooking = ServiceBooking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceId: service.id,
      serviceName: service.name,
      price: service.price,
      userEmail: userEmail,
      date: DateTime.now(),
    );

    _bookings.add(newBooking);

    // Mettre à jour le compteur pour les activités
    if (service.category == 'activity') {
      _activityCounters[service.id] = (_activityCounters[service.id] ?? 0) + 1;
    }

    await _save();
    return null; // Succès
  }

  // Calculer le total des services d'un utilisateur
  static double getUserServicesTotal(String email) {
    return _bookings
        .where((b) => b.userEmail == email)
        .fold(0.0, (sum, b) => sum + b.price);
  }

  // Récupérer les réservations d'un utilisateur
  static List<ServiceBooking> getUserBookings(String email) {
    return _bookings.where((b) => b.userEmail == email).toList();
  }

  // Calculer la facture complète d'un utilisateur (chambres + services)
  static double getTotalInvoice(String email) {
    final roomsTotal = ReservationService.getUserReservations(email)
        .fold(0.0, (sum, r) => sum + r.totalPrice);
    final servicesTotal = getUserServicesTotal(email);
    return roomsTotal + servicesTotal;
  }
}