class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      // price එක string එකක් හෝ number එකක් වුණත් වැඩ කරන්න හදලා තියෙන්නේ
      price: (map['price'] != null) ? double.parse(map['price'].toString()) : 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'All',
    );
  }
}