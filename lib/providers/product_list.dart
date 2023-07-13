class Product {
  final String name;
  final String imageUrl;
  final String price;
  final String url;
  final String merchantName;
  final String currency;
  final String? productCategory;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.url,
    required this.merchantName,
    required this.currency,
    required this.productCategory
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      url: json['url'],
      merchantName: json['merchantName'],
      currency: json['currency'],
      productCategory: json['productCategory']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'url': url,
      'merchantName':merchantName,
      'currency':currency,
      'productCategory': productCategory
    };
  }
}
