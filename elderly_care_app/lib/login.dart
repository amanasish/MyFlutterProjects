import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_styles.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://elderly-care-backend-giv2.onrender.com/api/userLogin',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Storing uniqueCode using SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('name', jsonData['data']['name']);
        await prefs.setString('email', jsonData['data']['email']);
        await prefs.setString('uniqueCode', jsonData['data']['uniqueCode']);

        // success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? 'Login successful')),
        );

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomTabScreen(showWelcome: true),
          ),
        );
      } else {
        // If Failed login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //frnted

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ClipOval(
                child: Image.asset(
                  'assets/icons/LogImg1.png',
                  height: 220,
                  width: 220,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              Text(
                'Login to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              SizedBox(height: 32),

              // Email Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Login Button
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: loginUser,
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 16),

              // Register Link
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  "Don't have an account? Register here!",
                  style: TextStyle(color: Colors.teal.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
