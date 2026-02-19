import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/Article.dart';

class ItemDetailPage extends StatelessWidget {
  final Article article;

  const ItemDetailPage({super.key, required this.article});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${article.price.toStringAsFixed(2)} €",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("Taille : ${article.size}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}