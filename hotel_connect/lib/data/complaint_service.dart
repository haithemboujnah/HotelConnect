// lib/data/complaint_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint.dart';

class ComplaintService {
  static const String _complaintsKey = 'complaints_list';
  static List<Complaint> _complaints = [];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_complaintsKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _complaints = decoded.map((json) => Complaint.fromJson(json)).toList();
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_complaints.map((c) => c.toJson()).toList());
    await prefs.setString(_complaintsKey, encoded);
  }

  // Ajouter une réclamation avec validation
  static Future<String?> addComplaint({
    required String userEmail,
    required String subject,
    required String message,
  }) async {
    // Validation 1 : champs vides
    if (subject.trim().isEmpty || message.trim().isEmpty) {
      return "Le sujet et le message sont obligatoires.";
    }

    // Validation 2 : longueur minimale du message
    if (message.trim().length < 10) {
      return "Le message doit contenir au moins 10 caractères.";
    }

    // Validation 3 : longueur maximale (protection)
    if (message.length > 500) {
      return "Le message ne peut pas dépasser 500 caractères.";
    }

    final newComplaint = Complaint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userEmail: userEmail,
      subject: subject.trim(),
      message: message.trim(),
      date: DateTime.now(),
    );

    _complaints.add(newComplaint);
    await _save();
    return null;
  }

  static List<Complaint> getUserComplaints(String email) {
    return _complaints.where((c) => c.userEmail == email).toList();
  }
}