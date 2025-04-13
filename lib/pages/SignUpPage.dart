/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuktuk/pages/LoginPage.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(
    builder: (context) => const SignUpPage(),
  );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print(userCredential.user?.uid);
      Navigator.pushReplacement(context, LoginPage.route());

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Sign up failed!")),
      );
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color:Colors.white),
        ),
        backgroundColor: Colors.green[700], // Rich Green Header
        foregroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        */
/*leading: IconButton( // Back Button
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(context, LoginPage.route());
          },
        ),*//*

      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF222222)], // Subtle dark gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email Input
                buildTextField("Email", emailController, isPassword: false),

                const SizedBox(height: 15),

                // Password Input
                buildTextField("Password", passwordController, isPassword: true),

                const SizedBox(height: 25),

                // Sign Up Button
                ElevatedButton(
                  onPressed: () async { await createUserWithEmailAndPassword();},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700], // Green Button
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("SIGN UP"),
                ),

                const SizedBox(height: 20),

                // Sign In Navigation
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, LoginPage.route());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow[700], // Bright Yellow for Highlight
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Input Field Builder
  Widget buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.yellow[700], // Bright Yellow Fields
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      validator: (value) {
        if (value!.isEmpty) return 'Enter $label';
        if (isPassword && value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }
}*/


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting Date
import 'package:tuktuk/pages/LoginPage.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(
    builder: (context) => const SignUpPage(),
  );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? selectedGender;
  DateTime? selectedDOB;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registration failed. Please try again.')),
          );
          return;
        }

        try {
          await FirebaseFirestore.instance.collection("UserRegistration").doc(user.uid).set({
            "userId": user.uid,
            "name": nameController.text.trim(),
            "mobileNo": mobileController.text.trim(),
            "email": emailController.text.trim(),
            "gender": selectedGender,
            "DOB": selectedDOB != null ? DateFormat('yyyy-MM-dd').format(selectedDOB!) : null,
            "createdAt": Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account Created Successfully!')),
          );

          nameController.clear();
          mobileController.clear();
          emailController.clear();
          passwordController.clear();

          Navigator.pushReplacement(context, LoginPage.route());
        } catch (firestoreError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving user data: $firestoreError')),
          );
        }
      } on FirebaseAuthException catch (authError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authError.message ?? "Sign up failed!")),
        );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700], // Rich Green Header
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF222222)], // Subtle dark gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                buildTextField("Name", nameController),
                const SizedBox(height: 15),
                buildTextField("Mobile No", mobileController, keyboardType: TextInputType.phone),
                const SizedBox(height: 15),
                buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                buildTextField("Password", passwordController, isPassword: true),
                const SizedBox(height: 15),

                // Gender Dropdown
                buildGenderDropdown(),

                const SizedBox(height: 15),

                // Date Picker for DOB
                buildDOBPicker(),

                const SizedBox(height: 25),

                // Sign Up Button
                ElevatedButton(
                  onPressed: createUserWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700], // Green Button
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("SIGN UP"),
                ),

                const SizedBox(height: 20),

                // Sign In Navigation
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, LoginPage.route());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow[700], // Bright Yellow for Highlight
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Input Field Builder
  Widget buildTextField(String label, TextEditingController controller, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.yellow[700], // Bright Yellow Fields
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      validator: (value) {
        if (value!.isEmpty) return 'Enter $label';
        if (isPassword && value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  // Gender Dropdown
  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: "Gender",
        filled: true,
        fillColor: Colors.yellow[700],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: ["Male", "Female", "Other"].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedGender = value;
        });
      },
      validator: (value) => value == null ? "Select gender" : null,
    );
  }

  // Date Picker for DOB
  Widget buildDOBPicker() {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDOB = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Date of Birth",
          filled: true,
          fillColor: Colors.yellow[700],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          selectedDOB == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(selectedDOB!),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
