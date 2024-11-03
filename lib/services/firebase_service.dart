import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Authenticate user by login and password without hashing for testing
  /// Returns UserModel if authentication is successful, otherwise null
  Future<UserModel?> authenticateUser(String login, String password) async {
    try {
      print("Attempting login for user: $login");

      QuerySnapshot querySnapshot = await _firestore
          .collection('Utilisateurs')
          .where('login', isEqualTo: login.toLowerCase())
          .limit(1)
          .get();

      print("Number of documents found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        var data = userDoc.data() as Map<String, dynamic>;

        // Debug print to see the document's structure and content
        print("Document ID: ${userDoc.id}");
        print("Document Data: $data");

        data.forEach((key, value) {
          print("Key: '$key', Value: '$value', Type: ${value.runtimeType}");
        });

        // Attempt to access the password field
        var storedPassword =
            data.keys.contains('password') ? data['password'] : null;

        if (storedPassword == null) {
          print("Password field is null or improperly formatted.");
          return null;
        }

        if (password == storedPassword) {
          print("User authenticated successfully.");
          return UserModel.fromDocument(userDoc);
        } else {
          print("Password does not match or is incorrectly formatted.");
          return null;
        }
      } else {
        print("No user found with the provided login.");
        return null;
      }
    } catch (e) {
      print("Authentication error: $e");
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      // Query the collection to find the document with the matching `login` field
      var querySnapshot = await _firestore
          .collection('Utilisateurs')
          .where('login', isEqualTo: user.login)
          .get();

      // Check if the document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the first matching document
        String documentId = querySnapshot.docs.first.id;

        // Update the document using the retrieved document ID
        await _firestore
            .collection('Utilisateurs')
            .doc(documentId)
            .update(user.toMap());

        print("User profile updated successfully.");
      } else {
        print("Error: No user found with the specified login.");
        throw Exception("No user found with the specified login.");
      }
    } catch (e) {
      print("Error updating user: $e");
      throw e;
    }
  }
}
