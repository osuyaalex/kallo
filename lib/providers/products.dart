import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:job/providers/product_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _list = [];
  List<Product> get getItems {
    return _list;
  }
  int? get count {
    return _list.length;
  }

  Future<void> loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedItems = prefs.getStringList('cartItems');

    if (savedItems != null) {
      _list.clear();
      _list.addAll(savedItems.map((item) => Product.fromJson(jsonDecode(item))));
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedItems = _list.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList('cartItems', savedItems);
  }

  void addItem(
      String name,
      String imageUrl,
      String price,

      ) {
    final product = Product(name: name, imageUrl: imageUrl, price:  price);
    _list.add(product);
    notifyListeners();
    saveCart();
  }


  void clearCart() {
    _list.clear();
    notifyListeners();
    saveCart();
  }
}
