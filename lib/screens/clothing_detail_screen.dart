import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tp2/screens/HomeScreen.dart';
import '../models/clothing_model.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class ClothingDetailScreen extends StatefulWidget {
  final ClothingModel clothing;
  final UserModel user;

  const ClothingDetailScreen({
    Key? key,
    required this.clothing,
    required this.user,
  }) : super(key: key);

  @override
  _ClothingDetailScreenState createState() => _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends State<ClothingDetailScreen> {
  int _currentIndex = 0;
  final Color themeColor = Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.clothing.title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400,
              width: double.infinity,
              child: Stack(
                children: [
                  Hero(
                    tag: 'clothing-${widget.clothing.title}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: MemoryImage(
                            base64Decode(widget.clothing.image),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clothing.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.clothing.price} €',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildInfoRow('Catégorie', widget.clothing.category),
                  _buildInfoRow('Taille', widget.clothing.size),
                  _buildInfoRow('Marque', widget.clothing.brand),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => addToPanier(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Ajouter au panier',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Retour',
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _onNavigationTap(int index) {
    setState(() => _currentIndex = index);

    final routes = {
      0: () => HomeScreen(user: widget.user),
      1: () => CartScreen(user: widget.user),
      2: () => ProfileScreen(user: widget.user),
    };

    if (routes.containsKey(index)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => routes[index]!()),
      );
    }
  }

  Future<void> addToPanier(BuildContext context) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Utilisateurs');
      QuerySnapshot querySnapshot =
          await users.where('login', isEqualTo: widget.user.login).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        var userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> panier = userData['Panier'] ?? [];

        CartItemModel newItem = CartItemModel(
          id: panier.length,
          imageUrl: widget.clothing.image,
          prix: widget.clothing.price,
          taille: widget.clothing.size,
          titre: widget.clothing.title,
        );

        await users.doc(userDoc.id).update({
          'Panier': FieldValue.arrayUnion([newItem.toMap()])
        });

        setState(() {
          widget.user.panier.add(newItem);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Produit ajouté au panier!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        _showErrorSnackBar(context, 'Utilisateur non trouvé!');
      }
    } catch (e) {
      print('Erreur: $e');
      _showErrorSnackBar(context, 'Erreur lors de l\'ajout au panier!');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
