class OrderItem {
  final String productName;
  final int quantity;

  OrderItem({required this.productName, required this.quantity});
}

class Order {
  final int id;
  final double total;
  final String status;
  final String createdAt;
  final String customerName;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      total: double.parse(json['total_amount'].toString()),
      status: json['status'],
      createdAt: json['created_at'],
      customerName: json['customer_name'],
      items: (json['items'] as List)
          .map((i) => OrderItem(productName: i['product_name'], quantity: i['quantity']))
          .toList(),
    );
  }
}
