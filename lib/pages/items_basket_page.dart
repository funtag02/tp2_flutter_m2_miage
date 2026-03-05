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
  Map<String, MapEntry<Article, int>> _items = {};
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

      final Map<String, MapEntry<Article, int>> items = {};
      for (final ref in basketRefs) {
        if (ref is DocumentReference) {
          final id = ref.id;
          if (items.containsKey(id)) {
            items[id] = MapEntry(items[id]!.key, items[id]!.value + 1);
          } else {
            final articleDoc = await ref.get();
            if (articleDoc.exists) {
              items[id] = MapEntry(
                Article.fromFirestore(articleDoc.data() as Map<String, dynamic>),
                1,
              );
            }
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

  Future<void> _removeOneItem(String docId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) return;

      final userDoc = userSnapshot.docs.first;
      final List<dynamic> basketRefs = List.from(userDoc.data()['basket'] ?? []);

      // Retire une seule occurrence
      final index = basketRefs.indexWhere(
        (r) => r is DocumentReference && r.id == docId,
      );
      if (index != -1) basketRefs.removeAt(index);

      await userDoc.reference.update({'basket': basketRefs});

      setState(() {
        final currentQty = _items[docId]!.value;
        if (currentQty <= 1) {
          _items.remove(docId);
        } else {
          _items[docId] = MapEntry(_items[docId]!.key, currentQty - 1);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  Future<void> _addOneItem(String docId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) return;

      final userDoc = userSnapshot.docs.first;
      final List<dynamic> basketRefs = List.from(userDoc.data()['basket'] ?? []);

      final newRef = FirebaseFirestore.instance.collection('articles').doc(docId);
      basketRefs.add(newRef);
      await userDoc.reference.update({'basket': basketRefs});

      setState(() {
        _items[docId] = MapEntry(_items[docId]!.key, _items[docId]!.value + 1);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  double get _total => _items.values.fold(
        0,
        (sum, entry) => sum + entry.key.price * entry.value,
      );

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
                              final docId = _items.keys.elementAt(index);
                              final article = _items[docId]!.key;
                              final quantity = _items[docId]!.value;

                              return Row(
                                children: [
                                  // Image
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
                                  // Infos
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
                                  // Contrôles quantité + suppression
                                  Column(
                                    children: [
                                      // Bouton X pour tout supprimer
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                        onPressed: () {
                                          // Supprime toutes les occurrences
                                          for (int i = 0; i < quantity; i++) {
                                            _removeOneItem(docId);
                                          }
                                        },
                                      ),
                                      // Contrôles +/-
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => _removeOneItem(docId),
                                            borderRadius: BorderRadius.circular(4),
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.remove, size: 16),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              "$quantity",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _addOneItem(docId),
                                            borderRadius: BorderRadius.circular(4),
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.add, size: 16, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Total
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