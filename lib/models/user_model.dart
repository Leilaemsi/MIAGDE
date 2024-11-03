import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class UserModel {
  String login;
  String password;
  String anniversaire;
  String adresse;
  double codePostal;
  String ville;
  List<CartItemModel> panier;

  UserModel({
    required this.login,
    required this.password,
    required this.anniversaire,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.panier, // Update to CartItemModel
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    var cartItems = (map['Panier'] as List<dynamic>?)
            ?.map((item) => CartItemModel.fromMap(item))
            .toList() ??
        [];

    return UserModel(
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      anniversaire: map['anniversaire'] ?? '',
      adresse: map['adresse'] ?? '',
      codePostal: (map['codePostal'] ?? 0).toDouble(),
      ville: map['ville'] ?? '',
      panier: cartItems, // Update to CartItemModel
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'login': login,
      'password': password,
      'anniversaire': anniversaire,
      'adresse': adresse,
      'codePostal': codePostal,
      'ville': ville,
      'Panier': panier
          .map((item) => item.toMap())
          .toList(), // Update to CartItemModel
    };
  }
}
