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
  String? thisProduct;
  Null? thisPrice;
  Null? thisCurrency;
  Null? thisAvailability;
  List<Products>? products;
  List? cprs;
  List? cprsTruncated;
  List? cprsWithinRange;
  List? scores;

  Data({this.thisProduct, this.thisPrice, this.thisCurrency, this.thisAvailability, this.products, this.cprs, this.cprsTruncated, this.cprsWithinRange, this.scores});

  Data.fromJson(Map<String, dynamic> json) {
    thisProduct = json['this_product'];
    thisPrice = json['this_price'];
    thisCurrency = json['this_currency'];
    thisAvailability = json['this_availability'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) { products!.add(new Products.fromJson(v)); });
    }
    if (json['cprs'] != null) {
      cprs = <Null>[];
      json['cprs'].forEach((v) { cprs!.add(Null); });
    }
    if (json['cprs_truncated'] != null) {
      cprsTruncated = <Null>[];
      json['cprs_truncated'].forEach((v) { cprsTruncated!.add(null); });
    }
    if (json['cprs_within_range'] != null) {
      cprsWithinRange = <Null>[];
      json['cprs_within_range'].forEach((v) { cprsWithinRange!.add(null); });
    }
    if (json['scores'] != null) {
      scores = <Null>[];
      json['scores'].forEach((v) { scores!.add(null); });
    }
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
      data['cprs'] = this.cprs!.map((v) => v.toJson()).toList();
    }
    if (this.cprsTruncated != null) {
      data['cprs_truncated'] = this.cprsTruncated!.map((v) => v.toJson()).toList();
    }
    if (this.cprsWithinRange != null) {
      data['cprs_within_range'] = this.cprsWithinRange!.map((v) => v.toJson()).toList();
    }
    if (this.scores != null) {
      data['scores'] = this.scores!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? currency;
  String? productLink;
  String? productCategory;
  String? productName;
  String? imageThumbnailUrl;
  dynamic price;
  PriceHistoryDict? priceHistoryDict;
  String? merchantUrl;
  bool? hasClipVector512;
  String? merchantDomain;
  String? merchantName;
  String? merchantType;

  Products({this.currency, this.productLink, this.productCategory, this.productName, this.imageThumbnailUrl, this.price, this.priceHistoryDict, this.merchantUrl, this.hasClipVector512, this.merchantDomain, this.merchantName, this.merchantType});

  Products.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    productLink = json['product_link'];
    productCategory = json['product_category'];
    productName = json['product_name'];
    imageThumbnailUrl = json['image_thumbnail_url'];
    price = json['price'];
    priceHistoryDict = json['price_history_dict'] != null ? new PriceHistoryDict.fromJson(json['price_history_dict']) : null;
    merchantUrl = json['merchant_url'];
    hasClipVector512 = json['has_clip_vector_512'];
    merchantDomain = json['merchant_domain'];
    merchantName = json['merchant_name'];
    merchantType = json['merchant_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['product_link'] = this.productLink;
    data['product_category'] = this.productCategory;
    data['product_name'] = this.productName;
    data['image_thumbnail_url'] = this.imageThumbnailUrl;
    data['price'] = this.price;
    if (this.priceHistoryDict != null) {
      data['price_history_dict'] = this.priceHistoryDict!.toJson();
    }
    data['merchant_url'] = this.merchantUrl;
    data['has_clip_vector_512'] = this.hasClipVector512;
    data['merchant_domain'] = this.merchantDomain;
    data['merchant_name'] = this.merchantName;
    data['merchant_type'] = this.merchantType;
    return data;
  }
}

class PriceHistoryDict {
  dynamic i17052023;
  dynamic i04072023;

  PriceHistoryDict({this.i17052023, this.i04072023});

  PriceHistoryDict.fromJson(Map<String, dynamic> json) {
    i17052023 = json['17-05-2023'];
    i04072023 = json['04-07-2023'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['17-05-2023'] = this.i17052023;
    data['04-07-2023'] = this.i04072023;
    return data;
  }
}
