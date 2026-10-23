class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int quantity;
  final int farmerId;
  final String farmerName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.quantity,
    required this.farmerId,
    required this.farmerName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      // MySQL DECIMAL arrives as a string, so parse via toString()
      price: double.parse(json['price'].toString()),
      category: json['category'],
      quantity: json['quantity'],
      farmerId: json['farmer_id'],
      farmerName: json['farmer_name'] ?? '',
    );
  }
}
