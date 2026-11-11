// lib/screens/services_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import '../data/auth_service.dart';
import '../data/service_booking_service.dart';
import '../models/models.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F2027),
        appBar: AppBar(
          backgroundColor: const Color(0xFF203A43),
          title: Text(
            "Services de l'Hôtel",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.room_service), text: "Room Service"),
              Tab(icon: Icon(Icons.event), text: "Activités"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildServiceList('room_service'),
            _buildServiceList('activity'),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList(String category) {
    final services = MockData.services.where((s) => s.category == category).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 150)),
          child: _buildServiceCard(service),
        );
      },
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    final isActivity = service.category == 'activity';
    final isAvailable = isActivity ? ServiceBookingService.hasAvailableSpots(service) : true;
    final remaining = ServiceBookingService.getRemainingSpots(service);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF203A43),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isAvailable ? Colors.amber : Colors.grey,
          child: Icon(
            isActivity ? Icons.event_available : Icons.restaurant,
            color: Colors.black,
          ),
        ),
        title: Text(
          service.name,
          style: GoogleFonts.poppins(
            color: isAvailable ? Colors.white : Colors.white38,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "${service.price.toStringAsFixed(0)} DT"
              "${isActivity ? ' • $remaining places restantes' : ''}",
          style: TextStyle(color: isAvailable ? Colors.amber : Colors.grey),
        ),
        trailing: ElevatedButton(
          onPressed: isAvailable ? () => _handleBooking(service) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isAvailable ? Colors.amber : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            isAvailable ? "Réserver" : "Complet",
            style: TextStyle(
              color: isAvailable ? Colors.black : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _handleBooking(ServiceItem service) async {
    final error = await ServiceBookingService.bookService(
      service: service,
      userEmail: AuthService.currentUser!.email,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ ${service.name} ajouté à votre facture (+${service.price} DT)"),
          backgroundColor: Colors.green,
        ),
      );
      // Rafraîchir l'UI pour mettre à jour les places restantes
      setState(() {});
    }
  }
}