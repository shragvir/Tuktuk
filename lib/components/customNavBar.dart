import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});
  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('UserRegistration').doc(user.uid).get();
      return userDoc.data()?['name'] ?? 'User';
    }
    return 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF222222)], // Subtle dark gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String>(
              future: getUserName(),
              builder: (context, snapshot) {
                return SizedBox(
                  height: 120,
                  child: DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.green[700]),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        snapshot.connectionState == ConnectionState.waiting
                            ? 'Loading...'
                            : 'Hello, ${snapshot.data}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 100,// Set fixed height
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green[700]),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Menu",
                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.yellowAccent),
              title: const Text(
                "Request a Ride",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/RideRequestPage'); // Adjust route
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.yellowAccent),
              title: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/LoginPage'); // Adjust route
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list_outlined, color: Colors.yellowAccent),
              title: const Text(
                "View Requests",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/ViewRequestsPage'); // Adjust route
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined, color: Colors.yellowAccent),
              title: const Text(
                "View Matches",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/ViewMatchesPage'); // Adjust route
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.yellowAccent),
              title: const Text(
                "Admin Dashboard",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/AdminPage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list_outlined, color: Colors.yellowAccent),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/ProfilePage'); // Adjust route
              },
            ),
          ],
        ),
      ),
    );
  }
}

