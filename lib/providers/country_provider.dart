import 'package:flutter/material.dart';

class CountryProvider with ChangeNotifier{
  Map<String, dynamic> countryData = {};

  getCountryData({String? countryName}){
    if(countryName != null){
      countryData['countryName'] = countryName;
    }
    notifyListeners();
  }
}