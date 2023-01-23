import 'dart:async';

import 'package:ocr/network/network_connect.dart';

class UserController {
  NetworkConnect _connect = NetworkConnect();

  Map<String, dynamic> mapBody = Map<String, dynamic>();

//------------------------Start------------------------------------------->>>
  final StreamController _loginStreamController = StreamController.broadcast();

  StreamSink get loginStreamSink => _loginStreamController.sink;

  Stream get loginStream => _loginStreamController.stream;

//-------------------------------End---------------------------->>>

  //------------------------Start------------------------------------------->>>

  final StreamController<Map<String, dynamic>> _forgotPassController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<Map<String, dynamic>> get forgotPassStreamSink =>
      _forgotPassController.sink;

  Stream<Map<String, dynamic>> get forgotPassStream =>
      _forgotPassController.stream;

  //-------------------------------End---------------------------->>>

  final StreamController<Map<String, dynamic>> _resendStreamController =
      StreamController<Map<String, dynamic>>();

  StreamSink<Map<String, dynamic>> get resendStreamSink =>
      _resendStreamController.sink;

  Stream<Map<String, dynamic>> get resendStream =>
      _resendStreamController.stream;

//==============================================================>
  final StreamController<Map<String, dynamic>> _resetPasswordController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<Map<String, dynamic>> get resetPasswordStreamSink =>
      _resetPasswordController.sink;

  Stream<Map<String, dynamic>> get resetPasswordStream =>
      _resetPasswordController.stream;

//Login User------>
  void checkLogin(String username, String password) async {
    mapBody = Map<String, dynamic>();
    mapBody['userid'] = username;
    mapBody['password'] = password;
    print("map+==$mapBody");

    _connect.sendPost(mapBody, NetworkConnect.userLogin).then((mapResponse) {
      loginStreamSink.add(mapResponse);
    });
  }

  void destroy() {
    _loginStreamController.close();
    _resendStreamController.close();
    _forgotPassController.close();
    _resetPasswordController.close();
  }
}
