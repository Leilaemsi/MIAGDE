import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../screens/HomeScreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF4A90E2).withOpacity(0.1),
              Colors.white,
              Colors.white,
              const Color(0xFF4A90E2).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Banner at the top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'MIAGED',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Wrapped the remaining content in Expanded and Center
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color:
                                      const Color(0xFF4A90E2).withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: _loginController,
                                      decoration: InputDecoration(
                                        labelText: 'Login',
                                        labelStyle:
                                            TextStyle(color: Colors.grey[600]),
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: const Color(0xFF4A90E2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4A90E2),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Veuillez entrer votre identifiant';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle:
                                            TextStyle(color: Colors.grey[600]),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: const Color(0xFF4A90E2),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: const Color(0xFF4A90E2),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4A90E2),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Veuillez entrer votre mot de passe';
                                        }
                                        return null;
                                      },
                                    ),
                                    if (_errorMessage != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    _isLoading = true;
                                                    _errorMessage = null;
                                                  });
                                                  try {
                                                    UserModel? user =
                                                        await FirebaseService()
                                                            .authenticateUser(
                                                      _loginController.text,
                                                      _passwordController.text,
                                                    );

                                                    if (user != null) {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              HomeScreen(
                                                                  user: user),
                                                        ),
                                                      );
                                                    } else {
                                                      setState(() {
                                                        _errorMessage =
                                                            'Identifiants incorrects';
                                                      });
                                                    }
                                                  } catch (e) {
                                                    setState(() {
                                                      _errorMessage =
                                                          'Une erreur est survenue';
                                                    });
                                                  } finally {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4A90E2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const Text(
                                                'Se connecter',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
