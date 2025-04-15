import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/CustomNavBar.dart';
import '../components/customAppBar.dart';

class ViewRequestsPage extends StatefulWidget {
  const ViewRequestsPage({super.key});

  @override
  ViewRequestsPageState createState() => ViewRequestsPageState();
}

class ViewRequestsPageState extends State<ViewRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "View Ride Requests"),
      drawer: const CustomNavBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('RideRequests').where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid).orderBy('createdAt', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // Add debug print
                print("Connection state: ${snapshot.connectionState}");
                print("Has data: ${snapshot.hasData}");
                print("Data empty: ${snapshot.hasData ? snapshot.data!.docs.isEmpty : 'N/A'}");

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    "No ride requests found",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  );
                }
                // Add debug print
                print("Number of docs: ${snapshot.data!.docs.length}");

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var request = snapshot.data!.docs[index];
                    return Card(
                      color: request['status'] == 'Pending' ? Color(0xFFFFF44F)
                          : Colors.lightGreenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // "${request['pickupLocation']} → ${request['dropoffLocation']}",
                                    "${request['pickupLocation'].split(',')[0]} → ${request['dropoffLocation'].split(',')[0]}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Time: ${request['preferredTime']}\nPassengers: ${request['numberOfPassengers']}",
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                color: request['status'] == 'Pending' ? Colors.orange : Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                request['status'],
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
