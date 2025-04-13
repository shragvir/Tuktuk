import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuktuk/pages/HomePage.dart';
import 'package:tuktuk/pages/RideRequestPage.dart';
import 'package:tuktuk/pages/SignUpPage.dart';

class FlashPage extends StatefulWidget {
  const FlashPage({super.key});

  @override
  State<FlashPage> createState() => _FlashPageState();
}

class _FlashPageState extends State<FlashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RideRequestPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/images/rickshaw.png',
              //   width: 200,
              //   height: 200,
              //   fit: BoxFit.cover,
              // ).animate().slideX(begin: -1, end: 0, duration: 1500.ms),
              Image.asset(
                'assets/images/rickshaw.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                color: Colors.transparent,
                colorBlendMode: BlendMode.multiply, // Makes white parts transparent
              ).animate().slideX(begin: -1, end: 0, duration: 1500.ms),

              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFFEFD339), Color(0xFF56D239)],
                  ).createShader(bounds);
                },
                child: const Text(
                  'TUK TUK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ).animate().scale(begin: Offset(0, 0), end: Offset(1, 1), duration: 720.ms),
            ],
          ),
        ),
      ),
    );
  }
}


