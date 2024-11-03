import 'package:cloud_firestore/cloud_firestore.dart';

class ClothingModel {
  final String category;
  final String image;
  final String brand;
  final double price;
  final String size;
  final String title;

  ClothingModel({
    required this.category,
    required this.image,
    required this.brand,
    required this.price,
    required this.size,
    required this.title,
  });

  // Factory method to create ClothingModel from a Map
  factory ClothingModel.fromMap(Map<String, dynamic> map) {
    return ClothingModel(
      category: map['categorie'] ?? '',
      image: map['image'] ?? '',
      brand: map['marque'] ?? '',
      price: (map['prix'] is double)
          ? map['prix']
          : (map['prix'] as num).toDouble(),
      size: map['taille'] ?? '',
      title: map['titre'] ?? '',
    );
  }

  // New method to create ClothingModel from a Firestore DocumentSnapshot
  factory ClothingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }
    return ClothingModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'categorie': category,
      'image': image,
      'marque': brand,
      'prix': price,
      'taille': size,
      'titre': title,
    };
  }
}
