import 'package:intl/intl.dart';

class Purchase {
  String atcName,
      atcPath,
      atcType,
      amount,
      buyer,
      date,
      docEntry,
      docNum,
      document,
      objType,
      packages,
      series,
      transporter,
      type,
      vendorCode,
      vendorName,
      atcEntry,
      vendorRefNo;
  DateTime dateTime;

  Purchase.fromJSON(json) {
    atcName = json['ATCName'];
    atcPath = json['ATCPath'];
    atcType = json['ATCType'];
    atcEntry = json['AtcEntry'];
    amount = json['Amount'];
    buyer = json['Buyer'];
    date = json['Date'];
    if (date != null && date.length != 0) {
      try {
        dateTime = DateTime.parse(date);
        date = DateFormat('dd MMM').format(dateTime);
      } catch (e) {
        date = json['Date'];
      }
    }
    docEntry = json['DocEntry'];
    docNum = json['DocNum'];
    document = json['Document'];
    objType = json['ObjType'];
    packages = json['Packages'];
    series = json['Series'];
    transporter = json['Transporter'];
    type = json['Type'];
    vendorRefNo = json['Vendor Ref. No.'];
    vendorCode = json['Vendor Code'];
    vendorName = json['Vendor Name'];
  }

  toJSON() {
    Map<String, dynamic> json = {};
    json['ATCName'] = atcName;
    json['ATCPath'] = atcPath;
    json['ATCType'] = atcType;
    json['AtcEntry'] = atcEntry;
    json['Amount'] = amount;
    json['Buyer'] = buyer;
    json['Date'] = date;
    if (dateTime != null) {
      try {
        json['Date'] = DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        json['Date'] = date;
        print("Exception=$e");
      }
    }
    json['DocEntry'] = docEntry;
    json['DocNum'] = docNum;
    json['Document'] = document;
    json['ObjType'] = objType;
    json['Packages'] = packages;
    json['Series'] = series;
    json['Transporter'] = transporter;
    json['Type'] = type;
    json['Vendor Ref. No.'] = vendorRefNo;
    json['Vendor Code'] = vendorCode;
    json['Vendor Name'] = vendorName;
    return json;
  }
}
