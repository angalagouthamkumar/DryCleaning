class CartItemModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? imagePath;
  int quantity;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imagePath,
    this.quantity = 1,
  });
}
