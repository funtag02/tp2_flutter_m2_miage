import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/Article.dart';

class BuyItemsPage extends StatelessWidget {
  const BuyItemsPage({super.key});

  // TODO : remove this line, should be real images converted to base64
  static const String dummyBase64 =
    "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";
  
  @override
  Widget build(BuildContext context) {
    // TODO : also remove this
    final List<Article> dummyArticles = [
      Article(
        title: "T-Shirt",
        size: "M",
        price: 29.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "Hoodie",
        size: "L",
        price: 59.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "T-Shirt",
        size: "M",
        price: 79.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "Hoodie",
        size: "L",
        price: 99.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "T-Shirt",
        size: "M",
        price: 29.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "Hoodie",
        size: "L",
        price: 59.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "T-Shirt",
        size: "M",
        price: 79.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "Hoodie",
        size: "L",
        price: 99.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "Hoodie",
        size: "L",
        price: 59.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "T-Shirt",
        size: "M",
        price: 79.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "Hoodie",
        size: "L",
        price: 99.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "T-Shirt",
        size: "M",
        price: 29.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "Hoodie",
        size: "L",
        price: 59.99,
        imageBase64: dummyBase64,
      ),
      Article(
        title: "T-Shirt",
        size: "M",
        price: 79.99,
        imageBase64: dummyBase64,
      ),
    ];

    final List<Article> articles = dummyArticles;

    return Scaffold(
      appBar: AppBar(title: const Text("Buy Items")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: articles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final article = articles[index];

            Uint8List imageBytes = base64Decode(article.imageBase64);

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                          bottom: Radius.circular(12)
                        ),
                        child: Image.memory(
                          imageBytes,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              Text("Size: ${article.size}"),
                              Text(
                                "${article.price.toStringAsFixed(2)} €",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            );
          },
        ),
      ),
    );
  }
}
