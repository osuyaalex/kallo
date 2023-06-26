import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Define the ChangeNotifier class
class AnimatedProvider with ChangeNotifier {
  bool _myVariable = false;

  bool get myVariable => _myVariable;

  set myVariable(bool value) {
    _myVariable = value;
    notifyListeners(); // Notify listeners when the value changes
  }
}
