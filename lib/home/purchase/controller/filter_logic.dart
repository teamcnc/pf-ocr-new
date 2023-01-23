import 'package:intl/intl.dart';
import 'package:ocr/home/purchase/model/purchase.dart';

class PurchaseFilterLogic {
  PurchaseFilterLogic(List<Purchase> purchaseList) {
    this.incomingPurchaseList = purchaseList;
    getOptionLists();
  }
  List<String> filtersOptionsList = [
    'Series',
    'Date',
    'Vendor Code',
    'Vendor Name',
    'Buyer',
    'Transporter',
  ];
  List seriesList = [],
      vendorCodelist = [],
      vendorNameList = [],
      buyerList = [],
      transporterList = [];
  List selectedSeriesList = [],
      selectedVendorCodelist = [],
      selectedVendorNameList = [],
      selectedBuyerList = [],
      selectedTransporterList = [];

  List<Purchase> filterList = [];
  List<Purchase> incomingPurchaseList = [];

  DateTime fromDate = DateTime.now(), toDate = DateTime.now();
  String fromDateString, toDateString;

  String formatDate(DateTime date) => DateFormat('yyyy, dd MMM').format(date);

  getOptionLists() {
    seriesList = [];
    vendorCodelist = [];
    vendorNameList = [];
    buyerList = [];
    transporterList = [];
    incomingPurchaseList.forEach((element) {
      if (element.series != null && !seriesList.contains(element.series)) {
        seriesList.add(element.series);
      }
      if (element.vendorCode != null &&
          !vendorCodelist.contains(element.vendorCode)) {
        vendorCodelist.add(element.vendorCode);
      }
      if (element.vendorName != null &&
          !vendorNameList.contains(element.vendorName)) {
        vendorNameList.add(element.vendorName);
      }
      if (element.buyer != null && !buyerList.contains(element.buyer)) {
        buyerList.add(element.buyer);
      }
      if (element.transporter != null &&
          !transporterList.contains(element.transporter)) {
        transporterList.add(element.transporter);
      }
    });
    seriesList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    vendorCodelist.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    vendorNameList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    buyerList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    transporterList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  setIncomingFilters(Map<String, dynamic> filterMap) {
    if (filterMap['selectedSeriesList'] != null) {
      filterMap['selectedSeriesList'].forEach((element) {
        selectedSeriesList.add(element);
      });
    }
    if (filterMap['selectedBuyerList'] != null)
      filterMap['selectedBuyerList'].forEach((element) {
        selectedBuyerList.add(element);
      });
    if (filterMap['selectedVendorCodelist'] != null)
      filterMap['selectedVendorCodelist'].forEach((element) {
        selectedVendorCodelist.add(element);
      });
    if (filterMap['selectedVendorNameList'] != null)
      filterMap['selectedVendorNameList'].forEach((element) {
        selectedVendorNameList.add(element);
      });
    if (filterMap['selectedTransporterList'] != null)
      filterMap['selectedTransporterList'].forEach((element) {
        selectedTransporterList.add(element);
      });
    if (filterMap['fromDate'] != null) {
      fromDate = filterMap['fromDate'];
      fromDateString = formatDate(fromDate);
    }
    if (filterMap['toDate'] != null) {
      toDate = filterMap['toDate'];
      toDateString = formatDate(toDate);
    }
    applyFilters();
  }

  _filterList(String item, bool isAdd, String selected) {
    if (item != null) {
      if (isAdd == true) {
        if (selected == 'Series') {
          selectedSeriesList.add(item);
        } else if (selected == 'Vendor Code') {
          selectedVendorCodelist.add(item);
        } else if (selected == 'Vendor Name') {
          selectedVendorNameList.add(item);
        } else if (selected == 'Buyer') {
          selectedBuyerList.add(item);
        } else if (selected == 'Transporter') {
          selectedTransporterList.add(item);
        }
      } else {
        if (selected == 'Series') {
          selectedSeriesList.remove(item);
        } else if (selected == 'Vendor Code') {
          selectedVendorCodelist.remove(item);
        } else if (selected == 'Vendor Name') {
          selectedVendorNameList.remove(item);
        } else if (selected == 'Buyer') {
          selectedBuyerList.remove(item);
        } else if (selected == 'Transporter') {
          selectedTransporterList.remove(item);
        }
      }
      applyFilters();
    }
  }

  applyFilters() {
    bool isChecked = (selectedBuyerList.length > 0 ||
            selectedVendorCodelist.length > 0 ||
            selectedVendorNameList.length > 0 ||
            selectedSeriesList.length > 0 ||
            selectedTransporterList.length > 0 ||
            fromDateString != null ||
            toDateString != null)
        ? true
        : false;
    if (isChecked) {
      filterList = [];
      incomingPurchaseList.forEach((element) {
        if ((selectedSeriesList.length == 0 ||
                selectedSeriesList.contains(element.series)) &&
            (selectedVendorCodelist.length == 0 ||
                selectedVendorCodelist.contains(element.vendorCode)) &&
            (selectedVendorNameList.length == 0 ||
                selectedVendorNameList.contains(element.vendorName)) &&
            (selectedTransporterList.length == 0 ||
                selectedTransporterList.contains(element.transporter)) &&
            (selectedBuyerList.length == 0 ||
                selectedBuyerList.contains(element.buyer))) {
          if (fromDateString != null && toDateString != null) {
            incomingPurchaseList.forEach((element) {
              if (element.dateTime != null &&
                  (fromDate.isBefore(element.dateTime) ||
                      fromDate.isAtSameMomentAs(element.dateTime)) &&
                  (toDate.isAfter(element.dateTime) ||
                      toDate.isAtSameMomentAs(element.dateTime)) &&
                  !filterList.contains(element)) {
                filterList.add(element);
              }
            });
          } else {
            if (fromDateString != null) {
              if (element.dateTime != null &&
                  (fromDate.isBefore(element.dateTime) ||
                      fromDate.isAtSameMomentAs(element.dateTime)) &&
                  !filterList.contains(element)) {
                filterList.add(element);
              }
            } else if (toDateString != null) {
              if (element.dateTime != null &&
                  (toDate.isAfter(element.dateTime) ||
                      toDate.isAtSameMomentAs(element.dateTime)) &&
                  !filterList.contains(element)) {
                filterList.add(element);
              }
            } else {
              filterList.add(element);
            }
          }
        }
      });
    } else {
      filterList = [];
      incomingPurchaseList.forEach((element) {
        filterList.add(element);
      });
    }
  }
}
