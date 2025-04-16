// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class OtpVerificationPage extends StatefulWidget {
//   final String matchId;
//   const OtpVerificationPage({required this.matchId, super.key});
//
//   @override
//   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// }
//
// class _OtpVerificationPageState extends State<OtpVerificationPage> {
//   final TextEditingController otpController = TextEditingController();
//   String? errorMessage;
//
//   Future<void> verifyOtp() async {
//     final enteredOtp = otpController.text.trim();
//     final user = FirebaseAuth.instance.currentUser;
//
//     final doc = await FirebaseFirestore.instance
//         .collection('RideMatches')
//         .doc(widget.matchId)
//         .get();
//
//     if (doc.exists) {
//       final data = doc.data()!;
//       final correctOtp = data['otp'];
//
//       if (enteredOtp == correctOtp) {
//         await FirebaseFirestore.instance
//             .collection('RideMatches')
//             .doc(widget.matchId)
//             .update({
//           'isOtpVerified': true,
//           'status': 'Verified',
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("OTP Verified! Ride confirmed.")),
//         );
//
//         Navigator.pop(context);
//       } else {
//         setState(() {
//           errorMessage = "Incorrect OTP. Please try again.";
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Verify Ride OTP"),
//         backgroundColor: Colors.green[700],
//         foregroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             const Text(
//               "Enter the OTP shared by your co-rider",
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "Enter OTP",
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: Colors.yellow[700],
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: verifyOtp,
//               child: const Text("Verify"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//             if (errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Text(errorMessage!,
//                     style: const TextStyle(color: Colors.red)),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
  bool isLoading = false;

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final enteredOtp = otpController.text.trim();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          errorMessage = "User not authenticated.";
          isLoading = false;
        });
        return;
      }

      final currentUserId = user.uid;
      final firestore = FirebaseFirestore.instance;

      // Get the match document
      final doc = await firestore
          .collection('RideMatches')
          .doc(widget.matchId)
          .get();

      if (!doc.exists) {
        setState(() {
          errorMessage = "Match not found.";
          isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      final correctOtp = data['otp'];
      final List<dynamic> userIds = data['userIds'] ?? [];
      final List<dynamic> requestStatuses = data['requestStatuses'] ?? [];

      // Check if the OTP is correct
      if (enteredOtp != correctOtp) {
        setState(() {
          errorMessage = "Incorrect OTP. Please try again.";
          isLoading = false;
        });
        return;
      }

      // Find the current user's index in the userIds array
      final int userIndex = userIds.indexOf(currentUserId);

      if (userIndex == -1 || userIndex >= requestStatuses.length) {
        setState(() {
          errorMessage = "User not found in this match.";
          isLoading = false;
        });
        return;
      }

      // Create a copy of the request statuses array to update the current user's status
      List<String> updatedRequestStatuses = List<String>.from(requestStatuses);
      updatedRequestStatuses[userIndex] = 'verified';

      // Check if this is the primary user (the first user in the array)
      final bool isPrimaryUser = userIndex == 0;

      // Check if all non-primary users have verified their OTPs
      bool allNonPrimaryUsersVerified = true;

      for (int i = 1; i < userIds.length; i++) {
        if (i < updatedRequestStatuses.length &&
            updatedRequestStatuses[i].toLowerCase() != 'verified') {
          allNonPrimaryUsersVerified = false;
          break;
        }
      }

      // Determine the new match status
      String newMatchStatus = data['status'] ?? 'matched';

      // If all non-primary users have verified their OTPs, update the match status to active
      if (allNonPrimaryUsersVerified) {
        newMatchStatus = 'active';
      }

      // Start a batch write to update everything atomically
      final batch = firestore.batch();

      // Update the match document
      final matchRef = firestore.collection('RideMatches').doc(widget.matchId);
      batch.update(matchRef, {
        'requestStatuses': updatedRequestStatuses,
        'isOtpVerified': allNonPrimaryUsersVerified,
        'status': newMatchStatus,
      });

      // Update the user's ride request status
      final List<dynamic> rideRequestIds = data['rideRequestIds'] ?? [];
      if (userIndex >= 0 && userIndex < rideRequestIds.length) {
        final String requestId = rideRequestIds[userIndex];
        final requestRef = firestore.collection('RideRequests').doc(requestId);
        batch.update(requestRef, {
          'status': 'verified',
        });
      }

      // Commit all updates
      await batch.commit();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(allNonPrimaryUsersVerified
              ? "OTP Verified! Ride is now active."
              : "OTP Verified! Waiting for others to verify."),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to previous screen
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        errorMessage = "Error verifying OTP: $e";
        isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the OTP shared by your co-rider",
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Enter OTP",
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.yellow[700],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text("Verify", style: TextStyle(fontSize: 16)),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}