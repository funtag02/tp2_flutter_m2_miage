import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/model/article.dart';

class ItemsBasketPage extends StatefulWidget {
  final String username;

  const ItemsBasketPage({required this.username});

  @override
  _ItemsBasketPageState createState() => _ItemsBasketPageState();
}

class _ItemsBasketPageState extends State<ItemsBasketPage> {
  List<MapEntry<DocumentReference, Article>> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBasket();
  }

  Future<void> _loadBasket() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        setState(() {
          _error = "Utilisateur introuvable";
          _isLoading = false;
        });
        return;
      }

      final userDoc = userSnapshot.docs.first;
      final dynamic basketData = userDoc.data()['basket'];

      final List<dynamic> basketRefs;
      if (basketData is List) {
        basketRefs = basketData;
      } else if (basketData is DocumentReference) {
        basketRefs = [basketData];
      } else {
        basketRefs = [];
      }

      final List<MapEntry<DocumentReference, Article>> items = [];
      for (final ref in basketRefs) {
        if (ref is DocumentReference) {
          final articleDoc = await ref.get();
          if (articleDoc.exists) {
            items.add(MapEntry(
              ref,
              Article.fromFirestore(articleDoc.data() as Map<String, dynamic>),
            ));
          }
        }
      }

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Erreur : $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(DocumentReference ref) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) return;

      final userDoc = userSnapshot.docs.first;
      final List<dynamic> basketRefs = List.from(userDoc.data()['basket'] ?? []);

      basketRefs.removeWhere((r) => r is DocumentReference && r.id == ref.id);
      await userDoc.reference.update({'basket': basketRefs});

      setState(() {
        _items.removeWhere((entry) => entry.key.id == ref.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }

  double get _total => _items.fold(0, (sum, entry) => sum + entry.value.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                )
              : _items.isEmpty
                  ? const Center(child: Text("Votre panier est vide"))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final article = _items[index].value;
                              final ref = _items[index].key;
                              return Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: article.imageBase64.isNotEmpty
                                        ? Image.memory(
                                            base64Decode(article.imageBase64),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image_not_supported),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(article.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text(article.category.label,
                                            style: const TextStyle(color: Colors.grey)),
                                        Text("Taille : ${article.size}",
                                            style: const TextStyle(color: Colors.grey)),
                                        Text("${article.price.toStringAsFixed(2)} €",
                                            style: const TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _removeItem(ref),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                                top: BorderSide(color: Colors.grey[300]!)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text("${_total.toStringAsFixed(2)} €",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple)),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}