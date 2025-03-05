import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final DatabaseService _databaseService = DatabaseService();

  User? get user => _user;

  Future<void> registerUser(
    String id,
    String name,
    String password,
    String role, {
    String? subject,
  }) async {
    _user = User(
      id: id,
      name: name,
      password: password,
      role: role,
      subject: subject,
    );
    await _databaseService.registerUser(_user!);
    notifyListeners();
  }

  Future<bool> loginUser(String name, String password) async {
    _user = await _databaseService.loginUser(name, password);
    notifyListeners();
    return _user != null;
  }
}
