import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';
import 'add_clothing_screen.dart';
import 'HomeScreen.dart';
import 'cart_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late TextEditingController _anniversaireController;
  late TextEditingController _adresseController;
  late TextEditingController _codePostalController;
  late TextEditingController _villeController;
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  // Custom colors
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2D3436);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color dangerColor = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController(text: widget.user.login);
    _passwordController = TextEditingController(text: widget.user.password);
    _anniversaireController =
        TextEditingController(text: widget.user.anniversaire);
    _adresseController = TextEditingController(text: widget.user.adresse);
    _codePostalController = _codePostalController =
        TextEditingController(text: widget.user.codePostal.toStringAsFixed(0));

    _villeController = TextEditingController(text: widget.user.ville);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? dangerColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final updatedUser = UserModel(
          login: _loginController.text,
          password: _passwordController.text,
          anniversaire: _anniversaireController.text,
          adresse: _adresseController.text,
          codePostal: double.parse(_codePostalController.text),
          ville: _villeController.text,
          panier: widget.user.panier,
        );

        await _firebaseService.updateUser(updatedUser);

        setState(() {
          widget.user.login = updatedUser.login;
          widget.user.password = updatedUser.password;
          widget.user.anniversaire = updatedUser.anniversaire;
          widget.user.adresse = updatedUser.adresse;
          widget.user.codePostal = updatedUser.codePostal;
          widget.user.ville = updatedUser.ville;
        });

        _showSnackBar('Profil mis à jour avec succès');
      } catch (e) {
        _showSnackBar('Erreur lors de la mise à jour: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String errorText,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: primaryColor.withOpacity(0.8),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = primaryColor,
    Color textColor = Colors.white,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Mise à jour du profil...',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: primaryColor,
                            child: Icon(Icons.person,
                                size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.user.login,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _loginController,
                      label: 'Login',
                      errorText: 'Veuillez entrer votre login',
                      readOnly: true,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      errorText: 'Veuillez entrer un mot de passe',
                      obscureText: true,
                    ),
                    _buildTextField(
                      controller: _anniversaireController,
                      label: 'Date d\'anniversaire',
                      errorText: 'Veuillez entrer votre date d\'anniversaire',
                    ),
                    _buildTextField(
                      controller: _adresseController,
                      label: 'Adresse',
                      errorText: 'Veuillez entrer votre adresse',
                    ),
                    _buildTextField(
                      controller: _codePostalController,
                      label: 'Code postal',
                      errorText: 'Veuillez entrer votre code postal',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField(
                      controller: _villeController,
                      label: 'Ville',
                      errorText: 'Veuillez entrer votre ville',
                    ),
                    const SizedBox(height: 24),
                    _buildButton(
                      text: 'Valider',
                      onPressed: _saveProfile,
                      icon: Icons.save,
                    ),
                    _buildButton(
                      text: 'Ajouter un vêtement',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddClothingScreen(),
                          ),
                        );
                      },
                      backgroundColor: successColor,
                      icon: Icons.add_circle_outline,
                    ),
                    _buildButton(
                      text: 'Se déconnecter',
                      onPressed: () => _logout(),
                      backgroundColor: dangerColor,
                      icon: Icons.logout,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shop),
              label: 'Acheter',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Panier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: 2,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(user: widget.user),
                ),
              );
            } else if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(user: widget.user),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _anniversaireController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    super.dispose();
  }
}
