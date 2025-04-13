import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/CustomNavBar.dart';
import '../components/customAppBar.dart';

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
  final TextEditingController _passengerController = TextEditingController();

  String? genderPreference = "Any";
  String? status = "Pending";


  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to submit a ride request')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('RideRequests').add({
          'userId': user.uid,
          'pickupLocation': _pickupController.text,
          'dropoffLocation': _dropoffController.text,
          'preferredTime': _timeController.text,
          'genderPreference': genderPreference,
          'numberOfPassengers': int.parse(_passengerController.text),
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
        _passengerController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: const CustomAppBar(title: "Request a Ride"),
      drawer: const CustomNavBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF222222)], // Subtle dark gradient
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
                buildTextField('Pickup Location', _pickupController),
                buildTextField('Drop-off Location', _dropoffController),
                buildTextField('Preferred Time', _timeController),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    'Gender Preference:',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

                buildTextField('Number of Passengers', _passengerController, isNumber: true),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700], // Green button
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

  // Custom TextField Builder
  Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.yellow[700], // Yellow fields
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        validator: (value) {
          if (value!.isEmpty) return 'Enter $label';
          if (isNumber && int.tryParse(value) == null) return 'Enter a valid number';
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
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
