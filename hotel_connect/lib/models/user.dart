// lib/models/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final String password; // ⚠️ Simulation locale uniquement

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // Convertir l'objet en Map (pour le stockage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Reconstruire l'objet depuis une Map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}