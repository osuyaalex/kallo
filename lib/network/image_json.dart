class KalloImageSearch {
  bool? itemFound;
  Data? data;
  Null? error;

  KalloImageSearch({this.itemFound, this.data, this.error});

  KalloImageSearch.fromJson(Map<String, dynamic> json) {
    itemFound = json['item_found'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_found'] = this.itemFound;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['error'] = this.error;
    return data;
  }
}

class Data {
  Null? thisProduct;
  Null? thisPrice;
  Null? thisCurrency;
  Null? thisAvailability;
  List<Products>? products;
  List? cprs;
  List? cprsTruncated;
  List? cprsWithinRange;
  List<dynamic>? scores;

  Data(
      {this.thisProduct,
        this.thisPrice,
        this.thisCurrency,
        this.thisAvailability,
        this.products,
        this.cprs,
        this.cprsTruncated,
        this.cprsWithinRange,
        this.scores});

  Data.fromJson(Map<String, dynamic> json) {
    thisProduct = json['this_product'];
    thisPrice = json['this_price'];
    thisCurrency = json['this_currency'];
    thisAvailability = json['this_availability'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
    if (json['cprs'] != null) {
      cprs = <Null>[];
      json['cprs'].forEach((v) {
        cprs!.add(null);
      });
    }
    if (json['cprs_truncated'] != null) {
      cprsTruncated = <Null>[];
      json['cprs_truncated'].forEach((v) {
        cprsTruncated!.add(null);
      });
    }
    if (json['cprs_within_range'] != null) {
      cprsWithinRange = <Null>[];
      json['cprs_within_range'].forEach((v) {
        cprsWithinRange!.add(null);
      });
    }
    scores = json['scores'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['this_product'] = this.thisProduct;
    data['this_price'] = this.thisPrice;
    data['this_currency'] = this.thisCurrency;
    data['this_availability'] = this.thisAvailability;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.cprs != null) {
      data['cprs'] = this.cprs!.map((v) => v?.toJson()).toList();
    }
    if (this.cprsTruncated != null) {
      data['cprs_truncated'] =
          this.cprsTruncated!.map((v) => v.toJson()).toList();
    }
    if (this.cprsWithinRange != null) {
      data['cprs_within_range'] =
          this.cprsWithinRange!.map((v) => v.toJson()).toList();
    }
    data['scores'] = this.scores;
    return data;
  }
}

class Products {
  String? currency;
  String? productLink;
  bool? hasRn50Vector2048;
  String? productName;
  String? imageThumbnailUrl;
  int? price;
  PriceHistoryDict? priceHistoryDict;
  String? merchantUrl;
  List<dynamic>? clipVector512;
  String? merchantDomain;
  String? merchantName;
  String? merchantType;

  Products(
      {this.currency,
        this.productLink,
        this.hasRn50Vector2048,
        this.productName,
        this.imageThumbnailUrl,
        this.price,
        this.priceHistoryDict,
        this.merchantUrl,
        this.clipVector512,
        this.merchantDomain,
        this.merchantName,
        this.merchantType});

  Products.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    productLink = json['product_link'];
    hasRn50Vector2048 = json['has_rn50_vector_2048'];
    productName = json['product_name'];
    imageThumbnailUrl = json['image_thumbnail_url'];
    price = json['price'].toInt();
    priceHistoryDict = json['price_history_dict'] != null
        ? new PriceHistoryDict.fromJson(json['price_history_dict'])
        : null;
    merchantUrl = json['merchant_url'];
    clipVector512 = json['clip_vector_512'];
    merchantDomain = json['merchant_domain'];
    merchantName = json['merchant_name'];
    merchantType = json['merchant_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['product_link'] = this.productLink;
    data['has_rn50_vector_2048'] = this.hasRn50Vector2048;
    data['product_name'] = this.productName;
    data['image_thumbnail_url'] = this.imageThumbnailUrl;
    data['price'] = this.price;
    if (this.priceHistoryDict != null) {
      data['price_history_dict'] = this.priceHistoryDict!.toJson();
    }
    data['merchant_url'] = this.merchantUrl;
    data['clip_vector_512'] = this.clipVector512;
    data['merchant_domain'] = this.merchantDomain;
    data['merchant_name'] = this.merchantName;
    data['merchant_type'] = this.merchantType;
    return data;
  }
}

class PriceHistoryDict {
  double? i20052023;

  PriceHistoryDict({this.i20052023});

  PriceHistoryDict.fromJson(Map<String, dynamic> json) {
    i20052023 = json['20-05-2023'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['20-05-2023'] = this.i20052023;
    return data;
  }
}
