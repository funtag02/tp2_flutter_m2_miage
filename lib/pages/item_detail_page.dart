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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),

                      // mets simplement la brand en gras, avec le nom de l'article pas en gras, mais garde le même layout (mets ton code en dessous)
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
              )
            ),
          ],
        ),
      ),
    );
  }
}