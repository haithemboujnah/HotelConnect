// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_connect/screens/rooms_screen.dart';
import 'package:hotel_connect/screens/services_screen.dart';
import '../data/auth_service.dart';
import 'invoice_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Les 3 vues (M2)
  final List<Widget> _screens = [
    const RoomsScreen(),
    const ServicesScreen(),
    const InvoiceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Fond sombre cohérent
      appBar: AppBar(
        backgroundColor: const Color(0xFF203A43),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bonjour, ${user?.name ?? 'Client'}",
              style: GoogleFonts.aBeeZee(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 18),
            ),
            Text(
              "Bienvenue à l'Hôtel Sahara Beach",
              style: GoogleFonts.aBeeZee(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.amber),
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
      body: FadeIn(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF203A43),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Chambres'),
          BottomNavigationBarItem(icon: Icon(Icons.room_service), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Facture'),
        ],
      ),
    );
  }
}