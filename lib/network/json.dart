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
        cprs!.add( Null);
      });
    }
    if (json['cprs_truncated'] != null) {
      cprsTruncated = <Null>[];
      json['cprs_truncated'].forEach((v) {
        cprsTruncated!.add( Null);
      });
    }
    if (json['cprs_within_range'] != null) {
      cprsWithinRange = <Null>[];
      json['cprs_within_range'].forEach((v) {
        cprsWithinRange!.add( Null);
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

class Products {
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

  Products(
      {this.currency,
        this.productLink,
        this.productName,
        this.imageThumbnailUrl,
        this.price,
        this.priceHistoryDict,
        this.merchantUrl,
        this.merchantDomain,
        this.merchantName,
        this.merchantType});

  Products.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}

class PriceHistoryDict {
  dynamic s11102022;
  dynamic s10102022;
  dynamic i11022023;
  dynamic i12022023;
  dynamic i20122022;
  dynamic i23122022;
  dynamic i09102022;

  PriceHistoryDict(
      {this.s11102022,
        this.s10102022,
        this.i11022023,
        this.i12022023,
        this.i20122022,
        this.i23122022,
        this.i09102022});

  PriceHistoryDict.fromJson(Map<String, dynamic> json) {
    s11102022 = json['11-10-2022'];
    s10102022 = json['10-10-2022'];
    i11022023 = json['11-02-2023'];
    i12022023 = json['12-02-2023'];
    i20122022 = json['20-12-2022'];
    i23122022 = json['23-12-2022'];
    i09102022 = json['09-10-2022'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['11-10-2022'] = this.s11102022;
    data['10-10-2022'] = this.s10102022;
    data['11-02-2023'] = this.i11022023;
    data['12-02-2023'] = this.i12022023;
    data['20-12-2022'] = this.i20122022;
    data['23-12-2022'] = this.i23122022;
    data['09-10-2022'] = this.i09102022;
    return data;
  }
}
