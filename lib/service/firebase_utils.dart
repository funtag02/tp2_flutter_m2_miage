import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/model/article.dart';
import 'package:flutter_application_2/model/user.dart';

//// ARTICLE

Future<List<MapEntry<String, Article>>> getArticlesFromFirebase() async {
  final snapshot = await FirebaseFirestore.instance.collection('articles').get();
  return snapshot.docs
      .map((doc) => MapEntry(doc.id, Article.fromFirestore(doc.data())))
      .toList();
}

//// USER

// get user data from firebase
Future<User> getUserDataFromFirebase(String username) async {
  final doc = await FirebaseFirestore.instance
      .collection("User") // oui je sais c'est perturbant
      .doc(username)
      .get();

  if (doc.exists) {
    // convertis la data du document en objet User
    return User.fromFirestore(doc.data()!);
  } else {
    throw Exception("User not found");
  }
}

Future<void> updateUserDataInFirebase(String username, Map<String, dynamic> data) async {
  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("Utilisateur '$username' introuvable");
    }

    await snapshot.docs.first.reference.update(data);
  } catch (e) {
    throw Exception("Erreur lors de la mise à jour : $e");
  }
}