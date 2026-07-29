
class ServiceItem {
  final String id;
  final String category;
  final String title;
  final String price;
  final double priceValue;
  final String? originalPrice;

  const ServiceItem({
    required this.id,
    required this.category,
    required this.title,
    required this.price,
    required this.priceValue,
    this.originalPrice,
  });
}

class QuickPack {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final double priceValue;

  const QuickPack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceValue,
  });
}
