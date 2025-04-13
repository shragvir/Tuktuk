// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../components/CustomNavBar.dart';
// import '../components/customAppBar.dart';
//
// class RideRequestPage extends StatefulWidget {
//   const RideRequestPage({super.key});
//
//   @override
//   RideRequestState createState() => RideRequestState();
// }
//
// class RideRequestState extends State<RideRequestPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _pickupController = TextEditingController();
//   final TextEditingController _dropoffController = TextEditingController();
//   final TextEditingController _timeController = TextEditingController();
//   final TextEditingController _passengerController = TextEditingController();
//
//   String? genderPreference = "Any";
//   String? status = "Pending";
//
//
//   Future<void> submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       User? user = FirebaseAuth.instance.currentUser;
//
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You must be logged in to submit a ride request')),
//         );
//         return;
//       }
//
//       try {
//         await FirebaseFirestore.instance.collection('RideRequests').add({
//           'userId': user.uid,
//           'pickupLocation': _pickupController.text,
//           'dropoffLocation': _dropoffController.text,
//           'preferredTime': _timeController.text,
//           'genderPreference': genderPreference,
//           'numberOfPassengers': int.parse(_passengerController.text),
//           'createdAt': Timestamp.now(),
//           'status': "Pending",
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ride Request Submitted!')),
//         );
//
//         _formKey.currentState!.reset();
//         _pickupController.clear();
//         _dropoffController.clear();
//         _timeController.clear();
//         _passengerController.clear();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error submitting request: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Dark background
//       appBar: const CustomAppBar(title: "Request a Ride"),
//       drawer: const CustomNavBar(),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Color(0xFF222222)], // Subtle dark gradient
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 buildTextField('Pickup Location', _pickupController),
//                 buildTextField('Drop-off Location', _dropoffController),
//                 buildTextField('Preferred Time', _timeController),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: const Text(
//                     'Gender Preference:',
//                     style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     buildRadioButton('Any'),
//                     buildRadioButton('Male'),
//                     buildRadioButton('Female'),
//                   ],
//                 ),
//
//                 buildTextField('Number of Passengers', _passengerController, isNumber: true),
//
//                 const SizedBox(height: 20),
//
//                 ElevatedButton(
//                   onPressed: submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green[700], // Green button
//                     foregroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   child: const Text('Submit Ride Request'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Custom TextField Builder
//   Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
//           filled: true,
//           fillColor: Colors.yellow[700], // Yellow fields
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         validator: (value) {
//           if (value!.isEmpty) return 'Enter $label';
//           if (isNumber && int.tryParse(value) == null) return 'Enter a valid number';
//           return null;
//         },
//       ),
//     );
//   }
//
//   // Custom Radio Button Builder
//   Widget buildRadioButton(String value) {
//     return Row(
//       children: [
//         Radio(
//           value: value,
//           groupValue: genderPreference,
//           activeColor: Colors.yellow[700],
//           onChanged: (newValue) {
//             setState(() {
//               genderPreference = newValue as String?;
//             });
//           },
//         ),
//         Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }
//

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
//
// import '../components/CustomNavBar.dart';
// import '../components/customAppBar.dart';
// import 'MapSelectionPage.dart';
//
// class RideRequestPage extends StatefulWidget {
//   const RideRequestPage({super.key});
//
//   @override
//   RideRequestState createState() => RideRequestState();
// }
//
// class RideRequestState extends State<RideRequestPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _pickupController = TextEditingController();
//   final TextEditingController _dropoffController = TextEditingController();
//   final TextEditingController _timeController = TextEditingController();
//   final TextEditingController _passengerController = TextEditingController();
//
//   String? genderPreference = "Any";
//   LatLng? _selectedPickupLocation;
//   LatLng? _selectedDropoffLocation;
//
//   Future<void> submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       User? user = FirebaseAuth.instance.currentUser;
//
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('You must be logged in to submit a ride request')),
//         );
//         return;
//       }
//
//       try {
//         await FirebaseFirestore.instance.collection('RideRequests').add({
//           'userId': user.uid,
//           'pickupLocation': _pickupController.text,
//           'pickupCoordinates': GeoPoint(_selectedPickupLocation!.latitude,
//               _selectedPickupLocation!.longitude),
//           'dropoffLocation': _dropoffController.text,
//           'dropoffCoordinates': GeoPoint(_selectedDropoffLocation!.latitude,
//               _selectedDropoffLocation!.longitude),
//           'preferredTime': _timeController.text,
//           'genderPreference': genderPreference,
//           'numberOfPassengers': int.parse(_passengerController.text),
//           'createdAt': Timestamp.now(),
//           'status': "Pending",
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ride Request Submitted!')),
//         );
//
//         _formKey.currentState!.reset();
//         _pickupController.clear();
//         _dropoffController.clear();
//         _timeController.clear();
//         _passengerController.clear();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error submitting request: $e')),
//         );
//       }
//     }
//   }
//
//   Future<String> _getAddressFromLatLng(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//           position.latitude, position.longitude);
//
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         return "${place.name}, ${place.locality}, ${place.administrativeArea}";
//       } else {
//         return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
//       }
//     } catch (e) {
//       print("Geocoding error: $e");
//       return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: const CustomAppBar(title: "Request a Ride"),
//       drawer: const CustomNavBar(),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Color(0xFF222222)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 // Pickup Location Field
//                 buildLocationField(
//                   label: 'Pickup Location',
//                   controller: _pickupController,
//                   onTap: () => _navigateToMapSelection(context, true),
//                 ),
//
//                 // Drop-off Location Field
//                 buildLocationField(
//                   label: 'Drop-off Location',
//                   controller: _dropoffController,
//                   onTap: () => _navigateToMapSelection(context, false),
//                 ),
//
//                 buildTextField('Preferred Time', _timeController),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: const Text(
//                     'Gender Preference:',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     buildRadioButton('Any'),
//                     buildRadioButton('Male'),
//                     buildRadioButton('Female'),
//                   ],
//                 ),
//
//                 buildTextField('Number of Passengers', _passengerController,
//                     isNumber: true),
//
//                 const SizedBox(height: 20),
//
//                 ElevatedButton(
//                   onPressed: submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green[700],
//                     foregroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     textStyle: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   child: const Text('Submit Ride Request'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _navigateToMapSelection(
//       BuildContext context, bool isPickup) async {
//     final selectedLocation = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MapSelectionPage(
//           initialLocation: isPickup ? _selectedPickupLocation : _selectedDropoffLocation,
//         ),
//       ),
//     );
//
//     if (selectedLocation != null) {
//       LatLng? selected = selectedLocation['latLng'];
//       String? placeName = selectedLocation['placeName'];
//
//       final address = await _getAddressFromLatLng(selected!); // assuming this returns something meaningful
//
//       setState(() {
//         if (isPickup) {
//           _selectedPickupLocation = selected;
//           _pickupController.text = placeName ?? address;
//         } else {
//           _selectedDropoffLocation = selected;
//           _dropoffController.text = placeName ?? address;
//         }
//       });
//     }
//   }
//
//
//   /*Future<String> _getAddressFromLatLng(LatLng position) async {
//     // In a real app, you would use a geocoding service here
//     // For simplicity, we'll just return coordinates
//     return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
//   }*/
//
//   Widget buildLocationField({
//     required String label,
//     required TextEditingController controller,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: InkWell(
//         onTap: onTap,
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: controller,
//             decoration: InputDecoration(
//               labelText: label,
//               labelStyle: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold),
//               filled: true,
//               fillColor: Colors.yellow[700],
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               suffixIcon: const Icon(Icons.map, color: Colors.black),
//             ),
//             style: const TextStyle(
//                 color: Colors.black, fontWeight: FontWeight.bold),
//             validator: (value) =>
//                 value!.isEmpty ? 'Please select $label' : null,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Custom TextField Builder
//   Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(
//               color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
//           filled: true,
//           fillColor: Colors.yellow[700], // Yellow fields
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         style:
//             const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         validator: (value) {
//           if (value!.isEmpty) return 'Enter $label';
//           if (isNumber && int.tryParse(value) == null)
//             return 'Enter a valid number';
//           return null;
//         },
//       ),
//     );
//   }
//
//   // Custom Radio Button Builder
//   Widget buildRadioButton(String value) {
//     return Row(
//       children: [
//         Radio(
//           value: value,
//           groupValue: genderPreference,
//           activeColor: Colors.yellow[700],
//           onChanged: (newValue) {
//             setState(() {
//               genderPreference = newValue as String?;
//             });
//           },
//         ),
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }
// // ... [Keep your existing buildTextField and buildRadioButton methods] ...


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to submit a ride request')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('RideRequests').add({
          'userId': user.uid,
          'pickupLocation': _pickupController.text,
          'pickupCoordinates': GeoPoint(_selectedPickupLocation!.latitude,
              _selectedPickupLocation!.longitude),
          'dropoffLocation': _dropoffController.text,
          'dropoffCoordinates': GeoPoint(_selectedDropoffLocation!.latitude,
              _selectedDropoffLocation!.longitude),
          'preferredTime': _timeController.text,
          'genderPreference': genderPreference,
          'numberOfPassengers': _selectedPassengerCount,
          'createdAt': Timestamp.now(),
          'status': "Pending",
        });

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
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

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
                          activeColor: Colors.yellow[700],
                          onChanged: (value) {
                            setState(() {
                              _selectedPassengerCount = value!;
                            });
                          },
                        ),
                        Text(
                          count.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
      BuildContext context, bool isPickup) async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(
          initialLocation: isPickup ? _selectedPickupLocation : _selectedDropoffLocation,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              filled: true,
              fillColor: Colors.yellow[700],
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: const Icon(Icons.map, color: Colors.black),
            ),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            validator: (value) =>
            value!.isEmpty ? 'Please select $label' : null,
          ),
        ),
      ),
    );
  }

  // Custom TextField Builder
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.yellow[700], // Yellow fields
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        style:
        const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        validator: (value) {
          if (value!.isEmpty) return 'Enter $label';
          return null;
        },
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
          activeColor: Colors.yellow[700],
          onChanged: (newValue) {
            setState(() {
              genderPreference = newValue as String?;
            });
          },
        ),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildTimeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        controller: _timeController,
        readOnly: true,
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );
          if (pickedTime != null) {
            setState(() {
              _timeController.text = pickedTime.format(context); // in 24-hour format
            });
          }
        },
        decoration: InputDecoration(
          labelText: 'Preferred Time',
          labelStyle: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.yellow[700],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),  // Slightly rounded corners
            borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),  // Yellow border with custom width
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),  // Increased padding for better space
          suffixIcon: const Icon(
            Icons.access_time,
            color: Colors.black,
            size: 28,  // Larger icon size
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),  // Focused border color and thickness
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
          ),
        ),
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),  // Larger text for better readability
        validator: (value) =>
        value!.isEmpty ? 'Please select Preferred Time' : null,
      ),
    );
  }


}
