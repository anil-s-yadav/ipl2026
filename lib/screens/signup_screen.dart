import 'package:flutter/material.dart';
import 'package:ipl2026/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();

  static Widget _field(
    TextEditingController cnt,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      controller: cnt,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final AuthService _auth = AuthService();

  void signupUser() async {
    String? result = await _auth.signup(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: phoneController.text,
    );

    if (result == null) {
      print("Signup success");
    } else {
      print(result);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0f2027),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_cricket,
                    size: 60,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// NAME
                  SignupScreen._field(
                    nameController,
                    "Full Name",
                    Icons.person,
                  ),

                  const SizedBox(height: 15),

                  /// EMAIL
                  SignupScreen._field(emailController, "Email", Icons.email),

                  const SizedBox(height: 15),

                  /// PHONE
                  SignupScreen._field(
                    phoneController,
                    "Phone Number (optional)",
                    Icons.phone,
                  ),

                  const SizedBox(height: 15),

                  /// PASSWORD
                  SignupScreen._field(
                    passwordController,
                    "Password",
                    Icons.lock,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),

                  /// REFERRAL

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => signupUser(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 10,
                      ),
                      child: const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "By signing up you agree to Terms & Privacy",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SignupScreen()),
                    // ),
                    child: Text(
                      "Have account? Login",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
