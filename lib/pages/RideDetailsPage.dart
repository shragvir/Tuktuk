import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/customAppBar.dart';
import 'ViewMatchesPage.dart';

class RideDetailsPage extends StatefulWidget {
  final String matchId;
  final bool isOtpVerified;

  const RideDetailsPage({
    Key? key,
    required this.matchId,
    required this.isOtpVerified,
  }) : super(key: key);

  @override
  _RideDetailsPageState createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _processingEndRide = false;

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('UserRegistration').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return {
          'displayName': userData['name'] ?? 'Unknown User',
          'photoURL':null,
          'email': userData['email'] ?? 'No email',
          'phone': userData['mobileNo'] ?? 'No phone',
        };
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return {
      'displayName': 'Unknown User',
      'photoURL': null,
      'email': 'No email',
      'phone': 'No phone',
    };
  }

  Future<void> _endRide() async {
    if (_processingEndRide) return;

    setState(() {
      _processingEndRide = true;
    });

    try {
      // Get the current match data
      final matchDoc = await _firestore.collection('RideMatches').doc(widget.matchId).get();
      if (!matchDoc.exists) {
        _showErrorMessage('Match data not found');
        return;
      }

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final List<dynamic> userIds = matchData['userIds'] ?? [];
      final List<dynamic> rideRequestIds = matchData['rideRequestIds'] ?? [];
      final List<dynamic> requestStatuses = matchData['requestStatuses'] ?? [];

      // Find the current user's index
      final currentUserId = _currentUser?.uid;
      if (currentUserId == null) {
        _showErrorMessage('User not authenticated');
        return;
      }

      final userIndex = userIds.indexOf(currentUserId);
      if (userIndex == -1 || userIndex >= rideRequestIds.length) {
        _showErrorMessage('User not found in match');
        return;
      }

      // Update the request status for this user to "Completed"
      final updatedStatuses = List<String>.from(requestStatuses);
      updatedStatuses[userIndex] = 'Completed';

      // Check if all requests are now completed
      bool allCompleted = true;
      for (String status in updatedStatuses) {
        if (status != 'Completed') {
          allCompleted = false;
          break;
        }
      }

      // Update the match document
      final batch = _firestore.batch();
      final matchRef = _firestore.collection('RideMatches').doc(widget.matchId);

      batch.update(matchRef, {
        'requestStatuses': updatedStatuses,
        // If all users have completed, update the match status as well
        if (allCompleted) 'status': 'Completed',
      });

      // Update the user's ride request status
      final rideRequestId = rideRequestIds[userIndex];
      final requestRef = _firestore.collection('RideRequests').doc(rideRequestId);
      batch.update(requestRef, {
        'status': 'Completed',
      });

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride marked as completed')),
      );

      // If all requests are completed, show a success message
      if (allCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All riders have completed the ride')),
        );
      }

      // Refresh the page
      setState(() {});

    } catch (e) {
      _showErrorMessage('Error completing ride: $e');
    } finally {
      setState(() {
        _processingEndRide = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green[700], // Green header
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ViewMatchesPage()),
            );
          },
        ),
        title: const Text(
          "Ride Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('RideMatches').doc(widget.matchId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.yellowAccent),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Ride details not found",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> userIds = data['userIds'] ?? [];
          final List<dynamic> pickupLocations = data['pickupLocations'] ?? [];
          final List<dynamic> dropoffLocations = data['dropoffLocations'] ?? [];
          final List<dynamic> requestStatuses = data['requestStatuses'] ?? [];
          final bool isOtpVerified = data['isOtpVerified'] ?? false;
          final String matchStatus = data['status'] ?? '';

          // Find current user's index and status
          final currentUserId = _currentUser?.uid;
          final userIndex = userIds.indexOf(currentUserId);
          final currentUserStatus = userIndex >= 0 && userIndex < requestStatuses.length
              ? requestStatuses[userIndex]
              : '';

          final bool canEndRide = isOtpVerified &&
              currentUserStatus != 'Completed' &&
              matchStatus != 'Completed' &&
              matchStatus != 'Canceled';

          return Column(
            children: [
              // Ride Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: _getStatusColor(matchStatus),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ride Status: $matchStatus",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isOtpVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.verified, color: Colors.white),
                      ),
                  ],
                ),
              ),

              // User list with pickup/dropoff info
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userIds.length,
                  itemBuilder: (context, index) {
                    final userId = userIds[index];
                    final pickups = index < pickupLocations.length ? pickupLocations[index] : 'Unknown';
                    final dropoffs = index < dropoffLocations.length ? dropoffLocations[index] : 'Unknown';
                    final status = index < requestStatuses.length ? requestStatuses[index] : 'Unknown';

                    String pickup = pickups.toString().split(',')[0];
                    String dropoff = dropoffs.toString().split(',')[0];

                    // Show the current user's card with a different color
                    final isCurrentUser = userId == currentUserId;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getUserData(userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Loading user data...'),
                            ),
                          );
                        }

                        final userData = userSnapshot.data!;

                        return Card(
                          color: isCurrentUser ? Colors.blue[800] : Colors.blue[800],
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: userData['photoURL'] != null
                                          ? NetworkImage(userData['photoURL'])
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                      child: userData['photoURL'] == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userData['displayName'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (isCurrentUser)
                                            const Text(
                                              "(You)",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow('From', pickup.toString()),
                                const SizedBox(height: 4),
                                _buildInfoRow('To', dropoff.toString()),
                                const SizedBox(height: 8),
                                _buildInfoRow('Mobile', userData['phone']),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // End Ride Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: canEndRide ? _endRide : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _processingEndRide
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  )
                      : Text(
                    currentUserStatus == 'Completed'
                        ? "You've Completed This Ride"
                        : (canEndRide ? "End Ride" : "Cannot End Ride Yet"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.lightGreen;
      case 'matched':
        return Colors.lightBlueAccent;
      case 'waiting':
        return Colors.orange;
      case 'canceled':
        return Colors.red[700]!;
      case 'full':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}

/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/customAppBar.dart';
import 'ViewMatchesPage.dart';
import 'dart:math';
import 'package:latlong2/latlong.dart' as ll;

class RideDetailsPage extends StatefulWidget {
  final String matchId;
  final bool isOtpVerified;

  const RideDetailsPage({
    Key? key,
    required this.matchId,
    required this.isOtpVerified,
  }) : super(key: key);

  @override
  _RideDetailsPageState createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _processingEndRide = false;
  final ll.Distance _distanceCalculator = ll.Distance();

  // Cost calculation parameters
  final double _baseFare = 50.0;           // Base fare in INR
  final double _costPerKm = 15.0;          // Cost per km in INR
  final double _minFare = 100.0;           // Minimum fare in INR

  Map<String, double> _distancePerUser = {};
  Map<String, double> _costPerUser = {};
  double _totalRideDistance = 0.0;
  double _totalRideCost = 0.0;

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('UserRegistration').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return {
          'displayName': userData['name'] ?? 'Unknown User',
          'photoURL':null,
          'email': userData['email'] ?? 'No email',
          'phone': userData['mobileNo'] ?? 'No phone',
        };
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return {
      'displayName': 'Unknown User',
      'photoURL': null,
      'email': 'No email',
      'phone': 'No phone',
    };
  }

  // Calculate distance between two points
  double _calculateDistance(ll.LatLng start, ll.LatLng end) {
    return _distanceCalculator.as(ll.LengthUnit.Kilometer, start, end);
  }

  // Calculate cost based on distance
  double _calculateCost(double distanceInKm) {
    double cost = _baseFare + (distanceInKm * _costPerKm);
    return cost < _minFare ? _minFare : cost;
  }

  // Calculate costs for all users
  Future<void> _calculateCostsForAllUsers(Map<String, dynamic> data) async {
    try {
      final List<dynamic> userIds = data['userIds'] ?? [];
      final List<dynamic> pickupLocations = data['pickupLocations'] ?? [];
      final List<dynamic> dropoffLocations = data['dropoffLocations'] ?? [];

      // Main route coordinates
      final GeoPoint mainPickupGeo = data['pickupCoordinates'];
      final GeoPoint mainDropoffGeo = data['dropoffCoordinates'];
      final ll.LatLng mainPickup = ll.LatLng(mainPickupGeo.latitude, mainPickupGeo.longitude);
      final ll.LatLng mainDropoff = ll.LatLng(mainDropoffGeo.latitude, mainDropoffGeo.longitude);

      // Calculate total distance of the entire ride
      _totalRideDistance = _calculateDistance(mainPickup, mainDropoff);
      _totalRideCost = _calculateCost(_totalRideDistance);

      // Calculate individual distances
      Map<String, double> distances = {};
      double totalSegmentDistance = 0.0;

      for (int i = 0; i < userIds.length; i++) {
        final String userId = userIds[i];

        // Calculate individual segment distance if pickup/dropoff data exists
        if (i < pickupLocations.length && i < dropoffLocations.length) {
          // Get coordinates for this user's journey
          final pickupGeo = data['pickupCoordinates'];
          final dropoffGeo = data['dropoffCoordinates'];

          // Use individual coordinates if available, otherwise use main route
          final ll.LatLng pickup = pickupGeo != null
              ? ll.LatLng(pickupGeo.latitude, pickupGeo.longitude)
              : mainPickup;
          final ll.LatLng dropoff = dropoffGeo != null
              ? ll.LatLng(dropoffGeo.latitude, dropoffGeo.longitude)
              : mainDropoff;

          // Calculate this user's distance
          final double distance = _calculateDistance(pickup, dropoff);
          distances[userId] = distance;
          totalSegmentDistance += distance;
        } else {
          // Fallback if specific data is missing
          distances[userId] = _totalRideDistance / userIds.length;
          totalSegmentDistance += _totalRideDistance / userIds.length;
        }
      }

      // Calculate costs proportionally
      Map<String, double> costs = {};

      if (totalSegmentDistance > 0) {
        for (final userId in userIds) {
          final double userDistance = distances[userId] ?? (_totalRideDistance / userIds.length);
          final double proportion = userDistance / totalSegmentDistance;
          costs[userId] = _totalRideCost * proportion;
        }
      } else {
        // Fallback to equal splitting
        for (final userId in userIds) {
          costs[userId] = _totalRideCost / userIds.length;
        }
      }

      setState(() {
        _distancePerUser = distances;
        _costPerUser = costs;
      });
    } catch (e) {
      print('Error calculating costs: $e');
    }
  }

  Future<void> _endRide() async {
    if (_processingEndRide) return;

    setState(() {
      _processingEndRide = true;
    });

    try {
      // Get the current match data
      final matchDoc = await _firestore.collection('RideMatches').doc(widget.matchId).get();
      if (!matchDoc.exists) {
        _showErrorMessage('Match data not found');
        return;
      }

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final List<dynamic> userIds = matchData['userIds'] ?? [];
      final List<dynamic> rideRequestIds = matchData['rideRequestIds'] ?? [];
      final List<dynamic> requestStatuses = matchData['requestStatuses'] ?? [];

      // Find the current user's index
      final currentUserId = _currentUser?.uid;
      if (currentUserId == null) {
        _showErrorMessage('User not authenticated');
        return;
      }

      final userIndex = userIds.indexOf(currentUserId);
      if (userIndex == -1 || userIndex >= rideRequestIds.length) {
        _showErrorMessage('User not found in match');
        return;
      }

      // Update the request status for this user to "Completed"
      final updatedStatuses = List<String>.from(requestStatuses);
      updatedStatuses[userIndex] = 'Completed';

      // Check if all requests are now completed
      bool allCompleted = true;
      for (String status in updatedStatuses) {
        if (status != 'Completed') {
          allCompleted = false;
          break;
        }
      }

      // Update the match document
      final batch = _firestore.batch();
      final matchRef = _firestore.collection('RideMatches').doc(widget.matchId);

      batch.update(matchRef, {
        'requestStatuses': updatedStatuses,
        // If all users have completed, update the match status as well
        if (allCompleted) 'status': 'Completed',
      });

      // Update the user's ride request status
      final rideRequestId = rideRequestIds[userIndex];
      final requestRef = _firestore.collection('RideRequests').doc(rideRequestId);
      batch.update(requestRef, {
        'status': 'Completed',
      });

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride marked as completed')),
      );

      // If all requests are completed, show a success message
      if (allCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All riders have completed the ride')),
        );
      }

      // Refresh the page
      setState(() {});

    } catch (e) {
      _showErrorMessage('Error completing ride: $e');
    } finally {
      setState(() {
        _processingEndRide = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green[700], // Green header
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ViewMatchesPage()),
            );
          },
        ),
        title: const Text(
          "Ride Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('RideMatches').doc(widget.matchId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.yellowAccent),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Ride details not found",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> userIds = data['userIds'] ?? [];
          final List<dynamic> pickupLocations = data['pickupLocations'] ?? [];
          final List<dynamic> dropoffLocations = data['dropoffLocations'] ?? [];
          final List<dynamic> requestStatuses = data['requestStatuses'] ?? [];
          final bool isOtpVerified = data['isOtpVerified'] ?? false;
          final String matchStatus = data['status'] ?? '';

          // Calculate costs if not already done
          if (_totalRideCost == 0) {
            _calculateCostsForAllUsers(data);
          }

          // Find current user's index and status
          final currentUserId = _currentUser?.uid;
          final userIndex = userIds.indexOf(currentUserId);
          final currentUserStatus = userIndex >= 0 && userIndex < requestStatuses.length
              ? requestStatuses[userIndex]
              : '';

          final bool canEndRide = isOtpVerified &&
              currentUserStatus != 'Completed' &&
              matchStatus != 'Completed' &&
              matchStatus != 'Canceled';

          return Column(
            children: [
              // Ride Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: _getStatusColor(matchStatus),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ride Status: $matchStatus",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isOtpVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.verified, color: Colors.white),
                      ),
                  ],
                ),
              ),

              // Cost Summary Card
              Card(
                color: Colors.blue[900],
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Cost Estimate",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "₹${_totalRideCost.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Distance: ${_totalRideDistance.toStringAsFixed(2)} km",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Cost Split",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_costPerUser.isNotEmpty)
                        ...userIds.map((userId) {
                          final isCurrentUser = userId == currentUserId;
                          final double cost = _costPerUser[userId] ?? (_totalRideCost / userIds.length);
                          final double distance = _distancePerUser[userId] ?? (_totalRideDistance / userIds.length);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${isCurrentUser ? 'You' : 'Rider'} (${distance.toStringAsFixed(1)} km)",
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.yellowAccent : Colors.white,
                                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  "₹${cost.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.yellowAccent : Colors.white,
                                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      else
                        const Text(
                          "Calculating cost split...",
                          style: TextStyle(color: Colors.white70),
                        )
                    ],
                  ),
                ),
              ),

              // User list with pickup/dropoff info
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: userIds.length,
                  itemBuilder: (context, index) {
                    final userId = userIds[index];
                    final pickups = index < pickupLocations.length ? pickupLocations[index] : 'Unknown';
                    final dropoffs = index < dropoffLocations.length ? dropoffLocations[index] : 'Unknown';
                    final status = index < requestStatuses.length ? requestStatuses[index] : 'Unknown';

                    String pickup = pickups.toString().split(',')[0];
                    String dropoff = dropoffs.toString().split(',')[0];

                    // Show the current user's card with a different color
                    final isCurrentUser = userId == currentUserId;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getUserData(userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Loading user data...'),
                            ),
                          );
                        }

                        final userData = userSnapshot.data!;

                        return Card(
                          color: isCurrentUser ? Colors.blue[800] : Colors.blue[800],
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: userData['photoURL'] != null
                                          ? NetworkImage(userData['photoURL'])
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                      child: userData['photoURL'] == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userData['displayName'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (isCurrentUser)
                                            const Text(
                                              "(You)",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow('From', pickup.toString()),
                                const SizedBox(height: 4),
                                _buildInfoRow('To', dropoff.toString()),
                                const SizedBox(height: 8),
                                _buildInfoRow('Mobile', userData['phone']),
                                if (_costPerUser.containsKey(userId))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: _buildInfoRow('Cost', '₹${_costPerUser[userId]!.toStringAsFixed(2)}'),
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

              // End Ride Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: canEndRide ? _endRide : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _processingEndRide
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  )
                      : Text(
                    currentUserStatus == 'Completed'
                        ? "You've Completed This Ride"
                        : (canEndRide ? "End Ride" : "Cannot End Ride Yet"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.lightGreen;
      case 'matched':
        return Colors.lightBlueAccent;
      case 'waiting':
        return Colors.orange;
      case 'canceled':
        return Colors.red[700]!;
      case 'full':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}*/
