import 'package:intl/intl.dart';

class Sales {
  String atcName,
      atcPath,
      atcType,
      amount,
      city,
      customerCode,
      customerName,
      date,
      docEntry,
      docNum,
      document,
      driver,
      nos,
      objType,
      packages,
      salesEmployee,
      series,
      state,
      transporter,
      atcEntry,
      type;
  DateTime dateTime;

  Sales.fromJSON(json) {
    atcName = json['ATCName'];
    atcPath = json['ATCPath'];
    atcType = json['ATCType'];
    atcEntry = json['AtcEntry'];
    amount = json['Amount'];
    city = json['City'];
    customerCode = json['Customer Code'];
    customerName = json['Customer Name'];
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
    driver = json['Driver'];
    nos = json['Nos'];
    objType = json['ObjType'];
    packages = json['Packages'];
    salesEmployee = json['Sales Employee'];
    series = json['Series'];
    state = json['State'];
    transporter = json['Transporter'];
    type = json['Type'];
  }

  toJSON() {
    Map<String, dynamic> json = {};
    json['ATCName'] = atcName;
    json['ATCPath'] = atcPath;
    json['ATCType'] = atcType;
    json['AtcEntry'] = atcEntry;
    json['Amount'] = amount;
    json['City'] = city;
    json['Customer Code'] = customerCode;
    json['Customer Name'] = customerName;
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
    json['Driver'] = driver;
    json['Nos'] = nos;
    json['ObjType'] = objType;
    json['Packages'] = packages;
    json['Sales Employee'] = salesEmployee;
    json['Series'] = series;
    json['State'] = state;
    json['Transporter'] = transporter;
    json['Type'] = type;
    return json;
  }
}
