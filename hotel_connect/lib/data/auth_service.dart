// lib/data/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users_list';
  static const String _sessionKey = 'current_user_email';

  static List<User> _users = [];
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  // --- INITIALISATION : Charger les données au démarrage ---
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Charger tous les utilisateurs sauvegardés
    final String? usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> decoded = jsonDecode(usersJson);
      _users = decoded.map((json) => User.fromJson(json)).toList();
    } else {
      // Utilisateur de test par défaut si la base est vide
      _users = [
        User(id: '1', name: 'Test Client', email: 'test@hotel.com', password: '123456'),
      ];
      await _saveUsersToPrefs();
    }

    // 2. Restaurer la session (si l'utilisateur était connecté)
    final String? email = prefs.getString(_sessionKey);
    if (email != null) {
      try {
        _currentUser = _users.firstWhere((u) => u.email == email);
      } catch (e) {
        _currentUser = null; // L'utilisateur a été supprimé
      }
    }
  }

  // Sauvegarde interne de la liste des utilisateurs
  static Future<void> _saveUsersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  // --- INSCRIPTION ---
  static Future<String?> signUp(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return "Veuillez remplir tous les champs.";
    }
    if (_users.any((u) => u.email == email)) {
      return "Cet email est déjà utilisé.";
    }
    if (!email.contains('@') || !email.contains('.')) {
      return "Format d'email invalide.";
    }
    if (password.length < 6) {
      return "Le mot de passe doit contenir au moins 6 caractères.";
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );

    _users.add(newUser);
    await _saveUsersToPrefs(); // Sauvegarde persistante
    return null;
  }

  // --- CONNEXION ---
  static Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Veuillez remplir tous les champs.";
    }

    try {
      final user = _users.firstWhere(
            (u) => u.email == email && u.password == password,
      );

      _currentUser = user;

      // Sauvegarder la session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, user.email);

      return null;
    } catch (e) {
      return "Email ou mot de passe incorrect.";
    }
  }

  // --- DÉCONNEXION ---
  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey); // Supprimer la session
  }
}