import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Define the ChangeNotifier class
class AnimatedProvider with ChangeNotifier {
  bool _myVariable = true;
  bool _firstVariable = false;

  bool get myVariable => _myVariable;
  bool get firstShow => _firstVariable;

  set myVariable(bool value) {
    _myVariable = value;
    notifyListeners(); // Notify listeners when the value changes
  }
  set firstShow(bool value) {
    _firstVariable  = value;
    notifyListeners(); // Notify listeners when the value changes
  }
}
