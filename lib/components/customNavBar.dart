import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

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
              leading: const Icon(Icons.add_circle, color: Colors.yellow),
              title: const Text(
                "Request a Ride",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/RideRequestPage'); // Adjust route
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.yellow),
              title: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/LoginPage'); // Adjust route
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list_outlined, color: Colors.yellow),
              title: const Text(
                "View Requests",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/ViewRequestsPage'); // Adjust route
              },
            ),
          ],
        ),
      ),
    );
  }
}
