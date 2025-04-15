import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  // Show the popup with scale and fade effect and blurred background
  void showStatDialog(BuildContext context, String label, int value, IconData icon) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'StatDialog',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // blur effect
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEFD339), Color(0xFF56D239)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 90, color: Colors.black),
                    const SizedBox(height: 40),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$value",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  // Build tile for each stat
  Widget buildStatCardTile(BuildContext context, String label, IconData icon, Future<int> futureCount) {
    return FutureBuilder<int>(
      future: futureCount,
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            int count = snapshot.data ?? 0;
            showStatDialog(context, label, count, icon);
          },
          child: Card(
            elevation: 5,  // Adding elevation for a shadow effect
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFD339), Color(0xFF56D239)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16), // Rounded corners for the card
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.black),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fetch count from Firestore
  Future<int> fetchCount(CollectionReference collection, {String? statusFilter}) async {
    Query query = collection;
    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }
    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/LoginPage');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome tile with same height as other tiles
            Container(
              height: 180, // Set the height to match the other tiles
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFD339), Color(0xFF56D239)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              child: const Center(
                child: Text(
                  "Welcome, Admin!",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Grid of stat tiles
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.9,
                children: [
                  buildStatCardTile(
                    context,
                    "Total Registered Users",
                    Icons.people,
                    fetchCount(firestore.collection('UserRegistration')),
                  ),
                  buildStatCardTile(
                    context,
                    "Pending Ride Requests",
                    Icons.pending,
                    fetchCount(firestore.collection('RideRequests'), statusFilter: 'Pending'),
                  ),
                  buildStatCardTile(
                    context,
                    "Accepted Ride Requests",
                    Icons.handshake,
                    fetchCount(firestore.collection('RideRequests'), statusFilter: 'Accepted'),
                  ),
                  buildStatCardTile(
                    context,
                    "Completed Ride Requests",
                    Icons.done_all_sharp,
                    fetchCount(firestore.collection('RideRequests'), statusFilter: 'Completed'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
