// lib/data/mock_data.dart
import '../models/models.dart';

class MockData {
  // Liste des chambres
  static List<Room> rooms = [
    Room(id: '1', number: '101', type: 'Simple', pricePerNight: 80.0),
    Room(id: '2', number: '102', type: 'Double', pricePerNight: 120.0),
    Room(id: '3', number: '201', type: 'Suite', pricePerNight: 250.0),
  ];

  // Liste des services (Room Service & Activités)
  static List<ServiceItem> services = [
    // Room Service
    ServiceItem(id: 's1', name: 'Petit Déjeuner', price: 15.0, category: 'room_service'),
    ServiceItem(id: 's2', name: 'Dîner Gourmet', price: 45.0, category: 'room_service'),
    ServiceItem(id: 's3', name: 'Boissons Fraîches', price: 10.0, category: 'room_service'),
    ServiceItem(id: 's4', name: 'Ménage Express', price: 20.0, category: 'room_service'),
    // Activités
    ServiceItem(id: 'a1', name: 'Accès Spa', price: 30.0, category: 'activity', maxCapacity: 10),
    ServiceItem(id: 'a2', name: 'Excursion Medina', price: 50.0, category: 'activity', maxCapacity: 5),
    ServiceItem(id: 'a3', name: 'Cours de Yoga', price: 25.0, category: 'activity', maxCapacity: 8),
    ServiceItem(id: 'a4', name: 'Dîner Spectacle', price: 60.0, category: 'activity', maxCapacity: 20),
  ];

  // Facture actuelle du client (simulée)
  static Invoice currentInvoice = Invoice(
    id: 'INV-001',
    lines: [
      InvoiceLine(description: 'Réservation Chambre 101 (2 nuits)', amount: 160.0),
    ],
  );
}