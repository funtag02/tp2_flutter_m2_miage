import 'package:flutter/material.dart';
import 'package:flutter_application_2/service/firebase_utils.dart';
import 'package:flutter_application_2/model/user.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _anniversaireController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();

  final chefUseraname = "chef";
  final chefsDocname = "admin_001";
  
  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _anniversaireController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  void _populateFields(User user) {
    _loginController.text = user.login;
    _passwordController.text = user.password;
    _anniversaireController.text =
        "${user.anniversaire.day.toString().padLeft(2, '0')}/"
        "${user.anniversaire.month.toString().padLeft(2, '0')}/"
        "${user.anniversaire.year}";
    _adresseController.text = user.adresse;
    _codePostalController.text = user.codePostal;
    _villeController.text = user.ville;
  }

  Future<void> _saveToFirebase() async {
    try {
      // jsp pourquoi le username ne marche pas si j'utilise la variable finale definie au dessus
      await updateUserDataInFirebase("chef", {
        'password': _passwordController.text,
        'adress': _adresseController.text,
        'postcode': _codePostalController.text,
        'city': _villeController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil de l\'utilisateur'),
      ),
      body: FutureBuilder<User>(
        future: getUserDataFromFirebase(chefsDocname),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("User data not found"));
          }

          // Populate les champs une seule fois quand les données arrivent
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _populateFields(snapshot.data!);
          });

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _loginController,
                  decoration: InputDecoration(labelText: 'Login'),
                  readOnly: true,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: _anniversaireController,
                  decoration: InputDecoration(
                    labelText: 'Anniversaire',
                    hintText: 'jj/mm/aaaa',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: snapshot.data!.anniversaire,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _anniversaireController.text =
                          "${picked.day.toString().padLeft(2, '0')}/"
                          "${picked.month.toString().padLeft(2, '0')}/"
                          "${picked.year}";
                    }
                  },
                ),
                TextField(
                  controller: _adresseController,
                  decoration: InputDecoration(labelText: 'Adresse'),
                ),
                TextField(
                  controller: _codePostalController,
                  decoration: InputDecoration(labelText: 'Code Postal'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _villeController,
                  decoration: InputDecoration(labelText: 'Ville'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(Colors.deepPurple),
                  ),
                  onPressed: _saveToFirebase,
                  child:
                      Text('Valider', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                        Color.fromARGB(255, 243, 16, 0)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Se déconnecter',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}