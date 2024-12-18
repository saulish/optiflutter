import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _items = {};

  Map<String, Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> medicine) {
    final name = medicine['name'];
    if (_items.containsKey(name)) {
      _items[name]!['quantity'] += 1; // Incrementa la cantidad si ya existe
    } else {
      _items[name] = {
        'medicine': medicine,
        'quantity': 1, // Inicializa con cantidad 1
      };
    }
    notifyListeners(); // Notifica cambios
  }

  void clearCart() {
    _items.clear();
    notifyListeners(); // Notifica cambios
  }
}
