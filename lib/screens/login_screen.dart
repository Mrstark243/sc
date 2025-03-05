import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'teacher_home_screen.dart';
import 'student_home_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildGradient(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(nameController, 'Name', Icons.person),
                    const SizedBox(height: 10),
                    _buildTextField(
                      passwordController,
                      'Password',
                      Icons.lock,
                      obscure: true,
                    ),
                    const SizedBox(height: 20),
                    _buildLoginButton(context),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Don\'t have an account? Register',
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Colors.deepPurpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        bool loggedIn = await Provider.of<UserProvider>(
          context,
          listen: false,
        ).loginUser(nameController.text, passwordController.text);
        if (loggedIn) {
          String role =
              Provider.of<UserProvider>(context, listen: false).user!.role;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      role == 'teacher'
                          ? TeacherHomeScreen()
                          : StudentHomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please check your credentials.'),
            ),
          );
        }
      },
      child: const Text('Login'),
    );
  }
}
