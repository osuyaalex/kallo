import 'package:flutter/material.dart';

snack(context, String title){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Color(0xff7F78D8).withOpacity(0.6),
      content: Text(title)));
}