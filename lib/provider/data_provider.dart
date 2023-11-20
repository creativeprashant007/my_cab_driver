import 'package:cab_driver/model/history.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  String earnings = "0";
  String tripCount = "0";
  List<History> tripHistory = [];
  List<String> tripHistoryKeys = [];
  void updateEarning(String newEarnings) {
    earnings = newEarnings;
    notifyListeners();
  }

  void updateTripCount({String? tripCountTotal}) {
    tripCount = tripCountTotal!;
    notifyListeners();
  }

  void updateTripHistoryKeys(List<String> keys) {
    tripHistoryKeys = keys;
    notifyListeners();
  }

  void updateTripHistory(History history) {
    tripHistory.add(history);
    notifyListeners();
  }
}
