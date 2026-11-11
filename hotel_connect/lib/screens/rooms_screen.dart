// lib/screens/rooms_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import '../data/auth_service.dart';
import '../data/reservation_service.dart';
import '../models/models.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  // 🆕 État du filtre
  String _selectedType = 'Tous';
  double _maxPrice = 300.0;

  final List<String> _types = ['Tous', 'Simple', 'Double', 'Suite'];

  // 🆕 Règle métier : filtrer la liste des chambres
  List<Room> get _filteredRooms {
    return MockData.rooms.where((room) {
      final matchType = _selectedType == 'Tous' || room.type == _selectedType;
      final matchPrice = room.pricePerNight <= _maxPrice;
      return matchType && matchPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _filteredRooms.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    "Aucune chambre ne correspond aux critères.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRooms.length,
              itemBuilder: (context, index) {
                final room = _filteredRooms[index];
                return FadeInUp(
                  key: ValueKey('${room.id}_$_selectedType$_maxPrice'),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  child: _buildRoomCard(room),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 Section des filtres
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: const Color(0xFF203A43),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtre par type
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _types.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: Colors.amber,
                    backgroundColor: Colors.white10,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Filtre par prix
          Row(
            children: [
              Text(
                "Prix max : ${_maxPrice.toStringAsFixed(0)} DT",
                style: GoogleFonts.poppins(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Slider(
                  value: _maxPrice,
                  min: 50,
                  max: 300,
                  divisions: 5,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.white24,
                  label: "${_maxPrice.toStringAsFixed(0)} DT",
                  onChanged: (value) => setState(() => _maxPrice = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    // ... (garder exactement le même code qu'avant)
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
    // ... (garder exactement le même code qu'avant)
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

    final error = await ReservationService.createReservation(
      roomId: room.id,
      userEmail: AuthService.currentUser!.email,
      checkIn: checkIn,
      checkOut: checkOut,
      pricePerNight: room.pricePerNight,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
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