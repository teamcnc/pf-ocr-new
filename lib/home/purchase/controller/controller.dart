import 'dart:async';

import 'package:ocr/network/network_connect.dart';

class PurchaseController {
  NetworkConnect _connect = NetworkConnect();

  Map<String, dynamic> mapBody = Map<String, dynamic>();

//------------------------Start------------------------------------------->>>
  final StreamController _purchaseListStreamController =
      StreamController.broadcast();

  StreamSink get purchaseListStreamSink => _purchaseListStreamController.sink;

  Stream get purchaseListStream => _purchaseListStreamController.stream;

//-------------------------------End---------------------------->>>

  void getPurchaseList() async {
    mapBody = Map<String, dynamic>();
    mapBody['userid'] = NetworkConnect.currentUser.id;

    _connect
        .sendPost(mapBody, NetworkConnect.purchaseInvoices)
        .then((mapResponse) {
      purchaseListStreamSink.add(mapResponse);
    });
  }

  void destroy() {
    _purchaseListStreamController.close();
  }
}
