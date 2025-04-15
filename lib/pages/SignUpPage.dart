


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
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User registration failed. Please try again.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection("UserRegistration").doc(
            user.uid).set({
          "userId": user.uid,
          "name": nameController.text.trim(),
          "mobileNo": mobileController.text.trim(),
          "email": emailController.text.trim(),
          "gender": selectedGender,
          "DOB": selectedDOB != null ? DateFormat('yyyy-MM-dd').format(
              selectedDOB!) : null,
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
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                buildTextField("Mobile No", mobileController,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 15),
                buildTextField("Email", emailController,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                buildTextField(
                    "Password", passwordController, isPassword: true),
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
                    backgroundColor: Colors.lightGreenAccent,
                    // Green Button
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .yellowAccent, // Bright Yellow for Highlight
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
  Widget buildTextField(String label, TextEditingController controller, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus
                .of(context)
                .hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: hasFocus ? 80 : 75,
              child: TextFormField(
                controller: controller,
                obscureText: isPassword,
                keyboardType: keyboardType ?? TextInputType.text,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 22, horizontal: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.yellowAccent,
                      width: 2.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.lightGreenAccent,
                      width: 2.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter $label';
                  if (isPassword && value.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
            );
          },
        ),
      ),
    );
  }


  // Gender Dropdown
  Widget buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus
                .of(context)
                .hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: hasFocus ? 80 : 75,
              child: DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(
                  hintText: "Gender",
                  hintStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  // Background color
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 22, horizontal: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.yellowAccent,
                      width: 2.5,
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
                dropdownColor: Colors.grey.shade900,
                // Dropdown color
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                // Text color of selected item
                items: ["Male", "Female", "Other"].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender), // Text color inside the dropdown
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                validator: (value) => value == null ? "Select gender" : null,
              ),
            );
          },
        ),
      ),
    );
  }


  // Date Picker for DOB
  Widget buildDOBPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus
                .of(context)
                .hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: hasFocus ? 80 : 75,
              child: InkWell(
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
                    hintText: "Date of Birth",
                    hintStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.yellowAccent,
                        width: 2.5,
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
                  child: Text(
                    selectedDOB == null
                        ? "Date of Birth"
                        : DateFormat('yyyy-MM-dd').format(selectedDOB!),
                    style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold), // Text color
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
