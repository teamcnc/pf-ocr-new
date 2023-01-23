import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:ocr/home/sales/model/sales.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/multiple_chips.dart';

import 'multi_checkbox.dart';

class SalesFilters extends StatefulWidget {
  List<Sales> salesList;
  List selectedSeriesList = [],
      selectedCustCodelist = [],
      selectedCustNameList = [],
      selectedCityList = [],
      selectedStateList = [],
      selectedSalesEmpList = [],
      selectedTransporterList = [],
      selectedDriverList = [],
      selectedNosList = [];
  DateTime fromDate, toDate;
  SalesFilters(
      {Key key,
      this.salesList,
      this.selectedCityList,
      this.selectedCustCodelist,
      this.selectedCustNameList,
      this.selectedDriverList,
      this.selectedNosList,
      this.selectedSalesEmpList,
      this.selectedSeriesList,
      this.selectedStateList,
      this.selectedTransporterList,
      this.fromDate,
      this.toDate})
      : super(key: key);

  @override
  _SalesFiltersState createState() => _SalesFiltersState();
}

class _SalesFiltersState extends State<SalesFilters> {
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

  DateTime fromDate = DateTime.now(), toDate = DateTime.now();
  String fromDateString, toDateString;

  String formatDate(DateTime date) => DateFormat('yyyy, dd MMM').format(date);

  @override
  void initState() {
    super.initState();
    // if (widget.salesList != null) {
    //   widget.salesList.forEach((element) {
    //     filterList.add(element);
    //   });
    // }
    getOptionLists();
    setIncomingFilters();
  }

  setIncomingFilters() {
    if (widget.selectedCityList != null)
      widget.selectedCityList.forEach((element) {
        selectedCityList.add(element);
      });
    if (widget.selectedCustCodelist != null)
      widget.selectedCustCodelist.forEach((element) {
        selectedCustCodelist.add(element);
      });
    if (widget.selectedCustNameList != null)
      widget.selectedCustNameList.forEach((element) {
        selectedCustNameList.add(element);
      });
    if (widget.selectedDriverList != null)
      widget.selectedDriverList.forEach((element) {
        selectedDriverList.add(element);
      });
    if (widget.selectedNosList != null)
      widget.selectedNosList.forEach((element) {
        selectedNosList.add(element);
      });
    if (widget.selectedSalesEmpList != null)
      widget.selectedSalesEmpList.forEach((element) {
        selectedSalesEmpList.add(element);
      });
    if (widget.selectedSeriesList != null)
      widget.selectedSeriesList.forEach((element) {
        selectedSeriesList.add(element);
      });
    if (widget.selectedStateList != null)
      widget.selectedStateList.forEach((element) {
        selectedStateList.add(element);
      });
    if (widget.selectedTransporterList != null)
      widget.selectedTransporterList.forEach((element) {
        selectedTransporterList.add(element);
      });
    if (widget.fromDate != null) {
      fromDate = widget.fromDate;
      fromDateString = formatDate(fromDate);
    }
    if (widget.toDate != null) {
      toDate = widget.toDate;
      toDateString = formatDate(toDate);
    }
    applyFilters();
  }

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
    widget.salesList.forEach((element) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // backgroundColor: Colors.grey.withOpacity(0.4),
        appBar: AppBar(
          backgroundColor: AppColors.appTheame,
          title: Text("Select Filters"),
          actions: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appTheame,
                  ),
                  // color: Colors.white,
                  onPressed: () {
                    if (widget.salesList != null) filterList = widget.salesList;
                    getOptionLists();
                    fromDate = DateTime.now();
                    toDate = DateTime.now();
                    fromDateString = null;
                    toDateString = null;

                    Map<String, dynamic> popData = {
                      'filterList': filterList,
                    };

                    Navigator.pop(context, popData);
                  },
                  child: Text("CLEAR")),
            )
          ],
        ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 20, top: 10),
                itemCount: filtersOptionsList.length,
                itemBuilder: (listContext, index) {
                  if (filtersOptionsList[index] == 'Date')
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Text(
                              filtersOptionsList[index],
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        DateTime tempDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: fromDate,
                                                firstDate: DateTime(1900),
                                                lastDate: toDateString != null
                                                    ? toDate
                                                    : DateTime.now());
                                        if (tempDate != null) {
                                          fromDate = tempDate;
                                          fromDateString = formatDate(fromDate);
                                        }
                                        applyFilters();
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.6))),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "From",
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  fromDateString != null
                                                      ? "$fromDateString"
                                                      : "-",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(Icons.calendar_today)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        DateTime tempDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: toDate,
                                                firstDate:
                                                    fromDateString != null
                                                        ? fromDate
                                                        : DateTime(1900),
                                                lastDate: DateTime.now());
                                        if (tempDate != null) {
                                          toDate = tempDate;
                                          toDateString = formatDate(toDate);
                                        }
                                        applyFilters();
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.6))),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "To",
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  toDateString != null
                                                      ? "$toDateString"
                                                      : "-",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(Icons.calendar_today),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ),
                    );
                  else
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Text(
                              filtersOptionsList[index],
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                          MultipleChips(
                            items: (filtersOptionsList[index] == 'Series'
                                    ? selectedSeriesList
                                    : filtersOptionsList[index] ==
                                            'Customer Code'
                                        ? selectedCustCodelist
                                        : filtersOptionsList[index] ==
                                                'Customer Name'
                                            ? selectedCustNameList
                                            : filtersOptionsList[index] ==
                                                    'City'
                                                ? selectedCityList
                                                : filtersOptionsList[index] ==
                                                        'State'
                                                    ? selectedStateList
                                                    : filtersOptionsList[
                                                                index] ==
                                                            'Sales Employee'
                                                        ? selectedSalesEmpList
                                                        : filtersOptionsList[
                                                                    index] ==
                                                                'Transporter'
                                                            ? selectedTransporterList
                                                            : filtersOptionsList[
                                                                        index] ==
                                                                    'Driver'
                                                                ? selectedDriverList
                                                                : filtersOptionsList[
                                                                            index] ==
                                                                        'Nos'
                                                                    ? selectedNosList
                                                                    : filterList)
                                .map((e) => MultiSelectItem(e, e))
                                .toList(),
                            onRemove: (value) {
                              _filterList(
                                  value, false, filtersOptionsList[index]);
                              FocusScope.of(context).unfocus();
                            },
                          ),
                          // MultiSelectChipDisplay(
                          //   // icon: Icon(
                          //   //   Icons.close,
                          //   //   color: Colors.white,
                          //   // ),
                          //   items: (filtersOptionsList[index] == 'Series'
                          //           ? selectedSeriesList
                          //           : filtersOptionsList[index] ==
                          //                   'Customer Code'
                          //               ? selectedCustCodelist
                          //               : filtersOptionsList[index] ==
                          //                       'Customer Name'
                          //                   ? selectedCustNameList
                          //                   : filtersOptionsList[index] ==
                          //                           'City'
                          //                       ? selectedCityList
                          //                       : filtersOptionsList[index] ==
                          //                               'State'
                          //                           ? selectedStateList
                          //                           : filtersOptionsList[
                          //                                       index] ==
                          //                                   'Sales Employee'
                          //                               ? selectedSalesEmpList
                          //                               : filtersOptionsList[
                          //                                           index] ==
                          //                                       'Transporter'
                          //                                   ? selectedTransporterList
                          //                                   : filtersOptionsList[
                          //                                               index] ==
                          //                                           'Driver'
                          //                                       ? selectedDriverList
                          //                                       : filtersOptionsList[
                          //                                                   index] ==
                          //                                               'Nos'
                          //                                           ? selectedNosList
                          //                                           : filterList)
                          //       .map((e) => MultiSelectItem(e, e))
                          //       .toList(),
                          //   // onTap: (value) {
                          //   //   setState(() {
                          //   //     _filterList(
                          //   //         value, false, filtersOptionsList[index]);
                          //   //   });
                          //   // },
                          //   chipColor: AppColors.appTheame,
                          //   textStyle: TextStyle(color: Colors.white),
                          // ),
                          Container(
                            height: 65,
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 10.0, right: 10, bottom: 20),
                            child: TypeAheadFormField(
                                autoFlipDirection: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: filtersOptionsList[index],
                                        hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14),
                                        contentPadding:
                                            EdgeInsets.only(top: 5, left: 10),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            borderSide: BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.6))),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            borderSide: BorderSide(
                                                color: AppColors.appTheame))),
                                    // controller: _companyName,
                                    onSubmitted: (value) {
                                      // FocusScope.of(context)
                                      //     .requestFocus(_emailFocus);
                                    }),
                                suggestionsCallback: (pattern) {
                                  // return _organizationList
                                  //     .getDataFromUri(pattern);
                                  return filtersOptionsList[index] == 'Series'
                                      ? seriesList.where((element) => element
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()))
                                      : filtersOptionsList[index] ==
                                              'Customer Code'
                                          ? custCodelist.where((element) => element
                                              .toLowerCase()
                                              .contains(pattern.toLowerCase()))
                                          : filtersOptionsList[index] ==
                                                  'Customer Name'
                                              ? custNameList.where((element) =>
                                                  element.toLowerCase().contains(
                                                      pattern.toLowerCase()))
                                              : filtersOptionsList[index] ==
                                                      'City'
                                                  ? cityList.where((element) =>
                                                      element
                                                          .toLowerCase()
                                                          .contains(pattern.toLowerCase()))
                                                  : filtersOptionsList[index] == 'State'
                                                      ? stateList.where((element) => element.toLowerCase().contains(pattern.toLowerCase()))
                                                      : filtersOptionsList[index] == 'Sales Employee'
                                                          ? salesEmpList.where((element) => element.toLowerCase().contains(pattern.toLowerCase()))
                                                          : filtersOptionsList[index] == 'Transporter'
                                                              ? transporterList.where((element) => element.toLowerCase().contains(pattern.toLowerCase()))
                                                              : filtersOptionsList[index] == 'Driver'
                                                                  ? driverList.where((element) => element.toLowerCase().contains(pattern.toLowerCase()))
                                                                  : filtersOptionsList[index] == 'Nos'
                                                                      ? nosList.where((element) => element.toLowerCase().contains(pattern.toLowerCase()))
                                                                      : filterList;
                                },
                                itemBuilder: (context, item) {
                                  var checked = filtersOptionsList[index] ==
                                          'Series'
                                      ? selectedSeriesList.contains(item)
                                      : filtersOptionsList[index] ==
                                              'Customer Code'
                                          ? selectedCustCodelist.contains(item)
                                          : filtersOptionsList[index] ==
                                                  'Customer Name'
                                              ? selectedCustNameList
                                                  .contains(item)
                                              : filtersOptionsList[index] ==
                                                      'City'
                                                  ? selectedCityList
                                                      .contains(item)
                                                  : filtersOptionsList[index] ==
                                                          'State'
                                                      ? selectedStateList
                                                          .contains(item)
                                                      : filtersOptionsList[index] ==
                                                              'Sales Employee'
                                                          ? selectedSalesEmpList
                                                              .contains(item)
                                                          : filtersOptionsList[
                                                                      index] ==
                                                                  'Transporter'
                                                              ? selectedTransporterList
                                                                  .contains(
                                                                      item)
                                                              : filtersOptionsList[index] ==
                                                                      'Driver'
                                                                  ? selectedDriverList
                                                                      .contains(
                                                                          item)
                                                                  : filtersOptionsList[index] ==
                                                                          'Nos'
                                                                      ? selectedNosList.contains(
                                                                          item)
                                                                      : filterList
                                                                          .contains(item);
                                  return MultiCheckBox(
                                    isChecked: checked,
                                    item: item,
                                    onChanged: (value) {
                                      // setState(() {
                                      _filterList(item, value,
                                          filtersOptionsList[index]);
                                      // });
                                    },
                                  );
                                },
                                transitionBuilder:
                                    (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                                noItemsFoundBuilder: (context) {
                                  return Container(
                                    height: 35,
                                    child: Center(
                                      child: Text(
                                        "No items found!",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.appTheame,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {},
                                onSaved: (suggestion) {}),
                          ),
                          //   Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 10.0, horizontal: 10.0),
                          //     child: AutoCompleteTextField(
                          //       key: new GlobalKey(),
                          //       minLength: 0,
                          //       submitOnSuggestionTap: false,
                          //       // controller: _suggestionTextFeildSearchController,
                          //       suggestions: filtersOptionsList[index] == 'Series'
                          //           ? seriesList
                          //           : filtersOptionsList[index] == 'Customer Code'
                          //               ? custCodelist
                          //               : filtersOptionsList[index] ==
                          //                       'Customer Name'
                          //                   ? custNameList
                          //                   : filtersOptionsList[index] == 'City'
                          //                       ? cityList
                          //                       : filtersOptionsList[index] ==
                          //                               'State'
                          //                           ? stateList
                          //                           : filtersOptionsList[index] ==
                          //                                   'Sales Employee'
                          //                               ? salesEmpList
                          //                               : filtersOptionsList[
                          //                                           index] ==
                          //                                       'Transporter'
                          //                                   ? transporterList
                          //                                   : filtersOptionsList[
                          //                                               index] ==
                          //                                           'Driver'
                          //                                       ? driverList
                          //                                       : filtersOptionsList[
                          //                                                   index] ==
                          //                                               'Nos'
                          //                                           ? nosList
                          //                                           : filterList,
                          //       suggestionsAmount: 100,
                          //       maxHeight: 300,
                          //       clearOnSubmit: true,
                          //       textSubmitted: (value) {},
                          //       // style: TextStyle(
                          //       //     color: Colors.blue),
                          //       decoration: InputDecoration(
                          //           fillColor: Colors.white,
                          //           filled: true,
                          //           hintText: filtersOptionsList[index],
                          //           hintStyle: TextStyle(
                          //             color: Colors.grey,
                          //             fontWeight: FontWeight.normal,
                          //           ),
                          //           border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(10),
                          //               borderSide: BorderSide.none)),
                          //       itemFilter: (item, query) {
                          //         if (filtersOptionsList[index] == 'Series')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] ==
                          //             'Customer Code')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] ==
                          //             'Customer Name')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] == 'City')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] == 'State')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] ==
                          //             'Sales Employee')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] ==
                          //             'Transporter')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] == 'Driver')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] == 'Nos')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else
                          //           return false;
                          //       },
                          //       itemSorter: (a, b) {
                          //         return a.compareTo(b);
                          //         // return sortListItems(
                          //         //     filtersOptionsList[index], a, b);
                          //       },
                          //       itemSubmitted: (item) {
                          //         // _suggestionTextFeildController.text = item;
                          //         // _filterList(item);
                          //       },
                          //       itemBuilder: (context, item) {
                          //         var checked = filtersOptionsList[index] ==
                          //                 'Series'
                          //             ? selectedSeriesList.contains(item)
                          //             : filtersOptionsList[index] == 'Customer Code'
                          //                 ? selectedCustCodelist.contains(item)
                          //                 : filtersOptionsList[index] ==
                          //                         'Customer Name'
                          //                     ? selectedCustNameList.contains(item)
                          //                     : filtersOptionsList[index] == 'City'
                          //                         ? selectedCityList.contains(item)
                          //                         : filtersOptionsList[index] ==
                          //                                 'State'
                          //                             ? selectedStateList
                          //                                 .contains(item)
                          //                             : filtersOptionsList[index] ==
                          //                                     'Sales Employee'
                          //                                 ? selectedSalesEmpList
                          //                                     .contains(item)
                          //                                 : filtersOptionsList[index] ==
                          //                                         'Transporter'
                          //                                     ? selectedTransporterList
                          //                                         .contains(item)
                          //                                     : filtersOptionsList[
                          //                                                 index] ==
                          //                                             'Driver'
                          //                                         ? selectedDriverList
                          //                                             .contains(
                          //                                                 item)
                          //                                         : filtersOptionsList[
                          //                                                     index] ==
                          //                                                 'Nos'
                          //                                             ? selectedNosList
                          //                                                 .contains(
                          //                                                     item)
                          //                                             : filterList
                          //                                                 .contains(
                          //                                                     item);
                          //         return MultiCheckBox(
                          //           isChecked: checked,
                          //           item: item,
                          //           onChanged: (value) {
                          //             // setState(() {
                          //             _filterList(
                          //                 item, value, filtersOptionsList[index]);
                          //             // });
                          //           },
                          //         );
                          //         // Container(
                          //         //   padding: EdgeInsets.all(5.0),
                          //         //   child: CheckboxListTile(
                          //         //     value: checked,
                          //         //     title: Text(item),
                          //         //     // item.customerCode
                          //         //     // filtersOptionsList[index] == 'Series'
                          //         //     //     ? item.series
                          //         //     //     : filtersOptionsList[index] ==
                          //         //     //             'Customer Code'
                          //         //     //         ? item.customerCode
                          //         //     //         : filtersOptionsList[index] ==
                          //         //     //                 'Customer Name'
                          //         //     //             ? item.customerName
                          //         //     //             : filtersOptionsList[index] ==
                          //         //     //                     'City'
                          //         //     //                 ? item.city
                          //         //     //                 : filtersOptionsList[
                          //         //     //                             index] ==
                          //         //     //                         'State'
                          //         //     //                     ? item.state
                          //         //     //                     : filtersOptionsList[
                          //         //     //                                 index] ==
                          //         //     //                             'Sales Employee'
                          //         //     //                         ? item.salesEmployee
                          //         //     //                         : filtersOptionsList[
                          //         //     //                                     index] ==
                          //         //     //                                 'Transporter'
                          //         //     //                             ? item
                          //         //     //                                 .transporter
                          //         //     //                             : filtersOptionsList[
                          //         //     //                                         index] ==
                          //         //     //                                     'Driver'
                          //         //     //                                 ? item
                          //         //     //                                     .driver
                          //         //     //                                 : filtersOptionsList[index] ==
                          //         //     //                                         'Nos'
                          //         //     //                                     ? item
                          //         //     //                                         .nos
                          //         //     //                                     : ''),
                          //         //     controlAffinity:
                          //         //         ListTileControlAffinity.leading,
                          //         //     onChanged: (checked) {
                          //         //       setState(() {
                          //         //         _filterList(item, checked,
                          //         //             filtersOptionsList[index]);
                          //         //       });
                          //         //     },
                          //         //   ),
                          //         // );
                          //       },
                          //     ),
                          //   ),
                        ],
                      ),
                    );
                })),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(0.4)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${filterList.length}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text("records found")
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appTheame,
                    ),
                    // color: AppColors.appTheame,
                    onPressed: () {
                      Map<String, dynamic> popData = {
                        'filterList': filterList,
                        'selectedSeriesList': selectedSeriesList,
                        'selectedCustCodelist': selectedCustCodelist,
                        'selectedCustNameList': selectedCustNameList,
                        'selectedCityList': selectedCityList,
                        'selectedStateList': selectedStateList,
                        'selectedSalesEmpList': selectedSalesEmpList,
                        'selectedTransporterList': selectedTransporterList,
                        'selectedDriverList': selectedDriverList,
                        'selectedNosList': selectedNosList,
                        'fromDate': fromDateString != null ? fromDate : null,
                        'toDate': toDateString != null ? toDate : null
                      };
                      Navigator.pop(context, popData);
                    },
                    child: Text(
                      "APPLY",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
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
      setState(() {});
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
      widget.salesList.forEach((element) {
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
      widget.salesList.forEach((element) {
        filterList.add(element);
      });
    }
    setState(() {});
  }
}
