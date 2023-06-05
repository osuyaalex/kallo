import 'package:flutter/material.dart';

snack(context, String title){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title), duration: Duration(seconds: 3),));
}