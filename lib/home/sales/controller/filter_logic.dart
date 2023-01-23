import 'package:intl/intl.dart';
import 'package:ocr/home/sales/model/sales.dart';

class SalesFilterLogic {
  SalesFilterLogic(List<Sales> salesList) {
    this.incomingSalesList = salesList;
    getOptionLists();
  }

  List<String> filtersOptionsList = [
    'Series',
    'Date',
    'Customer Code',
    'Customer Name',
    'City',
    'State',
    'Sales Employee',
    'Transporter',
    'Driver',
    'Nos'
  ];
  List seriesList = [],
      custCodelist = [],
      custNameList = [],
      cityList = [],
      stateList = [],
      salesEmpList = [],
      transporterList = [],
      driverList = [],
      nosList = [];
  List selectedSeriesList = [],
      selectedCustCodelist = [],
      selectedCustNameList = [],
      selectedCityList = [],
      selectedStateList = [],
      selectedSalesEmpList = [],
      selectedTransporterList = [],
      selectedDriverList = [],
      selectedNosList = [];

  List<Sales> filterList = [];
  List<Sales> incomingSalesList = [];

  DateTime fromDate = DateTime.now(), toDate = DateTime.now();
  String fromDateString, toDateString;

  String formatDate(DateTime date) => DateFormat('yyyy, dd MMM').format(date);

  getOptionLists() {
    seriesList = [];
    custCodelist = [];
    custNameList = [];
    cityList = [];
    stateList = [];
    salesEmpList = [];
    transporterList = [];
    driverList = [];
    nosList = [];
    incomingSalesList.forEach((element) {
      if (element.series != null && !seriesList.contains(element.series)) {
        seriesList.add(element.series);
      }
      if (element.customerCode != null &&
          !custCodelist.contains(element.customerCode)) {
        custCodelist.add(element.customerCode);
      }
      if (element.customerName != null &&
          !custNameList.contains(element.customerName)) {
        custNameList.add(element.customerName);
      }
      if (element.city != null && !cityList.contains(element.city)) {
        cityList.add(element.city);
      }
      if (element.state != null && !stateList.contains(element.state)) {
        stateList.add(element.state);
      }
      if (element.salesEmployee != null &&
          !salesEmpList.contains(element.salesEmployee)) {
        salesEmpList.add(element.salesEmployee);
      }
      if (element.transporter != null &&
          !transporterList.contains(element.transporter)) {
        transporterList.add(element.transporter);
      }
      if (element.driver != null && !driverList.contains(element.driver)) {
        driverList.add(element.driver);
      }
      if (element.nos != null && !nosList.contains(element.nos)) {
        nosList.add(element.nos);
      }
    });
    seriesList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    custCodelist.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    custNameList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    cityList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    stateList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    salesEmpList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    transporterList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    driverList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    nosList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  setIncomingFilters(Map<String, dynamic> filterMap) {
    if (filterMap['selectedCityList'] != null)
      filterMap['selectedCityList'].forEach((element) {
        selectedCityList.add(element);
      });
    if (filterMap['selectedCustCodelist'] != null)
      filterMap['selectedCustCodelist'].forEach((element) {
        selectedCustCodelist.add(element);
      });
    if (filterMap['selectedCustNameList'] != null)
      filterMap['selectedCustNameList'].forEach((element) {
        selectedCustNameList.add(element);
      });
    if (filterMap['selectedDriverList'] != null)
      filterMap['selectedDriverList'].forEach((element) {
        selectedDriverList.add(element);
      });
    if (filterMap['selectedNosList'] != null)
      filterMap['selectedNosList'].forEach((element) {
        selectedNosList.add(element);
      });
    if (filterMap['selectedSalesEmpList'] != null)
      filterMap['selectedSalesEmpList'].forEach((element) {
        selectedSalesEmpList.add(element);
      });
    if (filterMap['selectedSeriesList'] != null)
      filterMap['selectedSeriesList'].forEach((element) {
        selectedSeriesList.add(element);
      });
    if (filterMap['selectedStateList'] != null)
      filterMap['selectedStateList'].forEach((element) {
        selectedStateList.add(element);
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
        } else if (selected == 'Customer Code') {
          selectedCustCodelist.add(item);
        } else if (selected == 'Customer Name') {
          selectedCustNameList.add(item);
        } else if (selected == 'City') {
          selectedCityList.add(item);
        } else if (selected == 'State') {
          selectedStateList.add(item);
        } else if (selected == 'Sales Employee') {
          selectedSalesEmpList.add(item);
        } else if (selected == 'Transporter') {
          selectedTransporterList.add(item);
        } else if (selected == 'Driver') {
          selectedDriverList.add(item);
        } else if (selected == 'Nos') {
          selectedNosList.add(item);
        }
      } else {
        if (selected == 'Series') {
          selectedSeriesList.remove(item);
        } else if (selected == 'Customer Code') {
          selectedCustCodelist.remove(item);
        } else if (selected == 'Customer Name') {
          selectedCustNameList.remove(item);
        } else if (selected == 'City') {
          selectedCityList.remove(item);
        } else if (selected == 'State') {
          selectedStateList.remove(item);
        } else if (selected == 'Sales Employee') {
          selectedSalesEmpList.remove(item);
        } else if (selected == 'Transporter') {
          selectedTransporterList.remove(item);
        } else if (selected == 'Driver') {
          selectedDriverList.remove(item);
        } else if (selected == 'Nos') {
          selectedNosList.remove(item);
        }
      }
      applyFilters();
    }
  }

  applyFilters() {
    bool isChecked = (selectedCityList.length > 0 ||
            selectedCustCodelist.length > 0 ||
            selectedCustNameList.length > 0 ||
            selectedDriverList.length > 0 ||
            selectedNosList.length > 0 ||
            selectedSalesEmpList.length > 0 ||
            selectedSeriesList.length > 0 ||
            selectedStateList.length > 0 ||
            selectedTransporterList.length > 0 ||
            fromDateString != null ||
            toDateString != null)
        ? true
        : false;
    if (isChecked) {
      filterList = [];
      incomingSalesList.forEach((element) {
        if ((selectedSeriesList.length == 0 ||
                selectedSeriesList.contains(element.series)) &&
            (selectedCustCodelist.length == 0 ||
                selectedCustCodelist.contains(element.customerCode)) &&
            (selectedCustNameList.length == 0 ||
                selectedCustNameList.contains(element.customerName)) &&
            (selectedDriverList.length == 0 ||
                selectedDriverList.contains(element.driver)) &&
            (selectedNosList.length == 0 ||
                selectedNosList.contains(element.nos)) &&
            (selectedSalesEmpList.length == 0 ||
                selectedSalesEmpList.contains(element.salesEmployee)) &&
            (selectedStateList.length == 0 ||
                selectedStateList.contains(element.state)) &&
            (selectedTransporterList.length == 0 ||
                selectedTransporterList.contains(element.transporter)) &&
            (selectedCityList.length == 0 ||
                selectedCityList.contains(element.city))) {
          if (fromDateString != null && toDateString != null) {
            if (element.dateTime != null &&
                (fromDate.isBefore(element.dateTime) ||
                    fromDate.isAtSameMomentAs(element.dateTime)) &&
                (toDate.isAfter(element.dateTime) ||
                    toDate.isAtSameMomentAs(element.dateTime)) &&
                !filterList.contains(element)) {
              filterList.add(element);
            }
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
      incomingSalesList.forEach((element) {
        filterList.add(element);
      });
    }
  }
}
