import 'package:flutter/cupertino.dart';

class CounterProvider extends ChangeNotifier {
  int? _counter;

  CounterProvider(this._counter);

  int? get counter => _counter;

  set counter(int? value) {
    _counter = value;
    notifyListeners();
  }
}