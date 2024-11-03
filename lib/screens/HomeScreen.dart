import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/clothing_service.dart';
import '../models/clothing_model.dart';
import '../models/user_model.dart';
import 'clothing_detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ClothingModel>> clothingItems;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color themeColor = Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    clothingItems = ClothingService().fetchClothingItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: themeColor,
        title: Text(
          'BOUTIQUE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Text(
                widget.user.login[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ClothingModel>>(
        future: clothingItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun vêtement disponible',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data!;
          int crossAxisCount =
              (MediaQuery.of(context).size.width / 150).floor();
          if (crossAxisCount < 2) crossAxisCount = 2;

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.80,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final clothing = items[index];
              Uint8List bytes = base64Decode(clothing.image);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClothingDetailScreen(
                        clothing: clothing,
                        user: widget.user,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.memory(
                            bytes,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clothing.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Taille ${clothing.size}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${clothing.price} €',
                                  style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Acheter',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Panier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: themeColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(user: widget.user),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: widget.user),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
