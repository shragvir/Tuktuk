import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuktuk/pages/SignUpPage.dart';

/*
class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(
    builder: (context) => const LoginPage(),
  );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUserWithEmailAndPassword() async {
    try {
      final userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print(userCredential);
      Navigator.pushNamed(context, '/HomePage');
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign In.',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await loginUserWithEmailAndPassword();
                },
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, SignUpPage.route());
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account? ',
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
    );
  }
}*/

import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(
    builder: (context) => const LoginPage(),
  );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>{
  final TextEditingController _emails = TextEditingController();
  final TextEditingController _pw = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emails.dispose();
    _pw.dispose();
    super.dispose();
  }


  Future<void> loginUserWithEmailAndPassword() async {
    try {
      final userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emails.text.trim(),
        password: _pw.text.trim(),
      );
      print(userCredential);
      Navigator.pushNamed(context, '/RideRequestPage');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed!")),
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
          "Login",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color:Colors.white),
        ),
        backgroundColor: Colors.green[700], // Rich Green Header
        foregroundColor: Colors.black,
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
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email Input
                buildTextField("Email", _emails, isPassword: false),

                const SizedBox(height: 15),

                // Password Input
                buildTextField("Password", _pw, isPassword: true),

                const SizedBox(height: 25),

                // Sign In Button
                ElevatedButton(
                  onPressed: () async {
                    await loginUserWithEmailAndPassword();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent, // Rich Green Button
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("SIGN IN"),
                ),

                const SizedBox(height: 20),

                // Sign Up Navigation
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, SignUpPage.route());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellowAccent, // Bright Yellow for Highlight
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
                controller: controller,
                obscureText: isPassword,
                keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
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
                validator: (value) {
                  if (value!.isEmpty) return 'Enter $label';
                  if (isPassword && value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
            );
          },
        ),
      ),
    );
  }

}
