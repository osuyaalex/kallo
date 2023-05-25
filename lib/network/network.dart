import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job/network/json.dart';




class Network{
  Future<Koye> getProducts(String barcode,) async {
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
          //"query_txt": name,
          "country": "NG"
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
      print('the error isissssssisisisis ${error.toString()}');
    }

    return Koye.fromJson(jsonResponse);
  }

  Future<Koye> getProductsName(String name,) async {
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
          "country": "NG"
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
      print('the error isissssssisisisis ${error.toString()}');
    }

    return Koye.fromJson(jsonResponse);


  }
}