import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/CustomNavBar.dart';
import '../components/customAppBar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  final user = FirebaseAuth.instance.currentUser;
  bool isEditing = false;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("UserRegistration")
        .doc(user!.uid)
        .get();

    if (snapshot.exists) {
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>;
        nameController.text = userData!['name'] ?? '';
        mobileController.text = userData!['mobileNo'] ?? '';
      });
    }
  }

  Future<void> uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${user!.uid}.jpg');

    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("UserRegistration")
        .doc(user!.uid)
        .update({'profilePicUrl': imageUrl});

    setState(() {
      userData!['profilePicUrl'] = imageUrl;
    });
  }

  Future<void> saveProfileChanges() async {
    await FirebaseFirestore.instance
        .collection("UserRegistration")
        .doc(user!.uid)
        .update({
      'name': nameController.text.trim(),
      'mobileNo': mobileController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")));

    setState(() {
      userData!['name'] = nameController.text.trim();
      userData!['mobileNo'] = mobileController.text.trim();
      isEditing = false;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/LoginPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "My Profile"),
      drawer: const CustomNavBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF222222)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: userData == null
            ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: uploadProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userData!['profilePicUrl'] != null
                      ? NetworkImage(userData!['profilePicUrl'])
                      : null,
                  backgroundColor: Colors.yellow,
                  child: userData!['profilePicUrl'] == null
                      ? const Icon(Icons.person, size: 60, color: Colors.black)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              buildEditableField("Name", nameController),
              buildEditableField("Mobile No", mobileController),
              profileInfo("Email", userData!['email']),
              profileInfo("Gender", userData!['gender']),
              profileInfo("Date of Birth", userData!['DOB']),
              const SizedBox(height: 20),
              isEditing
                  ? ElevatedButton(
                onPressed: saveProfileChanges,
                child: const Text("Save"),
                style: elevatedButtonStyle(Colors.lightGreenAccent, Colors.black),
              )
                  : ElevatedButton(
                onPressed: () => setState(() => isEditing = true),
                child: const Text("Edit"),
                style: elevatedButtonStyle(Colors.yellowAccent, Colors.black),
              ),
              const SizedBox(height: 20),
              // buildMatchedRidesSection(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: elevatedButtonStyle(Colors.redAccent, Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey.shade900,
          contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.yellowAccent, width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.lightGreenAccent, width: 3),
          ),
        ),
      ),
    );
  }

  Widget profileInfo(String label, String? value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellowAccent, width: 2.5),
      ),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildMatchedRidesSection() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("RideMatches")
          .where('userIds', arrayContains: user?.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.yellow));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            "No matched rides yet",
            style: TextStyle(color: Colors.white70),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Matched Rides:",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    "${data['pickupLocation'].split(',')[0]} → ${data['dropoffLocation'].split(',')[0]}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Status: ${data['status']}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  ButtonStyle elevatedButtonStyle(Color bgColor, Color fgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}