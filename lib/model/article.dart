class Article {
  final String title;
  final String size;
  final double price;
  final String imageBase64;
  final ArticleCategory category;
  final String brand;

  Article({
    required this.title,
    required this.size,
    required this.price,
    required this.imageBase64,
    required this.brand,
    required this.category,
  });

  // Méthode factory pour créer un Article depuis Firestore
  factory Article.fromFirestore(Map<String, dynamic> data) {
    return Article(
      title: data['title'] ?? '',
      size: data['size'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageBase64: data['imageBase64'] ?? '',
      brand: data['marque'] ?? '',
      category: ArticleCategory.values.firstWhere(
        (e) => e.toString() == 'ArticleCategory.${data['category']}',
        orElse: () => ArticleCategory.shirt, // Valeur par défaut
      ),
    );
  }
}

enum ArticleCategory {
  pants("Pantalon"),
  shirt("Chemise"),
  hoodie("Sweat à capuche"),
  short("Short"),
  top("Haut"),
  pullover("Pull"),
  jacket("Veste");

  final String label;

  const ArticleCategory(this.label);
}