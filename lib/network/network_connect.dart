import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ocr/user/model/user_model.dart';
import 'package:ocr/utils/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkConnect {
  static User currentUser;
  static bool isFingerActive = false;

  static String _baseUrl = 'https://api1.press.fit/';

  static String userLogin = "ocrapp/login.php",
      // "pressfit-api/uploads-login-1",
      salesInvoices = 'pressfit-api/uploads-arinv-lr',
      getFilePassword = 'ocrapp/generator.php',
      fileUpload = 'ocrapp/process.php',
      purchaseInvoices = 'pressfit-api/uploads-apinv-orig';

  // logoutUser() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.clear();
  //   FlutterRestart.restartApp();
  // }

  Future sendPost(Map<String, dynamic> mapBody, String url) async {
    try {
      Map<String, String> headersData = Map<String, String>();
      headersData['content-type'] = "application/json";
      print("Url===$_baseUrl$url");
      http.Response response = await http.post(Uri.tryParse('$_baseUrl$url'),
          body: json.encode(mapBody),
          headers: {"content-type": "application/json"});
      var map = jsonDecode(response.body);
      // if (response.statusCode == 401 || response.statusCode == 403) {
      //   logoutUser();
      // }
      return map;
    } catch (e) {
      Map<String, dynamic> map = {
        'error': 'Please Check Internet Connection!$e'
      };
      return map;
    }
  }

  Future<Map<String, dynamic>> sendGet(String url) async {
    try {
      Map<String, String> headersData = Map<String, String>();
      headersData['Content-Type'] = "application/json";
      // if (NetworkConnect.currentUser != null) {
      //   headersData['Authorization'] =
      //       'Bearer ' + NetworkConnect.currentUser.token;
      //   // headersData['token'] = NetworkConnect.currentUser.token;
      // }
      http.Response response =
          await http.get(Uri.tryParse('$_baseUrl$url'), headers: headersData);
      Map<String, dynamic> map = jsonDecode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) {
        SharedPrefManager.logout(null);
      }

      return map;
    } catch (e) {
      print(e);
      Map<String, dynamic> map = {'error': 'Please Check Internet Connection!'};
      return map;
    }
  }

  Future<Map<String, dynamic>> post(
      Map<String, dynamic> mapBody, String url) async {
    try {
      Map<String, String> headersData = Map<String, String>();
      headersData['Content-Type'] = "application/json";
      if (NetworkConnect.currentUser != null) {
        headersData['Authorization'] =
            'Bearer ' + NetworkConnect.currentUser.token;
      }
      http.Response response = await http.post(
        Uri.tryParse('$_baseUrl$url'),
        body: json.encode(mapBody),
        headers: headersData,
      );
      Map<String, dynamic> map = jsonDecode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) {
        // logoutUser();
        SharedPrefManager.logout(null);
      }

      return map;
    } catch (e) {
      Map<String, dynamic> map = {'error': 'Please Check Internet Connection!'};
      return map;
    }
  }

  Future<Map<String, dynamic>> sendPostHeaders(
      Map<String, dynamic> mapBody, String url) async {
    try {
      http.Response response = await http.post(Uri.tryParse('$_baseUrl$url'),
          body: json.encode(mapBody),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'grant_type': 'password',
            'Authorization':
                'Basic ' + base64Encode(utf8.encode('testclient:testsecret'))
            // 'basic auth : Username: testclient, Password : testsecret'
          });
      Map<String, dynamic> map = jsonDecode(response.body);
      // if (response.statusCode == 401 || response.statusCode == 403) {
      //   logoutUser();
      // }

      return map;
    } catch (e) {
      print("Error==$e");
      Map<String, dynamic> map = {'error': 'Please Check Internet Connection!'};
      return map;
    }
  }

  Future<Map<String, dynamic>> sendFile(_image, String url) async {
    try {
      String apiUrl = '$_baseUrl$url';
      final request = new http.MultipartRequest('POST', Uri.parse(apiUrl));
      String fileName = _image.path.split("/").last;
      request.files.add(
        new http.MultipartFile.fromBytes('file', _image.readAsBytesSync(),
            contentType: MediaType('multipart', 'form-data'),
            filename: fileName),
      );
      http.Response response =
          await http.Response.fromStream(await request.send());
      Map<String, dynamic> map = jsonDecode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) {
        // logoutUser();
        SharedPrefManager.logout(null);
      }

      return map;
    } catch (e) {
      Map<String, dynamic> map = {'error': 'Please Check Internet Connection!'};
      return map;
    }
  }

  Future<Map<String, dynamic>> uploadFile(
      var apiUrl, File files, var password, var docnum, String type) async {
    try {
      final request = new http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields.addEntries([
        MapEntry('pass', password),
        MapEntry('docnum', docnum),
        MapEntry('type', type)
      ]);
      request.files.add(
          // await http.MultipartFile.fromPath('image', files.path)
          await http.MultipartFile.fromBytes('image', files.readAsBytesSync()));
      print("request.fields=${request.fields}");
      request.headers.addEntries([
        // MapEntry('Authorization', headers['Authorization']),
        MapEntry('content-type', 'multipart/form-data')
      ]);
      http.Response response =
          await http.Response.fromStream(await request.send());
      Map<String, dynamic> map = jsonDecode(response.body);
      return map;
    } catch (e) {
      Map<String, dynamic> map = {'msg': 'Please Check Internet Connection!'};
      return map;
    }
  }
}
