import 'package:flutter/cupertino.dart';

class User with ChangeNotifier {
  String id, token, name, auth, password;

  List salesID = [];
  List purchaseID = [];
  List totalFiles = [];
  bool isUploadingFiles = false;

  get getIsUploadingFiles => this.isUploadingFiles;

  set setIsUploadingFiles(bool isUploadingFiles) {
    this.isUploadingFiles = isUploadingFiles;
    notifyListeners();
  }

  String get getAuth => this.auth;

  set setAuth(String auth) => this.auth = auth;

  String get getPassword => this.password;

  set setPassword(String password) => this.password = password;

  String get getName => this.name;

  set setName(String name) => this.name = name;

  get getSalesID => this.salesID;

  set setSalesID(salesID) => this.salesID = salesID;

  get getPurchaseID => this.purchaseID;

  set setPurchaseID(purchaseID) => this.purchaseID = purchaseID;

  get getTotalFiles => this.totalFiles;

  set setTotalFiles(totalFiles) => this.totalFiles = totalFiles;

  User();

  User.fromJSON(Map<String, dynamic> map) {
    token = map['access_token'];
    id = map['UserCode'];
    name = map['UserName'];
    salesID = map['sales_ids'] ?? [];
    purchaseID = map['purchase_ids'] ?? [];
    auth = map['U_Auth_UploadsType'];
    password = map['PW'];
    notifyListeners();
  }

  toJSON() {
    return {
      'access_token': token,
      'U_Auth_UploadsType': auth,
      'UserCode': id,
      'UserName': name,
      'sales_ids': salesID,
      'purchase_ids': purchaseID,
      'PW': password
    };
  }
}
