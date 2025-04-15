import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../components/CustomNavBar.dart';
import '../components/customAppBar.dart';
import 'MapSelectionPage.dart';

class RideRequestPage extends StatefulWidget {
  const RideRequestPage({super.key});

  @override
  RideRequestState createState() => RideRequestState();
}

class RideRequestState extends State<RideRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String? genderPreference = "Any";
  int _selectedPassengerCount = 2; // Default number of passengers
  LatLng? _selectedPickupLocation;
  LatLng? _selectedDropoffLocation;

// Utility to calculate distance between two coordinates (Haversine formula)
  double calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371; // in km
    final dLat = _degreesToRadians(end.latitude - start.latitude);
    final dLon = _degreesToRadians(end.longitude - start.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double deg) => deg * pi / 180;

// Function to parse and compare time proximity
  bool isTimeWithinRange(String time1, String time2) {
    try {
      final format = DateFormat("HH:mm");
      final t1 = format.parse(time1);
      final t2 = format.parse(time2);
      final diff = t1.difference(t2).inMinutes.abs();
      return diff <= 15;
    } catch (e) {
      print("Time parsing error: $e");
      return false;
    }
  }

  final Distance distanceCalculator = ll.Distance();

  double calculateDistanceInKm(ll.LatLng start, ll.LatLng end) {
    return distanceCalculator.as(ll.LengthUnit.Kilometer, start, end);
  }



/*
  Future<void> checkForMatchingRides({
    required String userId,
    required String rideRequestId,
    required LatLng pickupCoordinates,
    required LatLng dropoffCoordinates,
    required String time,
    required String genderPref,
    required int maxPassengers,
    required String pickupLocation,
    required String dropoffLocation, required userGender,

  })
  async {
    final firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore
          .collection('RideRequests')
          .where('status', isEqualTo: 'Pending')
          .where('genderPreference', isEqualTo: genderPref)
          .get();

      bool foundMatchInRequests = false;

      for (var doc in querySnapshot.docs) {
        if (doc.id == rideRequestId) continue;

        final data = doc.data();
        final GeoPoint? otherPickupGeo = data['pickupCoordinates'];
        final GeoPoint? otherDropoffGeo = data['dropoffCoordinates'];
        final String? otherTime = data['preferredTime'];

        if (otherPickupGeo == null || otherDropoffGeo == null || otherTime == null) {
          continue;
        }

        final ll.LatLng otherPickup = ll.LatLng(otherPickupGeo.latitude, otherPickupGeo.longitude);
        final ll.LatLng otherDropoff = ll.LatLng(otherDropoffGeo.latitude, otherDropoffGeo.longitude);
        final ll.LatLng userPickup = ll.LatLng(pickupCoordinates.latitude, pickupCoordinates.longitude);
        final ll.LatLng userDropoff = ll.LatLng(dropoffCoordinates.latitude, dropoffCoordinates.longitude);

        final pickupDistance = calculateDistanceInKm(userPickup, otherPickup);
        final dropoffDistance = calculateDistanceInKm(userDropoff, otherDropoff);

        if (pickupDistance > 2 || dropoffDistance > 2) continue;

        if (!isTimeWithinRange(time, otherTime)) continue;

        final newMatchRef = firestore.collection('RideMatches').doc();
        await newMatchRef.set({
          'matchId': newMatchRef.id,
          'userIds': [userId, data['userId']],
          'rideRequestIds': [rideRequestId, doc.id],
          'pickupLocation': pickupLocation,                  // ✅ Add this
          'dropoffLocation': dropoffLocation,
          'pickupCoordinates': GeoPoint(pickupCoordinates.latitude, pickupCoordinates.longitude), // ✅ fix here
          'dropoffCoordinates': GeoPoint(dropoffCoordinates.latitude, dropoffCoordinates.longitude), // ✅ and here
          'genderPreference': genderPref,
          'status': 'Waiting',
          'maxPassengerCount': maxPassengers,
          'currentPassengerCount': 2,
          'createdAt': Timestamp.now(),
        });

        await firestore.collection('RideRequests').doc(rideRequestId).update({
          'status': 'Matched',
        });

        await firestore.collection('RideRequests').doc(doc.id).update({
          'status': 'Matched',
        });

        foundMatchInRequests = true;
        break;
      }

      if (!foundMatchInRequests) {
        // Only check RideMatches if no suitable RideRequest match was found
        final existingMatchQuery = await firestore
            .collection('RideMatches')
            .where('status', isEqualTo: 'Waiting')
            .where('genderPreference', isEqualTo: genderPref)
            .get();

        final ll.LatLng userPickup = ll.LatLng(pickupCoordinates.latitude, pickupCoordinates.longitude);
        final ll.LatLng userDropoff = ll.LatLng(dropoffCoordinates.latitude, dropoffCoordinates.longitude);

        for (var match in existingMatchQuery.docs) {
          final current = match.data();
          final GeoPoint? matchPickupGeo = current['pickupCoordinates'];
          final GeoPoint? matchDropoffGeo = current['dropoffCoordinates'];

          if (matchPickupGeo == null || matchDropoffGeo == null) continue;

          final ll.LatLng matchPickup = ll.LatLng(matchPickupGeo.latitude, matchPickupGeo.longitude);
          final ll.LatLng matchDropoff = ll.LatLng(matchDropoffGeo.latitude, matchDropoffGeo.longitude);

          final matchPickupDist = calculateDistanceInKm(userPickup, matchPickup);
          final matchDropoffDist = calculateDistanceInKm(userDropoff, matchDropoff);

          if (matchPickupDist <= 2 &&
              matchDropoffDist <= 2 &&
              current['currentPassengerCount'] < current['maxPassengerCount']) {
            await firestore.collection('RideMatches').doc(match.id).update({
              'userIds': FieldValue.arrayUnion([userId]),
              'rideRequestIds': FieldValue.arrayUnion([rideRequestId]),
              'currentPassengerCount': FieldValue.increment(1),
            });

            await firestore.collection('RideRequests').doc(rideRequestId).update({
              'status': 'Matched',
            });

            break;
          }
        }
      }
    } catch (e) {
      print('Error in matching logic: $e');
    }
  }
*/

  Future<void> checkForMatchingRides({
    required String userId,
    required String rideRequestId,
    required LatLng pickupCoordinates,
    required LatLng dropoffCoordinates,
    required String time,
    required String genderPref,   // current user's preference for others
    required String userGender,   // current user's own gender
    required int maxPassengers,
    required String pickupLocation,
    required String dropoffLocation,
  }) async
  {
    final firestore = FirebaseFirestore.instance;

    try {
      // Look for pending ride requests whose user's actual gender matches the current user's gender preference,
      // except when current user's preference is "Any".
      Query query = firestore.collection('RideRequests')
          .where('status', isEqualTo: 'pending');
      if (genderPref.toLowerCase() != 'any') {
        // Instead of matching on the other user's genderPreference,
        // we match the other user's actual gender.
        query = query.where('gender', isEqualTo: genderPref);
      }
      final querySnapshot = await query.get();

      bool foundMatchInRequests = false;

      for (var doc in querySnapshot.docs) {
        // Ensure we're not matching to our own ride request.
        if (doc.id == rideRequestId) continue;

        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue; // Skip this document if data is null.

        // Also check that the other ride's user is not the same as the current user.
        if (data['userId'] == userId) continue;

        final GeoPoint? otherPickupGeo = data['pickupCoordinates'];
        final GeoPoint? otherDropoffGeo = data['dropoffCoordinates'];
        final String? otherTime = data['preferredTime'];
        final String? otherUserId = data['userId'];
        final String? otherGender = data['gender']; // other user's actual gender
        final String? otherGenderPref = data['genderPreference']; // other user's preference

        if (otherPickupGeo == null ||
            otherDropoffGeo == null ||
            otherTime == null ||
            otherUserId == null ||
            otherGender == null ||
            otherGenderPref == null) {
          continue;
        }

        // If the other user's gender preference is not "Any", then check that it matches current user's gender.
        if (otherGenderPref.toLowerCase() != 'any' &&
            otherGenderPref.toLowerCase() != userGender.toLowerCase()) {
          continue;
        }

        final ll.LatLng otherPickup = ll.LatLng(otherPickupGeo.latitude, otherPickupGeo.longitude);
        final ll.LatLng otherDropoff = ll.LatLng(otherDropoffGeo.latitude, otherDropoffGeo.longitude);
        final ll.LatLng userPickup = ll.LatLng(pickupCoordinates.latitude, pickupCoordinates.longitude);
        final ll.LatLng userDropoff = ll.LatLng(dropoffCoordinates.latitude, dropoffCoordinates.longitude);

        final pickupDistance = calculateDistanceInKm(userPickup, otherPickup);
        final dropoffDistance = calculateDistanceInKm(userDropoff, otherDropoff);

        if (pickupDistance > 2 || dropoffDistance > 2) continue;
        if (!isTimeWithinRange(time, otherTime)) continue;

        // Calculate overall match gender preference.
        String matchGenderPreference;
        if (genderPref.toLowerCase() == otherGenderPref.toLowerCase() &&
            genderPref.toLowerCase() != 'any') {
          matchGenderPreference = genderPref;
        } else {
          matchGenderPreference = 'none';
        }

        // Create a new RideMatch document that includes both requests.
        final newMatchRef = firestore.collection('RideMatches').doc();
        await newMatchRef.set({
          'matchId': newMatchRef.id,
          'userIds': [userId, otherUserId],
          'rideRequestIds': [rideRequestId, doc.id],
          'pickupLocation': pickupLocation,
          'dropoffLocation': dropoffLocation,
          'pickupCoordinates': GeoPoint(pickupCoordinates.latitude, pickupCoordinates.longitude),
          'dropoffCoordinates': GeoPoint(dropoffCoordinates.latitude, dropoffCoordinates.longitude),
          'genderPreference': matchGenderPreference,
          // Set status based on capacity; if two passengers equal max, set to "Full", else "Waiting"
          'status': (2 == maxPassengers) ? 'Full' : 'Waiting',
          'maxPassengerCount': maxPassengers,
          'currentPassengerCount': 2,
          'createdAt': Timestamp.now(),
          // Store the actual genders of both matched users
          'passengerGenders': [userGender, otherGender],
          'passengerGenderPreferences': [genderPref, otherGenderPref],
        });

        // Update both ride requests' statuses to "Matched" and store matchId
        await firestore.collection('RideRequests').doc(rideRequestId).update({
          'status': 'Matched',
          'matchId': newMatchRef.id,
        });
        await firestore.collection('RideRequests').doc(doc.id).update({
          'status': 'Matched',
          'matchId': newMatchRef.id,
        });

        foundMatchInRequests = true;
        break;
      }

      if (!foundMatchInRequests) {
        // Check existing RideMatches if no suitable pending RideRequest match was found.
        final matchQuery = await firestore
            .collection('RideMatches')
            .where('status', isEqualTo: 'Waiting')
            .where('genderPreference', isEqualTo: userGender)
            .get();

        final ll.LatLng userPickup = ll.LatLng(pickupCoordinates.latitude, pickupCoordinates.longitude);
        final ll.LatLng userDropoff = ll.LatLng(dropoffCoordinates.latitude, dropoffCoordinates.longitude);

        for (var match in matchQuery.docs) {
          final matchData = match.data();
          final GeoPoint? matchPickupGeo = matchData['pickupCoordinates'];
          final GeoPoint? matchDropoffGeo = matchData['dropoffCoordinates'];

          if (matchPickupGeo == null || matchDropoffGeo == null) continue;

          final ll.LatLng matchPickup = ll.LatLng(matchPickupGeo.latitude, matchPickupGeo.longitude);
          final ll.LatLng matchDropoff = ll.LatLng(matchDropoffGeo.latitude, matchDropoffGeo.longitude);

          final matchPickupDist = calculateDistanceInKm(userPickup, matchPickup);
          final matchDropoffDist = calculateDistanceInKm(userDropoff, matchDropoff);

          if (matchPickupDist > 2 || matchDropoffDist > 2) continue;

          final List<dynamic> matchedUserIds = matchData['userIds'];
          final int currentPassengerCount = matchData['currentPassengerCount'];
          final int matchMaxPassengers = matchData['maxPassengerCount'];

          // If match is already full, skip.
          if (currentPassengerCount >= matchMaxPassengers) continue;

          // Check genders of existing passengers stored in match.
          final List<dynamic> passengerGenders = matchData['passengerGenders'] ?? [];
          bool genderCompatible = true;

          // For every passenger already in the match, if new user's gender preference is not "Any", then check that the new user's actual gender
          // matches the expected preference.
          for (var existingGender in passengerGenders) {
            if (genderPref.toLowerCase() != 'any' &&
                userGender.toLowerCase() != genderPref.toLowerCase()) {
              genderCompatible = false;
              break;
            }
          }

          if (!genderCompatible) continue;

          final newCount = currentPassengerCount + 1;
          final newStatus = (newCount == matchMaxPassengers) ? 'Full' : 'Waiting';

          // Update the RideMatch with the new passenger.
          await firestore.collection('RideMatches').doc(match.id).update({
            'userIds': FieldValue.arrayUnion([userId]),
            'rideRequestIds': FieldValue.arrayUnion([rideRequestId]),
            'currentPassengerCount': newCount,
            'status': newStatus,
            // Also update passengerGenders array by adding the new user's gender.
            'passengerGenders': FieldValue.arrayUnion([userGender]),
          });

          // Update the ride request status for this new passenger.
          await firestore.collection('RideRequests').doc(rideRequestId).update({
            'status': 'Matched',
            'matchId': match.id,
          });

          break;
        }
      }
    } catch (e) {
      print('Error in matching logic: $e');
    }
  }



/*  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to submit a ride request'),
          ),
        );
        return;
      }

      try {
        // Generate a new document reference with a custom ID
        final rideDoc =
            FirebaseFirestore.instance.collection('RideRequests').doc();
        final rideId = rideDoc.id;

        await rideDoc.set({
          'rideRequestId': rideId,
          'userId': user.uid,
          'pickupLocation': _pickupController.text,
          'pickupCoordinates': GeoPoint(
            _selectedPickupLocation!.latitude,
            _selectedPickupLocation!.longitude,
          ),
          'dropoffLocation': _dropoffController.text,
          'dropoffCoordinates': GeoPoint(
            _selectedDropoffLocation!.latitude,
            _selectedDropoffLocation!.longitude,
          ),
          'preferredTime': _timeController.text,
          'genderPreference': genderPreference,
          'numberOfPassengers': _selectedPassengerCount,
          'createdAt': Timestamp.now(),
          'status': "Pending",
        });

        await checkForMatchingRides(
          userId: user.uid,
          rideRequestId: rideId,
          pickupCoordinates: _selectedPickupLocation!,
          dropoffCoordinates: _selectedDropoffLocation!,
          time: _timeController.text,
          genderPref: genderPreference!,
          maxPassengers: _selectedPassengerCount,
          pickupLocation: _pickupController.text,        // ✅
          dropoffLocation: _dropoffController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride Request Submitted!')),
        );

        _formKey.currentState!.reset();
        _pickupController.clear();
        _dropoffController.clear();
        _timeController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    }
  }*/
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to submit a ride request'),
          ),
        );
        return;
      }

      try {
        // 🔹 Get the user's gender from the Users collection
        final userSnapshot = await FirebaseFirestore.instance
            .collection('UserRegistration')
            .doc(user.uid)
            .get();

        final userGender = userSnapshot.data()?['gender'];
        if (userGender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User gender not found')),
          );
          return;
        }

        final rideDoc =
        FirebaseFirestore.instance.collection('RideRequests').doc();
        final rideId = rideDoc.id;

        await rideDoc.set({
          'rideRequestId': rideId,
          'userId': user.uid,
          'gender': userGender, // ✅ Store user's gender
          'pickupLocation': _pickupController.text,
          'pickupCoordinates': GeoPoint(
            _selectedPickupLocation!.latitude,
            _selectedPickupLocation!.longitude,
          ),
          'dropoffLocation': _dropoffController.text,
          'dropoffCoordinates': GeoPoint(
            _selectedDropoffLocation!.latitude,
            _selectedDropoffLocation!.longitude,
          ),
          'preferredTime': _timeController.text,
          'genderPreference': genderPreference,
          'numberOfPassengers': _selectedPassengerCount,
          'createdAt': Timestamp.now(),
          'status': "pending",
        });

        await checkForMatchingRides(
          userId: user.uid,
          userGender: userGender,
          rideRequestId: rideId,
          pickupCoordinates: _selectedPickupLocation!,
          dropoffCoordinates: _selectedDropoffLocation!,
          time: _timeController.text,
          genderPref: genderPreference!,
          maxPassengers: _selectedPassengerCount,
          pickupLocation: _pickupController.text,
          dropoffLocation: _dropoffController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride Request Submitted!')),
        );

        _formKey.currentState!.reset();
        _pickupController.clear();
        _dropoffController.clear();
        _timeController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    }
  }


  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.administrativeArea}";
      } else {
        return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      }
    } catch (e) {
      print("Geocoding error: $e");
      return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "Request a Ride"),
      drawer: const CustomNavBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF222222)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Pickup Location Field
                buildLocationField(
                  label: 'Pickup Location',
                  controller: _pickupController,
                  onTap: () => _navigateToMapSelection(context, true),
                ),

                // Drop-off Location Field
                buildLocationField(
                  label: 'Drop-off Location',
                  controller: _dropoffController,
                  onTap: () => _navigateToMapSelection(context, false),
                ),

                // buildTextField('Preferred Time', _timeController),

                buildTimeField(),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    'Gender Preference:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildRadioButton('Any'),
                    buildRadioButton('Male'),
                    buildRadioButton('Female'),
                  ],
                ),

                // Number of Passengers Radio Button Selection
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    'Number of Passengers:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [2, 3, 4, 5].map((int count) {
                    return Row(
                      children: [
                        Radio<int>(
                          value: count,
                          groupValue: _selectedPassengerCount,
                          activeColor: Color(0xFFEFD339),
                          onChanged: (value) {
                            setState(() {
                              _selectedPassengerCount = value!;
                            });
                          },
                        ),
                        Text(
                          count.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent, // Green button
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Submit Ride Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToMapSelection(
      BuildContext context, bool isPickup) async
  {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(
          initialLocation:
              isPickup ? _selectedPickupLocation : _selectedDropoffLocation,
        ),
      ),
    );

    if (selectedLocation != null) {
      LatLng? selected = selectedLocation['latLng'];
      String? placeName = selectedLocation['placeName'];

      final address = await _getAddressFromLatLng(selected!);

      setState(() {
        if (isPickup) {
          _selectedPickupLocation = selected;
          _pickupController.text = placeName ?? address;
        } else {
          _selectedDropoffLocation = selected;
          _dropoffController.text = placeName ?? address;
        }
      });
    }
  }

  // Location field builder
  Widget buildLocationField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: hasFocus ? 80 : 75,
              child: InkWell(
                onTap: onTap,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                      suffixIcon: const Icon(Icons.map, color: Colors.yellowAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.yellowAccent,
                          width: 3.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.lightGreenAccent,
                          width: 3.5,
                        ),
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please select $label' : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom TextField Builder
  Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8), // wider margin
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: hasFocus ? 80 : 75, // increase on focus
              child: TextFormField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.yellowAccent, // yellow
                      width: 3.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.lightGreenAccent, // green
                      width: 3.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter $label';
                  if (isNumber && int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom Radio Button Builder
  Widget buildRadioButton(String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: genderPreference,
          activeColor: Color(0xFFEFD339),
          onChanged: (newValue) {
            setState(() {
              genderPreference = newValue as String?;
            });
          },
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildTimeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: hasFocus ? 80 : 75,
              child: TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeController.text = pickedTime.format(context);
                    });
                  }
                },
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Preferred Time',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 22, horizontal: 18),
                  suffixIcon: const Icon(
                    Icons.access_time,
                    color: Colors.yellowAccent,
                    size: 28,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.yellowAccent,
                      width: 3.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.lightGreenAccent,
                      width: 3.5,
                    ),
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please select Preferred Time' : null,
              ),
            );
          },
        ),
      ),
    );
  }

}
