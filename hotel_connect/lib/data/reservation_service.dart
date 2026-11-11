// lib/data/reservation_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/reservation.dart';

class ReservationService {
  static const String _reservationsKey = 'reservations_list';
  static List<Reservation> _reservations = [];

  static List<Reservation> get allReservations => _reservations;

  // Charger les réservations depuis le stockage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_reservationsKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _reservations = decoded.map((json) => Reservation.fromJson(json)).toList();
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_reservations.map((r) => r.toJson()).toList());
    await prefs.setString(_reservationsKey, encoded);
  }

  // 🧠 RÈGLE MÉTIER : Vérifier si une chambre est disponible sur une période
  static bool isRoomAvailable(String roomId, DateTime checkIn, DateTime checkOut) {
    for (var res in _reservations) {
      if (res.roomId == roomId) {
        // Chevauchement de dates ?
        // Une réservation est en conflit si : (nouveau début < ancienne fin) ET (nouvelle fin > ancien début)
        if (checkIn.isBefore(res.checkOut) && checkOut.isAfter(res.checkIn)) {
          return false;
        }
      }
    }
    return true;
  }

  // Créer une réservation avec validation
  static Future<String?> createReservation({
    required String roomId,
    required String userEmail,
    required DateTime checkIn,
    required DateTime checkOut,
    required double pricePerNight,
  }) async {
    // Validation 1 : date de départ après arrivée
    if (!checkOut.isAfter(checkIn)) {
      return "La date de départ doit être après la date d'arrivée.";
    }

    // Validation 2 : pas dans le passé
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (checkIn.isBefore(todayDate)) {
      return "La date d'arrivée ne peut pas être dans le passé.";
    }

    // Validation 3 : disponibilité
    if (!isRoomAvailable(roomId, checkIn, checkOut)) {
      return "Cette chambre est déjà réservée sur ces dates.";
    }

    // Calcul du prix
    final nights = checkOut.difference(checkIn).inDays;
    final total = nights * pricePerNight;

    final newRes = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      userEmail: userEmail,
      checkIn: checkIn,
      checkOut: checkOut,
      totalPrice: total,
    );

    _reservations.add(newRes);
    await _save();
    return null; // Succès
  }

  // Récupérer les réservations d'un utilisateur
  static List<Reservation> getUserReservations(String email) {
    return _reservations.where((r) => r.userEmail == email).toList();
  }

  static bool canCancelReservation(Reservation res) {
    // Impossible d'annuler si le séjour a déjà commencé
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return res.checkIn.isAfter(todayDate);
  }

  // 🆕 Annuler une réservation avec validation
  static Future<String?> cancelReservation(String reservationId) async {
    final index = _reservations.indexWhere((r) => r.id == reservationId);

    if (index == -1) {
      return "Réservation introuvable.";
    }

    final res = _reservations[index];

    // Validation : le séjour ne doit pas avoir commencé
    if (!canCancelReservation(res)) {
      return "Impossible d'annuler : le séjour a déjà commencé.";
    }

    _reservations.removeAt(index);
    await _save();
    return null; // Succès
  }
}