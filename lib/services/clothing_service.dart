import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clothing_model.dart';
import '../models/user_model.dart'; // Assure-toi que ce chemin est correct
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ClothingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ClothingModel>> fetchClothingItems() async {
    try {
      final QuerySnapshot result = await _db.collection('Vetements').get();

      // Logging data for debugging
      for (var doc in result.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print(data);

        // Logging each key-value pair
        data.forEach((key, value) {
          print("Key: '$key', Value: '$value', Type: ${value.runtimeType}");
        });
      }

      // Creating a list of ClothingModel using fromDocument
      final List<ClothingModel> clothingItems = result.docs.map((doc) {
        return ClothingModel.fromDocument(doc); // Use fromDocument here
      }).toList();

      return clothingItems;
    } catch (e) {
      print("Error fetching clothing items: $e");
      return [];
    }
  }

  // Method to display or process clothingItems if needed
  void afficherClothingItems(List<ClothingModel> clothingItems) {
    for (var item in clothingItems) {
      print(
          item); // Adjust according to your ClothingModel's toString implementation
    }
  }

  Future<void> addClothing(ClothingModel clothing) async {
    try {
      await _db.collection('Vetements').add(clothing.toMap());
    } catch (e) {
      print("Error adding clothing: $e");
      throw e;
    }
  }

  Future<void> deleteClothing(int clothingId, String login) async {
    try {
      // Récupérer l'utilisateur par login depuis Firestore
      QuerySnapshot querySnapshot = await _db
          .collection('Utilisateurs')
          .where('login', isEqualTo: login.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        var data = userDoc.data() as Map<String, dynamic>;

        // Créer une instance de UserModel à partir des données
        UserModel userModel = UserModel.fromMap(data);

        // Supprime l'article du panier localement
        userModel.panier.removeWhere((item) => item.id == clothingId);

        // Met à jour Firestore
        await _db.collection('Utilisateurs').doc(userDoc.id).update({
          'Panier': userModel.panier.map((item) => item.toMap()).toList(),
        });

        print(
            "Article $clothingId supprimé du panier de l'utilisateur $login.");
      } else {
        print("Aucun utilisateur trouvé avec le login: $login.");
      }
    } catch (e) {
      print("Erreur lors de la suppression de l'article du panier: $e");
      throw e;
    }
  }
}
