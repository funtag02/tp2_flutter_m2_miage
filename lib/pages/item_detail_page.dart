import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailPage extends StatelessWidget {
  final Article article;
  final String articleId;
  final String username;

  const ItemDetailPage({
    super.key,
    required this.article,
    required this.articleId,
    required this.username,
  });

  Future<void> _addToBasket(BuildContext context) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur introuvable")),
        );
        return;
      }

      final userDoc = userSnapshot.docs.first;
      final ArticleRef = FirebaseFirestore.instance
          .collection('articles')
          .doc(articleId);

      // Récupère le panier actuel et ajoute la référence
      final dynamic basketData = userDoc.data()['basket'];
      final List<dynamic> basketRefs;
      if (basketData is List) {
        basketRefs = List.from(basketData);
      } else if (basketData is DocumentReference) {
        basketRefs = [basketData];
      } else {
        basketRefs = [];
      }

      basketRefs.add(ArticleRef);
      await userDoc.reference.update({'basket': basketRefs});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Article ajouté au panier ✓")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(article.imageBase64);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.memory(
              imageBytes,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            '${article.category.label} - ',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          Text(
                            article.brand,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${article.price.toStringAsFixed(2)} €',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
                      ),
                      Text(
                        'Taille : ${article.size}',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _addToBasket(context),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text(
                  'Ajouter au panier',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}