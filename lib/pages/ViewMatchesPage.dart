// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/CustomNavBar.dart';
// import '../components/customAppBar.dart';
//
// class ViewMatchesPage extends StatefulWidget {
//   const ViewMatchesPage({super.key});
//
//   @override
//   ViewMatchesPageState createState() => ViewMatchesPageState();
// }
//
// class ViewMatchesPageState extends State<ViewMatchesPage> {
//   final user = FirebaseAuth.instance.currentUser;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: const CustomAppBar(title: "Matched Rides"),
//       drawer: const CustomNavBar(),
//       body: Center(
//         child: Column(
//           children: [
//             Expanded(
//               child: StreamBuilder(
//                 stream: FirebaseFirestore.instance
//                     .collection('RideMatches')
//                     .where('userIds', arrayContains: user?.uid)
//                     .snapshots(),
//                 builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         "No matched rides found",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   }
//
//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) {
//                       var match = snapshot.data!.docs[index];
//
//                       String pickup = match['pickupLocation'].split(',')[0];
//                       String dropoff = match['dropoffLocation'].split(',')[0];
//                       String otherUserId = (match['userIds'] as List<dynamic>)
//                           .firstWhere((id) => id != user?.uid, orElse: () => 'Unknown');
//
//                       return Card(
//                         color: Colors.lightGreen[300],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "$pickup → $dropoff",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "Matched with: $otherUserId",
//                                 style: const TextStyle(
//                                   color: Colors.black87,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               /*Text(
//                                 "Time: ${match['preferredTime']}\nPassengers: ${match['numberOfPassengers']}",
//                                 style: const TextStyle(
//                                   color: Colors.black87,
//                                   fontSize: 14,
//                                 ),
//                               ),*/
//                               const SizedBox(height: 6),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 6,
//                                   horizontal: 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blueGrey,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   match['status'] ?? "Matched",
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/CustomNavBar.dart';
import '../components/customAppBar.dart';
import 'OtpVerificationPage.dart';

class ViewMatchesPage extends StatefulWidget {
  const ViewMatchesPage({super.key});

  @override
  ViewMatchesPageState createState() => ViewMatchesPageState();
}

class ViewMatchesPageState extends State<ViewMatchesPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "Matched Rides"),
      drawer: const CustomNavBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('RideMatches')
                    .where('userIds', arrayContains: user?.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.yellow));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matched rides found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var match = snapshot.data!.docs[index];
                      final data = match.data() as Map<String, dynamic>;

                      String pickup = data['pickupLocation'].split(',')[0];
                      String dropoff = data['dropoffLocation'].split(',')[0];
                      String otherUserId = (data['userIds'] as List<dynamic>)
                          .firstWhere((id) => id != user?.uid,
                              orElse: () => 'Unknown');

                      bool isPrimaryUser = data['userIds'][0] == user?.uid;
                      bool isOtpVerified = data['isOtpVerified'] ?? false;

                      return Card(
                        color: Colors.lightGreen[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          */
/*child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$pickup → $dropoff",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Matched with: $otherUserId",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!isOtpVerified) ...[
                                isPrimaryUser
                                    ? Text(
                                        "Share this OTP with co-rider: ${data['otp']}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  OtpVerificationPage(
                                                      matchId: match.id),
                                            ),
                                          );
                                        },
                                        child: const Text("Verify OTP"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isOtpVerified
                                      ? Colors.green
                                      : Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isOtpVerified
                                      ? "Verified"
                                      : (data['status'] ?? "Matched"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),*/
/*

                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$pickup → $dropoff",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Matched with: $otherUserId",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (!isOtpVerified) ...[
                                      isPrimaryUser
                                          ? Text(
                                        "Share this OTP with co-rider: ${data['otp']}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                          : ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  OtpVerificationPage(matchId: match.id),
                                            ),
                                          );
                                        },
                                        child: const Text("Verify OTP"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                        isOtpVerified ? Colors.green : Colors.blueGrey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isOtpVerified ? "Verified" : (data['status'] ?? "Matched"),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () async {
                                  final matchRef = FirebaseFirestore.instance
                                      .collection('RideMatches')
                                      .doc(match.id);

                                  // Remove user ID from the match
                                  List<dynamic> updatedUserIds =
                                  List.from(data['userIds'])..remove(user?.uid);

                                  String newStatus;
                                  if (updatedUserIds.isEmpty || updatedUserIds.length == 1) {
                                    newStatus = 'Canceled';
                                  } else {
                                    newStatus = 'Waiting';
                                  }

                                  await matchRef.update({
                                    'userIds': updatedUserIds,
                                    'status': newStatus,
                                  });

                                  // Optionally: show a snackbar or confirmation
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("You have canceled the match."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/CustomNavBar.dart';
import '../components/customAppBar.dart';
import 'OtpVerificationPage.dart';

class ViewMatchesPage extends StatefulWidget {
  const ViewMatchesPage({super.key});

  @override
  ViewMatchesPageState createState() => ViewMatchesPageState();
}

class ViewMatchesPageState extends State<ViewMatchesPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _cancelMatch(
      String matchId,
      String myRideRequestId,
      List<dynamic> allUserIds,
      List<dynamic> allRideRequestIds,
      List<dynamic> passengerGenders,
      List<dynamic> passengerGenderPreferences
      ) async
  {
    try {
      // Get the current user's ID
      final currentUserId = user?.uid;
      if (currentUserId == null) return;

      // Get the Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Start a batch to perform multiple operations atomically
      final batch = firestore.batch();

      // 1. Update the user's ride request status to "Canceled"
      final myRideRequestRef = firestore.collection('RideRequests').doc(myRideRequestId);
      batch.update(myRideRequestRef, {
        'status': 'Canceled',
        'matchId': null, // Remove match association
      });

      // 2. Remove user from the match
      final matchRef = firestore.collection('RideMatches').doc(matchId);
      final matchDoc = await matchRef.get();
      final matchData = matchDoc.data() as Map<String, dynamic>?;

      if (matchData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match data not found')),
        );
        return;
      }

      // Find the index of the current user in the userIds array
      final userIndex = allUserIds.indexOf(currentUserId);

      // Create copies of all arrays to be modified
      final remainingUserIds = List<String>.from(allUserIds)..removeAt(userIndex);
      final remainingRideRequestIds = List<String>.from(allRideRequestIds)..removeAt(userIndex);

      // Update gender and gender preference arrays
      final remainingPassengerGenders = List<String>.from(passengerGenders)..removeAt(userIndex);
      final remainingPassengerGenderPreferences =
      List<String>.from(passengerGenderPreferences)..removeAt(userIndex);

      // Get the current passenger count and max passenger value
      final int currentPassengerCount = matchData['currentPassengerCount'] ?? 0;
      final int maxPassengers = matchData['maxPassengerCount'] ?? 0;
      final int newPassengerCount = currentPassengerCount - 1;

      // Determine the new match status
      String newStatus;
      if (remainingUserIds.isEmpty || remainingUserIds.length == 1) {
        newStatus = 'Canceled';

        // If match is canceled, update the remaining ride request
        if (remainingUserIds.isNotEmpty && remainingRideRequestIds.isNotEmpty) {
          final remainingRequestRef = firestore.collection('RideRequests').doc(remainingRideRequestIds[0]);
          batch.update(remainingRequestRef, {
            'status': 'Pending',
            'matchId': null,
          });
        }
      } else if (newPassengerCount < maxPassengers) {
        newStatus = 'Waiting';
      } else {
        newStatus = 'Full';
      }

      // Recalculate gender preference for the match
      String matchGenderPreference = 'none';
      if (remainingPassengerGenderPreferences.isNotEmpty) {
        bool allSamePreference = true;
        final firstPref = remainingPassengerGenderPreferences[0];

        if (firstPref.toLowerCase() != 'any') {
          for (String pref in remainingPassengerGenderPreferences) {
            if (pref.toLowerCase() != firstPref.toLowerCase()) {
              allSamePreference = false;
              break;
            }
          }

          if (allSamePreference) {
            matchGenderPreference = firstPref;
          }
        }
      }

      // Update the match document
      batch.update(matchRef, {
        'userIds': remainingUserIds,
        'rideRequestIds': remainingRideRequestIds,
        'passengerGenders': remainingPassengerGenders,
        'passengerGenderPreferences': remainingPassengerGenderPreferences,
        'currentPassengerCount': newPassengerCount,
        'status': newStatus,
        'genderPreference': matchGenderPreference,
      });

      // Commit all the changes
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match canceled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling match: $e')),
      );
    }
  }

  // Find the ride request ID for the current user in a match
  Future<String?> _findMyRideRequestId(List<dynamic> userIds, List<dynamic> rideRequestIds) async
  {
    final currentUserId = user?.uid;
    if (currentUserId == null) return null;

    final userIndex = userIds.indexOf(currentUserId);
    if (userIndex >= 0 && userIndex < rideRequestIds.length) {
      return rideRequestIds[userIndex];
    }

    // Fallback: query Firestore if we can't find it in the arrays
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('RideRequests')
          .where('userId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'Matched')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print('Error finding ride request: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "Matched Rides"),
      drawer: const CustomNavBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('RideMatches')
                    .where('userIds', arrayContains: user?.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.yellow));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matched rides found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var match = snapshot.data!.docs[index];
                      final data = match.data() as Map<String, dynamic>;

                      String pickup = data['pickupLocation'].toString().split(',')[0];
                      String dropoff = data['dropoffLocation'].toString().split(',')[0];

                      List<dynamic> userIds = data['userIds'] ?? [];
                      List<dynamic> rideRequestIds = data['rideRequestIds'] ?? [];
                      List<dynamic> passengerGenders = data['passengerGenders'] ?? [];
                      List<dynamic> passengerGenderPreferences = data['passengerGenderPreferences'] ?? [];

                      String otherUserId = 'Unknown';
                      if (userIds.length > 1) {
                        otherUserId = userIds.firstWhere(
                                (id) => id != user?.uid,
                            orElse: () => 'Unknown'
                        );
                      }

                      bool isPrimaryUser = userIds.isNotEmpty && userIds[0] == user?.uid;
                      bool isOtpVerified = data['isOtpVerified'] ?? false;
                      bool isCanceled = data['status']?.toString().toLowerCase() == 'canceled';

                      return Card(
                        color: Colors.lightGreen[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "$pickup → $dropoff",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  // Cancel button
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Show a loading indicator
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(color: Colors.yellow),
                                        ),
                                      );

                                      // Confirm with user before cancellation
                                      Navigator.of(context).pop(); // Close loading indicator
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Cancel Ride Match'),
                                          content:  Text(isCanceled
                                              ? 'Are you sure you want to dismiss this match?'
                                              : 'Are you sure you want to cancel this ride match?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        // Show loading again
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator(color: Colors.yellow),
                                          ),
                                        );

                                        final myRideRequestId = await _findMyRideRequestId(
                                            userIds, rideRequestIds
                                        );

                                        if (myRideRequestId != null) {
                                          await _cancelMatch(
                                            match.id,
                                            myRideRequestId,
                                            userIds,
                                            rideRequestIds,
                                            passengerGenders,
                                            passengerGenderPreferences,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Could not find your ride request'),
                                            ),
                                          );
                                        }

                                        // Close loading indicator
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isCanceled ? Colors.blueGrey : Colors.red[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      minimumSize: const Size(80, 36),
                                    ),
                                    child: Text(isCanceled ? "Dismiss" : "Cancel"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Matched with: $otherUserId",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!isOtpVerified) ...[
                                isPrimaryUser
                                    ? Text(
                                  "Share this OTP with co-rider: ${data['otp']}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                    : ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OtpVerificationPage(
                                                matchId: match.id),
                                      ),
                                    );
                                  },
                                  child: const Text("Verify OTP"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isOtpVerified
                                      ? Colors.green
                                      : Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isOtpVerified
                                      ? "Verified"
                                      : (data['status'] ?? "Matched"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}