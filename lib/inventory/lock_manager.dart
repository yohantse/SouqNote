import 'package:flutter/material.dart';

enum LockType { none, pin, biometrics }

class LockManager extends ChangeNotifier {
  LockType lockType = LockType.none;
  String? pinCode;

  void setLockType(LockType type, {String? pin}) {
    lockType = type;
    pinCode = pin;
    notifyListeners();
  }

  bool verifyPin(String input) => pinCode == input;

  bool isLocked() => lockType != LockType.none;
}
