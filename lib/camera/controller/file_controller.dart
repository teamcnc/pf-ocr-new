import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ocr/network/network_connect.dart';
import 'package:ocr/utils/shared_preference.dart';

class FileController {
  var password;
  NetworkConnect _connect = NetworkConnect();

  Map<String, dynamic> mapBody = Map<String, dynamic>();

//------------------------Start------------------------------------------->>>
  final StreamController _fileListStreamController =
      StreamController.broadcast();

  StreamSink get fileListStreamSink => _fileListStreamController.sink;

  Stream get fileListStream => _fileListStreamController.stream;

//-------------------------------End---------------------------->>>

  void getFilePassword(File image, String docnum, String type) async {
    // _connect.sendGet(NetworkConnect.getFilePassword).then((mapResponse) {
    //   print("Res=$mapResponse");
    //   password = mapResponse['password'];
    var rng = new Random();
    mapBody = {
      // 'pass': mapResponse['password'],
      'docnum': docnum,
      'type': type,
      'image': "data:@file/pdf;base64," + base64Encode(image.readAsBytesSync()),
      'filename': "${rng.nextInt(10000)}.pdf"
    };
    _connect.sendPost(mapBody, NetworkConnect.fileUpload).then((mapResponse) {
      print("Res12=$mapResponse");
      fileListStreamSink.add(mapResponse);
    });
    // });
  }

  Future<bool> uploadFile(File image) async {
    List<String> pathElements = image.path.split('/');
    Map<String, dynamic> fileObj;
    if (pathElements[pathElements.length - 3] == 'sales') {
      fileObj = NetworkConnect.currentUser.salesID.firstWhere((element) =>
          element['docentry'] == pathElements[pathElements.length - 2]);
    } else if (pathElements[pathElements.length - 3] == 'purchase') {
      fileObj = NetworkConnect.currentUser.purchaseID.firstWhere((element) =>
          element['docentry'] == pathElements[pathElements.length - 2]);
    }
    mapBody = {
      // 'docnum': pathElements[pathElements.length - 2],
      'type': pathElements[pathElements.length - 3],
      'image': "data:@file/pdf;base64," + base64Encode(image.readAsBytesSync()),
      // 'filename': pathElements[pathElements.length - 1]
      // .split('.')[0]
      "docentry": pathElements[pathElements.length - 2],
      "filename": fileObj['filename'],
      "atcentry": fileObj['atcentry'],
      "atctype": fileObj['atctype'],
      // "atcpath": fileObj['atcpath']
      "userid": NetworkConnect.currentUser.id,
      "password": NetworkConnect.currentUser.password
    };
    Map<String, dynamic> mapResponse =
        await _connect.sendPost(mapBody, NetworkConnect.fileUpload);
    //     .then((mapResponse) {
    print("Res12=$mapResponse");
    //   fileListStreamSink.add(mapResponse);
    // });
    if (mapResponse['status'] == 'success') {
      fileListStreamSink
          .add({'status': true, 'from': pathElements[pathElements.length - 3]});
      if (pathElements[pathElements.length - 3] == 'purchase') {
        if (NetworkConnect.currentUser.purchaseID.contains(fileObj)) {
          NetworkConnect.currentUser.purchaseID.remove(fileObj);
        }
      } else {
        if (NetworkConnect.currentUser.salesID.contains(fileObj)) {
          NetworkConnect.currentUser.salesID.remove(fileObj);
        }
      }

      NetworkConnect.currentUser.totalFiles.firstWhere((element) =>
          element['docentry'] ==
          pathElements[pathElements.length - 2])['status'] = 'Success';
      // .add({'filename': fileObj['filename'], 'status': 'Success'});

      SharedPrefManager.setCurrentUser(NetworkConnect.currentUser);
      return true;
    } else {
      fileListStreamSink.add(
          {'status': false, 'from': pathElements[pathElements.length - 3]});
      NetworkConnect.currentUser.totalFiles.firstWhere((element) =>
          element['docentry'] ==
          pathElements[pathElements.length - 2])['status'] = 'Failure';
      if (mapResponse['result'] != null) {
        Map<String, dynamic> resultDecoded = json.decode(mapResponse['result']);
        if (resultDecoded['error'] != null) {
          if (resultDecoded['error']['message'] != null) {
            if (resultDecoded['error']['message']['value'] != null) {
              NetworkConnect.currentUser.totalFiles.firstWhere((element) =>
                      element['docentry'] ==
                      pathElements[pathElements.length - 2])['reason'] =
                  resultDecoded['error']['message']['value'];
            }
          }
        }
      }
      // NetworkConnect.currentUser.totalFiles
      //     .add({'filename': fileObj['filename'], 'status': 'Failure'});
      return false;
    }
  }

  void destroy() {
    _fileListStreamController.close();
  }
}
