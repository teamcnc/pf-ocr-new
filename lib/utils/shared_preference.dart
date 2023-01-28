import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:ocr/main.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:ocr/user/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// keys
const String keyFcmToken = 'fcmToken';

class SharedPrefManager {
  static SharedPreferences _sharedPreferences;

  SharedPreferences sharedPreferences;

  static List<User> loggedInUser = [];

  static Future<SharedPreferences> getSharedPref() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _sharedPreferences;
  }

  // static allClear() {
  //   _sharedPreferences.clear();
  // }

  // ------------------------------------------------->

  static Future<bool> setCurrentUser(User user) async {
    print('setCurrentUser Called');
    loggedInUser.clear();
    if (_sharedPreferences.containsKey('allLoggedInUser')) {
      var tempData =
          await jsonDecode(_sharedPreferences.getString('allLoggedInUser'));
      if (tempData != null) {
        for (var element in tempData) {
          loggedInUser.add(User.fromJSON(element));
        }
      }
    }
    var ids = Set<String>();
    var uniqueList =
        loggedInUser.where((element) => ids.add(element.id)).toList();
    loggedInUser = uniqueList;
    print(loggedInUser);
    if (!_sharedPreferences.containsKey("lastUserLoginID")) {
      print("user come first time");
      _sharedPreferences.setString(
          user.id.toString(), json.encode(user.toJSON()));
      loggedInUser.add(user);
      NetworkConnect.currentUser = user;
    } else if (loggedInUser != null &&
        loggedInUser.isNotEmpty &&
        loggedInUser.firstWhere(
              (element) => element.id == user.id,
              orElse: () => null,
            ) !=
            null) {
      print("User come 2nd time");
      NetworkConnect.currentUser =
          loggedInUser.firstWhere((element) => element.id == user.id);
    } else {
      print("New User");
      loggedInUser.add(user);
      NetworkConnect.currentUser = user;
    }
    loggedInUser.contains(user);
    print(user.id);
    _sharedPreferences.setString("lastUserLoginID", user.id.toString());
    _sharedPreferences.setString(
      "allLoggedInUser",
      jsonEncode(
        loggedInUser.map((e) => e.toJSON()).toList(),
      ),
    );
    return true;
  }

  static Future<User> getCurrentUser() async {
    loggedInUser.clear();
    var lastUserLoginID = _sharedPreferences.getString("lastUserLoginID");
    if (lastUserLoginID == null || lastUserLoginID.isEmpty) {
      return null;
    }
    if (_sharedPreferences.containsKey('allLoggedInUser')) {
      var tempData =
          await jsonDecode(_sharedPreferences.getString('allLoggedInUser'));
      if (tempData != null) {
        for (var element in tempData) {
          loggedInUser.add(User.fromJSON(element));
        }
      }
    } else {
      return null;
    }
    User user =
        loggedInUser.firstWhere((element) => element.id == lastUserLoginID);
    NetworkConnect.currentUser = user;
    print(
        "getCurrentUser Last User Login ID:$lastUserLoginID ${user.toJSON()}");
    return user;
  }

  static logout(User user) {
    // NetworkConnect.currentUser = null;
    _sharedPreferences.setString('lastUserLoginID', "").then((value) {
      // Phoenix.rebirth(navigatorKey.currentContext);
    });
    // if (user != null) {}
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

  static void updateCurrentUser(User currentUser) {
    int updateIndex = -1;
    for (var i = 0; i < loggedInUser.length; i++) {
      if (loggedInUser[i].id == currentUser.id) {
        updateIndex = i;
        break;
      }
    }
    if (updateIndex != -1) {
      loggedInUser[updateIndex] = currentUser;
      _sharedPreferences.setString(
        "allLoggedInUser",
        jsonEncode(
          loggedInUser.map((e) => e.toJSON()).toList(),
        ),
      );
    }
  }
}
