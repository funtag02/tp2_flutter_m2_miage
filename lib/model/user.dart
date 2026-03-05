// genere une classe user qui correspond aux champs specifies dans la profile page
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String login;
  final String password;
  final DateTime anniversaire;
  final String adresse;
  final String codePostal;
  final String ville;

  User({
    required this.login,
    required this.password,
    required this.anniversaire,
    required this.adresse,
    required this.codePostal,
    required this.ville,
  });

  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      login: data['username'] ?? '',
      password: data['password'] ?? '',
      anniversaire: (data['birth_day'] as Timestamp).toDate(),
      adresse: data['adress'] ?? '',
      codePostal: data['postcode'] ?? '',
      ville: data['city'] ?? '',
    );
  }
}