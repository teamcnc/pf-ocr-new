import 'dart:async';
import 'dart:convert';

import 'package:ocr/network/network_connect.dart';
import 'package:ocr/user/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// keys
const String keyFcmToken = 'fcmToken';

class SharedPrefManager {
  static SharedPreferences _sharedPreferences;

  SharedPreferences sharedPreferences;

  static Future<SharedPreferences> getSharedPref() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _sharedPreferences;
  }

  static allClear() {
    _sharedPreferences.clear();
  }

  // ------------------------------------------------->

  static Future<bool> setCurrentUser(User user) async {
    NetworkConnect.currentUser = user;
    return _sharedPreferences.setString('current_user', json.encode(user.toJSON()));
  }

  static Future<User> getCurrentUser() async {
    if (_sharedPreferences.getString('current_user') == null) {
      return null;
    }
    User user = User.fromJSON(
        json.decode(_sharedPreferences.getString('current_user')));
    NetworkConnect.currentUser = user;

    return user;
  }

  static logout(User user) {
    if (user != null) {
      NetworkConnect.currentUser = null;
      _sharedPreferences.setString('current_user', null);
    }
  }

  // keys
  static Future<bool> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<String> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  static Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
}
