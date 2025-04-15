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
