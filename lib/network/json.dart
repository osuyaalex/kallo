class Koye {
  bool? itemFound;
  Data? data;
  Null error;

  Koye({this.itemFound, this.data, this.error});

  Koye.fromJson(Map<String, dynamic> json) {
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
  List<double>? scores;

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
        cprs!.add( Null as Null);
      });
    }
    if (json['cprs_truncated'] != null) {
      cprsTruncated = <Null>[];
      json['cprs_truncated'].forEach((v) {
        cprsTruncated!.add( Null as Null);
      });
    }
    if (json['cprs_within_range'] != null) {
      cprsWithinRange = <Null>[];
      json['cprs_within_range'].forEach((v) {
        cprsWithinRange!.add(Null as Null);
      });
    }
    scores = json['scores'].cast<double>();
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
  String? merchantUrl;
  String? productName;
  String? price;
  String? currency;
  String? productLink;
  String? imageThumbnailUrl;
  PriceHistoryDict? priceHistoryDict;
  String? merchantDomain;
  String? merchantName;
  String? merchantType;
  String? merchantLongitude;
  String? merchantLatitude;

  Products(
      {this.merchantUrl,
        this.productName,
        this.price,
        this.currency,
        this.productLink,
        this.imageThumbnailUrl,
        this.priceHistoryDict,
        this.merchantDomain,
        this.merchantName,
        this.merchantType,
        this.merchantLongitude,
        this.merchantLatitude});

  Products.fromJson(Map<String, dynamic> json) {
    merchantUrl = json['merchant_url'];
    productName = json['product_name'];
    price = json['price'];
    currency = json['currency'];
    productLink = json['product_link'];
    imageThumbnailUrl = json['image_thumbnail_url'];
    priceHistoryDict = json['price_history_dict'] != null
        ? new PriceHistoryDict.fromJson(json['price_history_dict'])
        : null;
    merchantDomain = json['merchant_domain'];
    merchantName = json['merchant_name'];
    merchantType = json['merchant_type'];
    merchantLongitude = json['merchant_longitude'];
    merchantLatitude = json['merchant_latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchant_url'] = this.merchantUrl;
    data['product_name'] = this.productName;
    data['price'] = this.price;
    data['currency'] = this.currency;
    data['product_link'] = this.productLink;
    data['image_thumbnail_url'] = this.imageThumbnailUrl;
    if (this.priceHistoryDict != null) {
      data['price_history_dict'] = this.priceHistoryDict!.toJson();
    }
    data['merchant_domain'] = this.merchantDomain;
    data['merchant_name'] = this.merchantName;
    data['merchant_type'] = this.merchantType;
    data['merchant_longitude'] = this.merchantLongitude;
    data['merchant_latitude'] = this.merchantLatitude;
    return data;
  }
}

class PriceHistoryDict {
  String? s23122022;
  String? s10022023;
  String? s24122022;

  PriceHistoryDict({this.s23122022, this.s10022023, this.s24122022});

  PriceHistoryDict.fromJson(Map<String, dynamic> json) {
    s23122022 = json['23-12-2022'];
    s10022023 = json['10-02-2023'];
    s24122022 = json['24-12-2022'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['23-12-2022'] = this.s23122022;
    data['10-02-2023'] = this.s10022023;
    data['24-12-2022'] = this.s24122022;
    return data;
  }
}
