import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpVerificationPage extends StatefulWidget {
  final String matchId;
  const OtpVerificationPage({required this.matchId, super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  String? errorMessage;

  Future<void> verifyOtp() async {
    final enteredOtp = otpController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection('RideMatches')
        .doc(widget.matchId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final correctOtp = data['otp'];

      if (enteredOtp == correctOtp) {
        await FirebaseFirestore.instance
            .collection('RideMatches')
            .doc(widget.matchId)
            .update({
          'isOtpVerified': true,
          'status': 'Verified',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Verified! Ride confirmed.")),
        );

        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = "Incorrect OTP. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Ride OTP"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Enter the OTP shared by your co-rider",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter OTP",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.yellow[700],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOtp,
              child: const Text("Verify"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
