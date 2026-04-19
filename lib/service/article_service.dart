import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/article.dart';

// ─────────────────────────────────────────────────────────────────
// Service simulé
// ─────────────────────────────────────────────────────────────────
class ArticleService {
  /// Détecte la catégorie depuis l'image.
  /// Remplacer par un appel réel (Cloud Vision, GPT-4V…).
  static Future<ArticleCategory> detecterCategorie(Uint8List image) async {
    await Future.delayed(const Duration(seconds: 2));
    final categories = ArticleCategory.values;
    return categories[DateTime.now().millisecond % categories.length];
  }

  /// Sauvegarde l'article.
  static Future<void> sauvegarder(Article article) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: appel Firestore / REST API
    debugPrint('Article sauvegardé : ${article.toJson()}');
  }
}
