// lib/screens/rooms_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/reservation_service.dart';
import '../data/mock_data.dart';
import '../data/auth_service.dart';
import '../models/models.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.rooms.length,
        itemBuilder: (context, index) {
          final room = MockData.rooms[index];
          return FadeInUp(
            duration: Duration(milliseconds: 400 + (index * 200)),
            child: _buildRoomCard(room),
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF203A43),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chambre ${room.number}",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Icon(
                  room.type == 'Suite' ? Icons.king_bed : Icons.bed,
                  color: Colors.amber,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              room.type,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "${room.pricePerNight.toStringAsFixed(0)} DT / nuit",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showReservationDialog(room),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Réserver",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationDialog(Room room) async {
    final DateTime? checkIn = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: "Date d'arrivée",
    );
    if (checkIn == null) return;

    final DateTime? checkOut = await showDatePicker(
      context: context,
      initialDate: checkIn.add(const Duration(days: 1)),
      firstDate: checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: "Date de départ",
    );
    if (checkOut == null) return;

    // Appel à la logique métier
    final error = await ReservationService.createReservation(
      roomId: room.id,
      userEmail: AuthService.currentUser!.email,
      checkIn: checkIn,
      checkOut: checkOut,
      pricePerNight: room.pricePerNight,
    );

    if (!mounted) return;

    if (error != null) {
      // Cas négatif (M5)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      // Cas positif
      final nights = checkOut.difference(checkIn).inDays;
      final total = nights * room.pricePerNight;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Réservé ! Total : ${total.toStringAsFixed(0)} DT pour $nights nuit(s)."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}