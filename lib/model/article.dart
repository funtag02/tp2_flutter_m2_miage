class Article {
  final String title;
  final String size;
  final double price;
  final String imageBase64;

  Article({
    required this.title,
    required this.size,
    required this.price,
    required this.imageBase64,
  });

  // Méthode factory pour créer un Article depuis Firestore
  factory Article.fromFirestore(Map<String, dynamic> data) {
    return Article(
      title: data['title'] ?? '',
      size: data['size'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageBase64: data['imageBase64'] ?? '',
    );
  }
}