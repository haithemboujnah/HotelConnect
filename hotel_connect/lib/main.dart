// lib/main.dart
import 'package:flutter/material.dart';
import 'data/reservation_service.dart';
import 'data/auth_service.dart';
import 'data/complaint_service.dart';
import 'data/service_booking_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  await ReservationService.init();
  await ServiceBookingService.init();
  await ComplaintService.init();
  runApp(const HotelConnectApp());
}

class HotelConnectApp extends StatelessWidget {
  const HotelConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HotelConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        primaryColor: Colors.amber,
      ),
      // 🔀 Si un utilisateur est déjà connecté (session restaurée), on va direct au Home
      home: AuthService.currentUser != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}