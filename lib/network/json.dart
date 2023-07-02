class Koye {
  bool? itemFound;
  Data? data;
  Null? error;

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
  List<Pproducts>? products;
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
      products = <Pproducts>[];
      json['products'].forEach((v) {
        products!.add(new Pproducts.fromJson(v));
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
      data['cprs'] = this.cprs!.map((v) => v.toJson()).toList();
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

class Pproducts {
  String? currency;
  String? productLink;
  String? productName;
  String? imageThumbnailUrl;
  dynamic price;
  PriceHistoryDict? priceHistoryDict;
  String? merchantUrl;
  String? merchantDomain;
  String? merchantName;
  String? merchantType;
  String? merchantLongitude;
  String? merchantLatitude;

  Pproducts(
      {this.currency,
        this.productLink,
        this.productName,
        this.imageThumbnailUrl,
        this.price,
        this.priceHistoryDict,
        this.merchantUrl,
        this.merchantDomain,
        this.merchantName,
        this.merchantType,
        this.merchantLongitude,
        this.merchantLatitude});

  Pproducts.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    productLink = json['product_link'];
    productName = json['product_name'];
    imageThumbnailUrl = json['image_thumbnail_url'];
    price = json['price'];
    priceHistoryDict = json['price_history_dict'] != null
        ? new PriceHistoryDict.fromJson(json['price_history_dict'])
        : null;
    merchantUrl = json['merchant_url'];
    merchantDomain = json['merchant_domain'];
    merchantName = json['merchant_name'];
    merchantType = json['merchant_type'];
    merchantLongitude = json['merchant_longitude'];
    merchantLatitude = json['merchant_latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['product_link'] = this.productLink;
    data['product_name'] = this.productName;
    data['image_thumbnail_url'] = this.imageThumbnailUrl;
    data['price'] = this.price;
    if (this.priceHistoryDict != null) {
      data['price_history_dict'] = this.priceHistoryDict!.toJson();
    }
    data['merchant_url'] = this.merchantUrl;
    data['merchant_domain'] = this.merchantDomain;
    data['merchant_name'] = this.merchantName;
    data['merchant_type'] = this.merchantType;
    data['merchant_longitude'] = this.merchantLongitude;
    data['merchant_latitude'] = this.merchantLatitude;
    return data;
  }
}

class PriceHistoryDict {
  dynamic i09102022;
  dynamic i10022023;
  dynamic s12022023;
  dynamic s10102022;
  dynamic s23122022;

  PriceHistoryDict(
      {this.i09102022,
        this.i10022023,
        this.s12022023,
        this.s10102022,
        this.s23122022});

  PriceHistoryDict.fromJson(Map<String, dynamic> json) {
    i09102022 = json['09-10-2022'];
    i10022023 = json['10-02-2023'];
    s12022023 = json['12-02-2023'];
    s10102022 = json['10-10-2022'];
    s23122022 = json['23-12-2022'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['09-10-2022'] = this.i09102022;
    data['10-02-2023'] = this.i10022023;
    data['12-02-2023'] = this.s12022023;
    data['10-10-2022'] = this.s10102022;
    data['23-12-2022'] = this.s23122022;
    return data;
  }
}
