import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/clothing_service.dart';
import 'HomeScreen.dart';
import 'profile_screen.dart';

class CartScreen extends StatefulWidget {
  final UserModel user;

  const CartScreen({Key? key, required this.user}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ClothingService _clothingService = ClothingService();

  @override
  Widget build(BuildContext context) {
    double total = widget.user.panier.fold(0, (sum, item) => sum + item.prix);
    final Color themeColor = Color(0xFF4A90E2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Panier',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        automaticallyImplyLeading: false,
      ),
      body: widget.user.panier.isEmpty
          ? Center(
              child: Text(
                'Le panier est vide.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.user.panier.length,
                    itemBuilder: (context, index) {
                      final item = widget.user.panier[index];

                      // Decode the base64 image
                      String base64Image = item.imageUrl;
                      Uint8List bytes = base64Decode(base64Image);

                      return ListTile(
                        leading: Image.memory(
                          bytes,
                          width: 70, // Increased size
                          height: 70, // Increased size
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          item.titre,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Taille: ${item.taille}\nPrix: ${item.prix} €',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.clear, color: Colors.red),
                          onPressed: () async {
                            final removedItem = widget.user.panier[index];

                            setState(() {
                              widget.user.panier.removeAt(index);
                            });

                            // Remove from Firestore
                            await _clothingService.deleteClothing(
                                removedItem.id, widget.user.login);

                            // Use addPostFrameCallback to display the SnackBar after the frame stabilizes
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && widget.user.panier.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${removedItem.titre} supprimé du panier.'),
                                  ),
                                );
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: ${total.toStringAsFixed(2)} €',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeColor),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Acheter'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: 1,
        selectedItemColor: themeColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(user: widget.user)),
            );
          } else if (index == 2) {
            // Si l'utilisateur sélectionne l'onglet "Profil"
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: widget.user),
              ),
            );
          }
        },
      ),
    );
  }
}
