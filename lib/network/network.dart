import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:job/network/image_json.dart';
import 'package:job/network/json.dart';
import 'package:job/utilities/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';




class Network{
  Future<Koye> getProducts(String barcode,String countryCode, int? priceMin, int? priceMax, BuildContext context) async {
    var jsonResponse;

    try {
      const String apiKey = 'f7shtjns57sjBbjdf';
      const String url = 'https://o3hmv2z8oj.execute-api.us-east-1.amazonaws.com/Prod/get-data';
      final response = await http.post(Uri.parse('$url'),
          headers: {
        'x-api-key': apiKey,
        'Content-Type': 'application/json',
      },
        body:  jsonEncode({
          "action": "gpd_and_sd",
          "barcode": barcode,
          "country": countryCode,
          "filter_criteria": {
            "price_min": priceMin,
            "price_max": priceMax,
            "product_category": null
          }
          }),

      );

      print('hhhhhhhhhhhh');
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        jsonResponse  = jsonDecode(response.body);
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch(error){
      String errorMessage = error.toString();
      print('the error isissssssisisisis ${errorMessage}');
      if (errorMessage.contains('Failed host lookup')) {
        snack(context, AppLocalizations.of(context)!.connectionIsDown);
      } else if (errorMessage.contains('DOCTYPE HTML')) {
        snack(context, AppLocalizations.of(context)!.somethingWentWrong);
      } else {
        snack(context, errorMessage);
      }
    }

    return Koye.fromJson(jsonResponse);
  }

  Future<Koye> getProductsName(String name, String countryCode,int? priceMin, int? priceMax, BuildContext context) async {
    var jsonResponse;

    try {
      const String apiKey = 'f7shtjns57sjBbjdf';
      const String url = 'https://o3hmv2z8oj.execute-api.us-east-1.amazonaws.com/Prod/get-data';
      final response = await http.post(Uri.parse('$url'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body:  jsonEncode({
          "action": "gpd_and_sd",
          "query_txt": name,
          "country": countryCode,
          "filter_criteria": {
            "price_min": priceMin,
            "price_max": priceMax,
            "product_category": null
          }
        }),

      );

      print('hhhhhhhhhhhh');
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        jsonResponse  = jsonDecode(response.body);

      } else {
        throw Exception('Failed to load transactions');
      }
    } catch(error){
      String errorMessage = error.toString();
      print('the error isissssssisisisis ${errorMessage}');
      if (errorMessage.contains('Failed host lookup')) {
        snack(context, AppLocalizations.of(context)!.connectionIsDown);
      } else if (errorMessage.contains('DOCTYPE HTML')) {
        snack(context, AppLocalizations.of(context)!.somethingWentWrong);
      } else {
        snack(context, errorMessage);
      }
    }

    return Koye.fromJson(jsonResponse);

  }
  Future<KalloImageSearch> getProductsImage(String image, String countryCode, int priceMin, int priceMax, BuildContext context) async {
    var jsonResponse;

    try {
      const String apiKey = 'f7shtjns57sjBbjdf';
      const String url = 'https://o3hmv2z8oj.execute-api.us-east-1.amazonaws.com/Prod/get-data';
      final response = await http.post(Uri.parse('$url'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body:  jsonEncode({
          "action": "gpd_and_sd",
          "image_pixels": image,
          "country": countryCode,
          "filter_criteria": {
            "price_min": priceMin,
            "price_max": priceMax,
            "product_category": null
          }
        }),

      );

      print('hhhhhhhhhhhh');
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        jsonResponse  = jsonDecode(response.body);

      } else {
        throw Exception('Failed to load transactions');
      }
    } catch(error){
      String errorMessage = error.toString();
      print('the error isissssssisisisis ${errorMessage}');
      if (errorMessage.contains('Failed host lookup')) {
        snack(context, AppLocalizations.of(context)!.connectionIsDown);
      } else if (errorMessage.contains('DOCTYPE HTML')) {
        snack(context, AppLocalizations.of(context)!.somethingWentWrong);
      }else if(errorMessage.contains('!DOCTYPE HTML PUBLIC')){
        snack(context, AppLocalizations.of(context)!.somethingWentWrong);
      } else {
        snack(context, errorMessage);
      }
    }

    return KalloImageSearch.fromJson(jsonResponse);

  }
  Future<List<String>> getSearchSuggestions(String search, String countryCode,) async {
    var jsonResponse;

    try {
      const String apiKey = 'f7shtjns57sjBbjdf';
      const String url = 'https://o3hmv2z8oj.execute-api.us-east-1.amazonaws.com/Prod/search-suggest';
      final response = await http.post(Uri.parse('$url'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body:  jsonEncode({
          "prefix":search,
          "language":countryCode
        }),

      );

      print('hhhhhhhhhhhh');
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        jsonResponse  = jsonDecode(response.body);

        final suggestions = List<String>.from(jsonResponse['suggestions']);
        final weight = List<int>.from(jsonResponse['weights']);

        return suggestions;
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch(error){
      print('the error isissssssisisisis ${error.toString()}');
      throw error;
    }
  }

  Future<Koye> getSortedProductsName(String name, String countryCode, String magnitude, BuildContext context) async {
    var jsonResponse;

    try {
      const String apiKey = 'f7shtjns57sjBbjdf';
      const String url = 'https://o3hmv2z8oj.execute-api.us-east-1.amazonaws.com/Prod/get-data';
      final response = await http.post(Uri.parse('$url'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body:  jsonEncode({
          "action": "gpd_and_sd",
          "query_txt": name,
          "country": countryCode,
          "sort_criteria":{
            "price_sort_mode":magnitude
          }
        }),

      );

      print('hhhhhhhhhhhh');
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        jsonResponse  = jsonDecode(response.body);

      } else {
        throw Exception('Failed to load transactions');
      }
    } catch(error){
      String errorMessage = error.toString();
      print('the error isissssssisisisis ${errorMessage}');
      if (errorMessage.contains('Failed host lookup')) {
        snack(context, AppLocalizations.of(context)!.connectionIsDown);
      } else if (errorMessage.contains('DOCTYPE HTML')) {
        snack(context, AppLocalizations.of(context)!.somethingWentWrong);
      } else {
        snack(context, errorMessage);
      }
    }

    return Koye.fromJson(jsonResponse);

  }
  Future<Koye> getSortedProducts(String barcode, String countryCode, String magnitude, BuildContext context) async {
    var jsonResponse;

    try {
      const String apiKey = 'f7shtjns57sjBbjdf';
      const String url = 'https://o3hmv2z8oj.execute-api.us-east-1.amazonaws.com/Prod/get-data';
      final response = await http.post(Uri.parse('$url'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body:  jsonEncode({
          "action": "gpd_and_sd",
          "barcode": barcode,
          "country": countryCode,
          "sort_criteria":{
            "price_sort_mode":magnitude
          }
        }),

      );

      print('hhhhhhhhhhhh');
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        jsonResponse  = jsonDecode(response.body);

      } else {
        throw Exception('Failed to load transactions');
      }
    } catch(error){
      String errorMessage = error.toString();
      print('the error isissssssisisisis ${errorMessage}');
      if (errorMessage.contains('Failed host lookup')) {
        snack(context, AppLocalizations.of(context)!.connectionIsDown);
      } else if (errorMessage.contains('DOCTYPE HTML')) {
        snack(context, AppLocalizations.of(context)!.somethingWentWrong);
      } else {
        snack(context, errorMessage);
      }
    }

    return Koye.fromJson(jsonResponse);

  }
  Future<Koye> getProductsCategory(String countryCode, String productCat,int? priceMin, int? priceMax, BuildContext context) async {
    var jsonResponse;

    try {
      const String apiKey = 'f7shtjns57sjBbjdf';
      const String url = 'https://o3hmv2z8oj.execute-api.us-east-1.amazonaws.com/Prod/get-data';
      final response = await http.post(Uri.parse('$url'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body:  jsonEncode({
          "action": "gpd_and_sd",
          "query_txt": null,
          "country": countryCode,
          "filter_criteria": {
            "price_min": priceMin,
            "price_max": priceMax,
            "product_category": productCat
          },
        }),

      );

      print('hhhhhhhhhhhh');
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        jsonResponse  = jsonDecode(response.body);

      } else {
        throw Exception('Failed to load transactions');
      }
    } catch(error){
      String errorMessage = error.toString();
      print('the error isissssssisisisis ${errorMessage}');
      if (errorMessage.contains('Failed host lookup')) {
        snack(context, AppLocalizations.of(context)!.connectionIsDown);
      } else if (errorMessage.contains('DOCTYPE HTML')) {
        snack(context, AppLocalizations.of(context)!.somethingWentWrong);
      } else {
        snack(context, errorMessage);
      }
    }

    return Koye.fromJson(jsonResponse);

  }
}