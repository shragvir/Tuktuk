// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
//
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
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _userRequests = [];
//   Map<String, List<Map<String, dynamic>>> _matchesByRequest = {};
//   String? _selectedRequestId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserRequests();
//   }
//
//   Future<void> _loadUserRequests() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You must be logged in to view matches')),
//         );
//         Navigator.pushNamed(context, '/LoginPage');
//         return;
//       }
//
//       // Get current user's ride requests
//       QuerySnapshot requestsQuery = await FirebaseFirestore.instance
//           .collection('RideRequests')
//           .where('userId', isEqualTo: user.uid)
//           .where('status', isEqualTo: 'Pending')
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       List<Map<String, dynamic>> requests = [];
//       for (var doc in requestsQuery.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         requests.add({
//           'id': doc.id,
//           ...data,
//         });
//       }
//
//       if (mounted) {
//         setState(() {
//           _userRequests = requests;
//           if (requests.isNotEmpty) {
//             _selectedRequestId = requests[0]['id'];
//             _findMatchesForRequest(requests[0]['id']);
//           } else {
//             _isLoading = false;
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading requests: $e')),
//         );
//       }
//     }
//   }
//
//   Future<void> _findMatchesForRequest(String requestId) async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // First check if we already cached matches for this request
//       if (_matchesByRequest.containsKey(requestId)) {
//         setState(() {
//           _selectedRequestId = requestId;
//           _isLoading = false;
//         });
//         return;
//       }
//
//       // Get the original request
//       DocumentSnapshot request = await FirebaseFirestore.instance
//           .collection('RideRequests')
//           .doc(requestId)
//           .get();
//
//       if (!request.exists) {
//         throw Exception('Request not found');
//       }
//
//       Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;
//
//       // Parameters for matching
//       GeoPoint pickupCoords = requestData['pickupCoordinates'];
//       GeoPoint dropoffCoords = requestData['dropoffCoordinates'];
//       String prefTime = requestData['preferredTime'];
//       String genderPref = requestData['genderPreference'];
//       int passengers = requestData['numberOfPassengers'];
//
//       // Query other ride requests
//       QuerySnapshot potentialMatches = await FirebaseFirestore.instance
//           .collection('RideRequests')
//           .where('status', isEqualTo: 'Pending')
//           .where('userId', isNotEqualTo: requestData['userId']) // Don't match with self
//           .get();
//
//       List<Map<String, dynamic>> matches = [];
//
//       for (var doc in potentialMatches.docs) {
//         Map<String, dynamic> matchData = doc.data() as Map<String, dynamic>;
//
//         // Skip if gender preference doesn't match
//         if (genderPref != "Any" && matchData['genderPreference'] != "Any" &&
//             genderPref != matchData['genderPreference']) {
//           continue;
//         }
//
//         // Calculate distances
//         double pickupDistance = Geolocator.distanceBetween(
//           pickupCoords.latitude,
//           pickupCoords.longitude,
//           matchData['pickupCoordinates'].latitude,
//           matchData['pickupCoordinates'].longitude,
//         );
//
//         double dropoffDistance = Geolocator.distanceBetween(
//           dropoffCoords.latitude,
//           dropoffCoords.longitude,
//           matchData['dropoffCoordinates'].latitude,
//           matchData['dropoffCoordinates'].longitude,
//         );
//
//         // Parse time strings to calculate difference
//         int timeDiff = _calculateTimeDifference(prefTime, matchData['preferredTime']);
//
//         // Check if total passengers exceed limit
//         int totalPassengers = passengers + (matchData['numberOfPassengers'] as int);
//         if (totalPassengers > 5) {
//           continue;
//         }
//
//         // Calculate match score
//         int matchScore = _calculateMatchScore(
//           pickupDistance,
//           dropoffDistance,
//           timeDiff,
//         );
//
//         // Add to matches if score is above threshold
//         if (matchScore >= 60) {
//           matches.add({
//             'id': doc.id,
//             ...matchData,
//             'pickupDistance': pickupDistance,
//             'dropoffDistance': dropoffDistance,
//             'timeDifference': timeDiff,
//             'matchScore': matchScore,
//           });
//         }
//       }
//
//       // Sort by match score (highest first)
//       matches.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));
//
//       // Save matches to cache
//       _matchesByRequest[requestId] = matches;
//
//       if (mounted) {
//         setState(() {
//           _selectedRequestId = requestId;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error finding matches: $e");
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error finding matches: $e')),
//         );
//       }
//     }
//   }
//
//   int _calculateTimeDifference(String time1, String time2) {
//     // Parse time strings in 24-hour format (e.g., "14:30")
//     List<String> parts1 = time1.split(':');
//     List<String> parts2 = time2.split(':');
//
//     if (parts1.length < 2 || parts2.length < 2) {
//       return 1440; // Return 24 hours (in minutes) if format is invalid
//     }
//
//     try {
//       int hour1 = int.parse(parts1[0]);
//       int minute1 = int.parse(parts1[1]);
//       int hour2 = int.parse(parts2[0]);
//       int minute2 = int.parse(parts2[1]);
//
//       int totalMinutes1 = hour1 * 60 + minute1;
//       int totalMinutes2 = hour2 * 60 + minute2;
//
//       return (totalMinutes1 - totalMinutes2).abs();
//     } catch (e) {
//       return 1440; // Default to 24 hours on error
//     }
//   }
//
//   int _calculateMatchScore(double pickupDist, double dropoffDist, int timeDiff) {
//     // Base score
//     int score = 100;
//
//     // Deduct points for pickup distance (max deduction: 30 points)
//     if (pickupDist > 2000) { // More than 2km
//       score -= 30;
//     } else if (pickupDist > 1000) { // More than 1km
//       score -= 15;
//     } else if (pickupDist > 500) { // More than 500m
//       score -= 5;
//     }
//
//     // Deduct points for dropoff distance (max deduction: 20 points)
//     if (dropoffDist > 3000) { // More than 3km
//       score -= 20;
//     } else if (dropoffDist > 1500) { // More than 1.5km
//       score -= 10;
//     } else if (dropoffDist > 1000) { // More than 1km
//       score -= 5;
//     }
//
//     // Deduct points for time difference (max deduction: 40 points)
//     if (timeDiff > 30) { // More than 30 minutes
//       score -= 40;
//     } else if (timeDiff > 15) { // More than 15 minutes
//       score -= 20;
//     } else if (timeDiff > 5) { // More than 5 minutes
//       score -= 10;
//     }
//
//     return score < 0 ? 0 : score;
//   }
//
//   Future<void> _acceptMatch(String matchedRequestId) async {
//     if (_selectedRequestId == null) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception('User not logged in');
//       }
//
//       // Get details of both requests
//       DocumentSnapshot originalRequest = await FirebaseFirestore.instance
//           .collection('RideRequests')
//           .doc(_selectedRequestId)
//           .get();
//
//       DocumentSnapshot matchedRequest = await FirebaseFirestore.instance
//           .collection('RideRequests')
//           .doc(matchedRequestId)
//           .get();
//
//       if (!originalRequest.exists || !matchedRequest.exists) {
//         throw Exception('One or both requests no longer exist');
//       }
//
//       Map<String, dynamic> originalData = originalRequest.data() as Map<String, dynamic>;
//       Map<String, dynamic> matchedData = matchedRequest.data() as Map<String, dynamic>;
//
//       // Create a new match document
//       DocumentReference matchRef = await FirebaseFirestore.instance.collection('matches').add({
//         'requestId': _selectedRequestId,
//         'matchedRequestId': matchedRequestId,
//         'userId': originalData['userId'],
//         'matchedUserId': matchedData['userId'],
//         'pickupDistance': _matchesByRequest[_selectedRequestId]!
//             .firstWhere((m) => m['id'] == matchedRequestId)['pickupDistance'],
//         'dropoffDistance': _matchesByRequest[_selectedRequestId]!
//             .firstWhere((m) => m['id'] == matchedRequestId)['dropoffDistance'],
//         'timeDifference': _matchesByRequest[_selectedRequestId]!
//             .firstWhere((m) => m['id'] == matchedRequestId)['timeDifference'],
//         'matchScore': _matchesByRequest[_selectedRequestId]!
//             .firstWhere((m) => m['id'] == matchedRequestId)['matchScore'],
//         'isAccepted': true,
//         'createdAt': Timestamp.now(),
//         'status': 'Accepted',
//       });
//
//       // Update both requests
//       await originalRequest.reference.update({
//         'isMatched': true,
//         'activeMatchId': matchRef.id,
//         'matchRequestStatus': 'Matched',
//       });
//
//       await matchedRequest.reference.update({
//         'isMatched': true,
//         'activeMatchId': matchRef.id,
//         'matchRequestStatus': 'Matched',
//       });
//
//       // Refresh user requests
//       await _loadUserRequests();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Match accepted successfully!')),
//       );
//     } catch (e) {
//       print("Error accepting match: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error accepting match: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: const CustomAppBar(title: "View Matches"),
//       drawer: const CustomNavBar(),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Color(0xFF222222)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: _isLoading
//             ? const Center(
//           child: CircularProgressIndicator(
//             color: Colors.yellow,
//           ),
//         )
//             : _userRequests.isEmpty
//             ? _buildNoRequestsView()
//             : Column(
//           children: [
//             _buildRequestSelector(),
//             const Divider(color: Colors.yellow),
//             Expanded(
//               child: _selectedRequestId != null &&
//                   _matchesByRequest.containsKey(_selectedRequestId) &&
//                   _matchesByRequest[_selectedRequestId]!.isNotEmpty
//                   ? _buildMatchesList()
//                   : _buildNoMatchesView(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRequestSelector() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Select your ride request:",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.yellow[700],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.yellow),
//             ),
//             child: DropdownButton<String>(
//               value: _selectedRequestId,
//               isExpanded: true,
//               dropdownColor: Colors.yellow[700],
//               underline: Container(),
//               style: const TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//               items: _userRequests.map((request) {
//                 return DropdownMenuItem<String>(
//                   value: request['id'],
//                   child: Text(
//                     "${request['pickupLocation']} to ${request['dropoffLocation']} - ${request['preferredTime']}",
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   _findMatchesForRequest(newValue);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMatchesList() {
//     List<Map<String, dynamic>> matches = _matchesByRequest[_selectedRequestId]!;
//
//     return ListView.builder(
//       itemCount: matches.length,
//       padding: const EdgeInsets.all(8),
//       itemBuilder: (context, index) {
//         Map<String, dynamic> match = matches[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           color: const Color(0xFF333333),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(
//               color: Colors.yellow.withOpacity(0.5),
//               width: 1,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.stars, color: Colors.yellow, size: 24),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Match Score: ${match['matchScore']}%",
//                       style: TextStyle(
//                         color: _getScoreColor(match['matchScore']),
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Divider(color: Colors.grey),
//                 _buildInfoRow(Icons.location_on, "Pickup", match['pickupLocation']),
//                 _buildInfoRow(Icons.location_searching, "Distance",
//                     "${(match['pickupDistance'] / 1000).toStringAsFixed(2)} km away"),
//                 const SizedBox(height: 8),
//                 _buildInfoRow(Icons.location_off, "Dropoff", match['dropoffLocation']),
//                 _buildInfoRow(Icons.directions, "Distance",
//                     "${(match['dropoffDistance'] / 1000).toStringAsFixed(2)} km away"),
//                 const SizedBox(height: 8),
//                 _buildInfoRow(Icons.access_time, "Time", match['preferredTime']),
//                 _buildInfoRow(Icons.timelapse, "Difference",
//                     "${match['timeDifference']} minutes"),
//                 const SizedBox(height: 8),
//                 _buildInfoRow(Icons.person, "Gender Preference", match['genderPreference']),
//                 _buildInfoRow(Icons.group, "Passengers", match['numberOfPassengers'].toString()),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => _acceptMatch(match['id']),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green[700],
//                         foregroundColor: Colors.black,
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         "Accept Match",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: Colors.yellow[700], size: 20),
//           const SizedBox(width: 8),
//           SizedBox(
//             width: 80,
//             child: Text(
//               "$label:",
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getScoreColor(int score) {
//     if (score >= 90) return Colors.green;
//     if (score >= 75) return Colors.lightGreen;
//     if (score >= 60) return Colors.yellow;
//     return Colors.orange;
//   }
//
//   Widget _buildNoMatchesView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 80, color: Colors.yellow[700]),
//           const SizedBox(height: 16),
//           const Text(
//             "No matches found yet",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "We'll keep looking for suitable matches for your ride request",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               if (_selectedRequestId != null) {
//                 _findMatchesForRequest(_selectedRequestId!);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.yellow[700],
//               foregroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             ),
//             child: const Text("Refresh Search"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoRequestsView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.directions_car_outlined, size: 80, color: Colors.yellow[700]),
//           const SizedBox(height: 16),
//           const Text(
//             "No ride requests found",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Create a ride request to find potential matches",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pushNamed(context, '/RideRequestPage');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.yellow[700],
//               foregroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             ),
//             child: const Text("Create Request"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../components/CustomNavBar.dart';
import '../components/customAppBar.dart';

class ViewMatchesPages extends StatefulWidget {
  const ViewMatchesPages({super.key});

  @override
  ViewMatchesPagesState createState() => ViewMatchesPagesState();
}

class ViewMatchesPagesState extends State<ViewMatchesPages> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _userRequests = [];
  Map<String, List<Map<String, dynamic>>> _matchesByRequest = {};
  String? _selectedRequestId;

  @override
  void initState() {
    super.initState();
    _loadUserRequests();
  }

  Future<void> _loadUserRequests() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to view matches')),
        );
        Navigator.pushNamed(context, '/LoginPage');
        return;
      }

      // Get current user's ride requests
      QuerySnapshot requestsQuery = await FirebaseFirestore.instance
          .collection('RideRequests')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Pending')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> requests = [];
      for (var doc in requestsQuery.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        requests.add({
          'id': doc.id,
          ...data,
        });
      }

      if (mounted) {
        setState(() {
          _userRequests = requests;
          if (requests.isNotEmpty) {
            _selectedRequestId = requests[0]['id'];
            _findMatchesForRequest(requests[0]['id']);
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requests: $e')),
        );
      }
    }
  }

  Future<void> _findMatchesForRequest(String requestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check if we already cached matches for this request
      if (_matchesByRequest.containsKey(requestId)) {
        setState(() {
          _selectedRequestId = requestId;
          _isLoading = false;
        });
        return;
      }

      // Get the original request
      DocumentSnapshot request = await FirebaseFirestore.instance
          .collection('RideRequests')
          .doc(requestId)
          .get();

      if (!request.exists) {
        throw Exception('Request not found');
      }

      Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;

      // Parameters for matching
      GeoPoint pickupCoords = requestData['pickupCoordinates'];
      GeoPoint dropoffCoords = requestData['dropoffCoordinates'];
      String prefTime = requestData['preferredTime'];
      String genderPref = requestData['genderPreference'];
      int passengers = requestData['numberOfPassengers'];

      // Query other ride requests
      QuerySnapshot potentialMatches = await FirebaseFirestore.instance
          .collection('RideRequests')
          .where('status', isEqualTo: 'Pending')
          .where('userId', isNotEqualTo: requestData['userId']) // Don't match with self
          .get();

      List<Map<String, dynamic>> matches = [];

      for (var doc in potentialMatches.docs) {
        Map<String, dynamic> matchData = doc.data() as Map<String, dynamic>;

        // Skip if gender preference doesn't match
        if (genderPref != "Any" && matchData['genderPreference'] != "Any" &&
            genderPref != matchData['genderPreference']) {
          continue;
        }

        // Calculate distances
        double pickupDistance = Geolocator.distanceBetween(
          pickupCoords.latitude,
          pickupCoords.longitude,
          matchData['pickupCoordinates'].latitude,
          matchData['pickupCoordinates'].longitude,
        );

        double dropoffDistance = Geolocator.distanceBetween(
          dropoffCoords.latitude,
          dropoffCoords.longitude,
          matchData['dropoffCoordinates'].latitude,
          matchData['dropoffCoordinates'].longitude,
        );

        // Parse time strings to calculate difference
        int timeDiff = _calculateTimeDifference(prefTime, matchData['preferredTime']);

        // Check if total passengers exceed limit
        int totalPassengers = passengers + (matchData['numberOfPassengers'] as int);
        if (totalPassengers > 5) {
          continue;
        }

        // Calculate match score
        int matchScore = _calculateMatchScore(
          pickupDistance,
          dropoffDistance,
          timeDiff,
        );

        // Add to matches if score is above threshold
        if (matchScore >= 60) {
          matches.add({
            'id': doc.id,
            ...matchData,
            'pickupDistance': pickupDistance,
            'dropoffDistance': dropoffDistance,
            'timeDifference': timeDiff,
            'matchScore': matchScore,
          });
        }
      }

      // Sort by match score (highest first)
      matches.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));

      // Save matches to cache
      _matchesByRequest[requestId] = matches;

      if (mounted) {
        setState(() {
          _selectedRequestId = requestId;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error finding matches: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding matches: $e')),
        );
      }
    }
  }

  int _calculateTimeDifference(String time1, String time2) {
    // Parse time strings in 24-hour format (e.g., "14:30")
    List<String> parts1 = time1.split(':');
    List<String> parts2 = time2.split(':');

    if (parts1.length < 2 || parts2.length < 2) {
      return 1440; // Return 24 hours (in minutes) if format is invalid
    }

    try {
      int hour1 = int.parse(parts1[0]);
      int minute1 = int.parse(parts1[1]);
      int hour2 = int.parse(parts2[0]);
      int minute2 = int.parse(parts2[1]);

      int totalMinutes1 = hour1 * 60 + minute1;
      int totalMinutes2 = hour2 * 60 + minute2;

      return (totalMinutes1 - totalMinutes2).abs();
    } catch (e) {
      return 1440; // Default to 24 hours on error
    }
  }

  int _calculateMatchScore(double pickupDist, double dropoffDist, int timeDiff) {
    // Base score
    int score = 100;

    // Deduct points for pickup distance (max deduction: 30 points)
    if (pickupDist > 2000) { // More than 2km
      score -= 30;
    } else if (pickupDist > 1000) { // More than 1km
      score -= 15;
    } else if (pickupDist > 500) { // More than 500m
      score -= 5;
    }

    // Deduct points for dropoff distance (max deduction: 20 points)
    if (dropoffDist > 3000) { // More than 3km
      score -= 20;
    } else if (dropoffDist > 1500) { // More than 1.5km
      score -= 10;
    } else if (dropoffDist > 1000) { // More than 1km
      score -= 5;
    }

    // Deduct points for time difference (max deduction: 40 points)
    if (timeDiff > 30) { // More than 30 minutes
      score -= 40;
    } else if (timeDiff > 15) { // More than 15 minutes
      score -= 20;
    } else if (timeDiff > 5) { // More than 5 minutes
      score -= 10;
    }

    return score < 0 ? 0 : score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "View Matches"),
      drawer: const CustomNavBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF222222)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.yellow,
          ),
        )
            : _userRequests.isEmpty
            ? _buildNoRequestsView()
            : Column(
          children: [
            _buildRequestSelector(),
            const Divider(color: Colors.yellow),
            Expanded(
              child: _selectedRequestId != null &&
                  _matchesByRequest.containsKey(_selectedRequestId) &&
                  _matchesByRequest[_selectedRequestId]!.isNotEmpty
                  ? _buildMatchesList()
                  : _buildNoMatchesView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select your ride request:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow),
            ),
            child: DropdownButton<String>(
              value: _selectedRequestId,
              isExpanded: true,
              dropdownColor: Colors.yellow[700],
              underline: Container(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              items: _userRequests.map((request) {
                return DropdownMenuItem<String>(
                  value: request['id'],
                  child: Text(
                    "${request['pickupLocation']} to ${request['dropoffLocation']} - ${request['preferredTime']}",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _findMatchesForRequest(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    List<Map<String, dynamic>> matches = _matchesByRequest[_selectedRequestId]!;

    return ListView.builder(
      itemCount: matches.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        Map<String, dynamic> match = matches[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          color: const Color(0xFF333333),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.yellow.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.yellow, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Match Score: ${match['matchScore']}%",
                      style: TextStyle(
                        color: _getScoreColor(match['matchScore']),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey),
                _buildInfoRow(Icons.location_on, "Pickup", match['pickupLocation']),
                _buildInfoRow(Icons.location_searching, "Distance",
                    "${(match['pickupDistance'] / 1000).toStringAsFixed(2)} km away"),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_off, "Dropoff", match['dropoffLocation']),
                _buildInfoRow(Icons.directions, "Distance",
                    "${(match['dropoffDistance'] / 1000).toStringAsFixed(2)} km away"),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, "Time", match['preferredTime']),
                _buildInfoRow(Icons.timelapse, "Difference",
                    "${match['timeDifference']} minutes"),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person, "Gender Preference", match['genderPreference']),
                _buildInfoRow(Icons.group, "Passengers", match['numberOfPassengers'].toString()),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _acceptMatch(match['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Accept Match",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _acceptMatch(String matchedRequestId) {
    // TODO: Implement the match acceptance logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match acceptance will be implemented soon')),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.yellow[700], size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return Colors.yellow;
    return Colors.orange;
  }

  Widget _buildNoMatchesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.yellow[700]),
          const SizedBox(height: 16),
          const Text(
            "No matches found yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll keep looking for suitable matches for your ride request",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_selectedRequestId != null) {
                _findMatchesForRequest(_selectedRequestId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text("Refresh Search"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRequestsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 80, color: Colors.yellow[700]),
          const SizedBox(height: 16),
          const Text(
            "No ride requests found",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Create a ride request to find potential matches",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/RideRequestPage');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text("Create Request"),
          ),
        ],
      ),
    );
  }
}