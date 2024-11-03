class CartItemModel {
  final int id; // ID of the item
  final String imageUrl;
  final String titre;
  final String taille;
  final double prix;

  CartItemModel({
    required this.id,
    required this.imageUrl,
    required this.titre,
    required this.taille,
    required this.prix,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? 0, // Use 0 as a default if id is null
      imageUrl: map['imageUrl'] ?? '',
      titre: map['titre'] ?? '',
      taille: map['taille'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'titre': titre,
      'taille': taille,
      'prix': prix,
    };
  }
}
