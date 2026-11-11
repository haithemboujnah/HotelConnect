// lib/screens/invoice_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/reservation_service.dart';
import '../data/auth_service.dart';
import '../data/service_booking_service.dart';
import '../data/complaint_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F2027),
        appBar: AppBar(
          backgroundColor: const Color(0xFF203A43),
          title: Text(
            "Facture & Réclamations",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.receipt_long), text: "Facture"),
              Tab(icon: Icon(Icons.report_problem), text: "Réclamations"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInvoiceTab(),
            _buildComplaintsTab(),
          ],
        ),
      ),
    );
  }

  // --- ONGLET FACTURE ---
  Widget _buildInvoiceTab() {
    final email = AuthService.currentUser!.email;
    final reservations = ReservationService.getUserReservations(email);
    final services = ServiceBookingService.getUserBookings(email);
    final total = ServiceBookingService.getTotalInvoice(email);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF203A43), Color(0xFF2C5364)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text("Total à payer", style: GoogleFonts.poppins(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    "${total.toStringAsFixed(2)} DT",
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Chambres
          if (reservations.isNotEmpty) ...[
            Text("🏨 Chambres", style: GoogleFonts.poppins(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...reservations.map((r) => FadeInLeft(
              child: Card(
                color: const Color(0xFF203A43),
                child: ListTile(
                  title: Text("Chambre réservée", style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "${r.checkIn.day}/${r.checkIn.month} → ${r.checkOut.day}/${r.checkOut.month}",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    "${r.totalPrice.toStringAsFixed(0)} DT",
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],

          // Section Services
          if (services.isNotEmpty) ...[
            Text("🛎️ Services", style: GoogleFonts.poppins(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...services.map((s) => FadeInRight(
              child: Card(
                color: const Color(0xFF203A43),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(s.serviceName, style: TextStyle(color: Colors.white)),
                  trailing: Text(
                    "${s.price.toStringAsFixed(0)} DT",
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )),
          ],

          if (reservations.isEmpty && services.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text("Aucune dépense pour le moment.", style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- ONGLET RÉCLAMATIONS ---
  Widget _buildComplaintsTab() {
    final email = AuthService.currentUser!.email;
    final complaints = ComplaintService.getUserComplaints(email);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showComplaintDialog,
            icon: const Icon(Icons.add),
            label: const Text("Nouvelle réclamation"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: complaints.isEmpty
              ? Center(
            child: Text("Aucune réclamation.", style: TextStyle(color: Colors.white54)),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final c = complaints[index];
              return FadeInUp(
                child: Card(
                  color: const Color(0xFF203A43),
                  child: ListTile(
                    leading: Icon(Icons.report_problem, color: Colors.orange),
                    title: Text(c.subject, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(c.message, style: TextStyle(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.status == 'En attente' ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.status,
                        style: TextStyle(color: c.status == 'En attente' ? Colors.orange : Colors.green, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showComplaintDialog() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF203A43),
          title: Text("Nouvelle réclamation", style: TextStyle(color: Colors.amber)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Sujet",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  maxLength: 500,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Message",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  ),
                ),
                if (errorMessage != null)
                  Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final error = await ComplaintService.addComplaint(
                  userEmail: AuthService.currentUser!.email,
                  subject: subjectController.text,
                  message: messageController.text,
                );
                if (error != null) {
                  setStateDialog(() => errorMessage = error);
                } else {
                  Navigator.pop(context);
                  setState(() {}); // Rafraîchir la liste
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Réclamation envoyée."), backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text("Envoyer", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}