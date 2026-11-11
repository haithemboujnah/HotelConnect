// lib/models/complaint.dart

class Complaint {
  final String id;
  final String userEmail;
  final String subject;
  final String message;
  final String status; // 'En attente', 'Traitée'
  final DateTime date;

  Complaint({
    required this.id,
    required this.userEmail,
    required this.subject,
    required this.message,
    this.status = 'En attente',
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userEmail': userEmail,
    'subject': subject,
    'message': message,
    'status': status,
    'date': date.toIso8601String(),
  };

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    id: json['id'],
    userEmail: json['userEmail'],
    subject: json['subject'],
    message: json['message'],
    status: json['status'],
    date: DateTime.parse(json['date']),
  );
}