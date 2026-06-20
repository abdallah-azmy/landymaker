import 'package:flutter/material.dart';

class FontLoadNotifier extends ChangeNotifier {
  bool _ready = false;
  bool get ready => _ready;

  void markReady() {
    _ready = true;
    notifyListeners();
  }
}

final fontLoadNotifier = FontLoadNotifier();
