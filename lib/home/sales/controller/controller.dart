import 'dart:async';

import 'package:ocr/network/network_connect.dart';

class SalesController {
  NetworkConnect _connect = NetworkConnect();

  Map<String, dynamic> mapBody = Map<String, dynamic>();

//------------------------Start------------------------------------------->>>
  final StreamController _salesListStreamController =
      StreamController.broadcast();

  StreamSink get salesListStreamSink => _salesListStreamController.sink;

  Stream get salesListStream => _salesListStreamController.stream;

//-------------------------------End---------------------------->>>

  void getSalesList() async {
    mapBody = Map<String, dynamic>();
    mapBody['userid'] = NetworkConnect.currentUser.id;

    _connect
        .sendPost(mapBody, NetworkConnect.salesInvoices)
        .then((mapResponse) {
      salesListStreamSink.add(mapResponse);
    });
  }

  void destroy() {
    _salesListStreamController.close();
  }
}
