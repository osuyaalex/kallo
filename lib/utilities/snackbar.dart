import 'package:flutter/material.dart';

snack(context, String title){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 7),
      content: Text(title)));
}