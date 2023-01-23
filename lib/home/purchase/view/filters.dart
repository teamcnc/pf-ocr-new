import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:ocr/home/purchase/model/purchase.dart';
import 'package:ocr/home/sales/view/multi_checkbox.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/multiple_chips.dart';

class PurchaseFilters extends StatefulWidget {
  List<Purchase> purchaseList;
  List selectedSeriesList = [],
      selectedVendorCodelist = [],
      selectedVendorNameList = [],
      selectedBuyerList = [],
      selectedTransporterList = [];
  DateTime fromDate, toDate;
  PurchaseFilters(
      {Key key,
      this.purchaseList,
      this.selectedBuyerList,
      this.selectedVendorCodelist,
      this.selectedVendorNameList,
      this.selectedSeriesList,
      this.selectedTransporterList,
      this.fromDate,
      this.toDate})
      : super(key: key);

  @override
  _PurchaseFiltersState createState() => _PurchaseFiltersState();
}

class _PurchaseFiltersState extends State<PurchaseFilters> {
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

  DateTime fromDate = DateTime.now(), toDate = DateTime.now();
  String fromDateString, toDateString;

  String formatDate(DateTime date) => DateFormat('yyyy, dd MMM').format(date);

  @override
  void initState() {
    super.initState();
    // if (widget.purchaseList != null) {
    //   widget.purchaseList.forEach((element) {
    //     filterList.add(element);
    //   });
    // }
    // filterList = widget.purchaseList;
    getOptionLists();
    setIncomingFilters();
  }

  setIncomingFilters() {
    if (widget.selectedSeriesList != null) {
      widget.selectedSeriesList.forEach((element) {
        selectedSeriesList.add(element);
      });
    }
    if (widget.selectedBuyerList != null)
      widget.selectedBuyerList.forEach((element) {
        selectedBuyerList.add(element);
      });
    if (widget.selectedVendorCodelist != null)
      widget.selectedVendorCodelist.forEach((element) {
        selectedVendorCodelist.add(element);
      });
    if (widget.selectedVendorNameList != null)
      widget.selectedVendorNameList.forEach((element) {
        selectedVendorNameList.add(element);
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
    vendorCodelist = [];
    vendorNameList = [];
    buyerList = [];
    transporterList = [];
    widget.purchaseList.forEach((element) {
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
                    backgroundColor: Colors.white,
                  ),
                  // color: Colors.white,
                  onPressed: () {
                    if (widget.purchaseList != null)
                      filterList = widget.purchaseList;
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
                itemCount: filtersOptionsList.length,
                padding: EdgeInsets.only(bottom: 20, top: 10),
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
                                    : filtersOptionsList[index] == 'Vendor Code'
                                        ? selectedVendorCodelist
                                        : filtersOptionsList[index] ==
                                                'Vendor Name'
                                            ? selectedVendorNameList
                                            : filtersOptionsList[index] ==
                                                    'Buyer'
                                                ? selectedBuyerList
                                                : filtersOptionsList[index] ==
                                                        'Transporter'
                                                    ? selectedTransporterList
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
                          //   items: (filtersOptionsList[index] == 'Series'
                          //           ? selectedSeriesList
                          //           : filtersOptionsList[index] == 'Vendor Code'
                          //               ? selectedVendorCodelist
                          //               : filtersOptionsList[index] ==
                          //                       'Vendor Name'
                          //                   ? selectedVendorNameList
                          //                   : filtersOptionsList[index] ==
                          //                           'Buyer'
                          //                       ? selectedBuyerList
                          //                       : filtersOptionsList[index] ==
                          //                               'Transporter'
                          //                           ? selectedTransporterList
                          //                           : filterList)
                          //       .map((e) => MultiSelectItem(e, e))
                          //       .toList(),
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
                                    onSubmitted: (value) {}),
                                suggestionsCallback: (pattern) {
                                  // return _organizationList
                                  //     .getDataFromUri(pattern);
                                  return filtersOptionsList[index] == 'Series'
                                      ? seriesList.where((element) => element
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()))
                                      : filtersOptionsList[index] ==
                                              'Vendor Code'
                                          ? vendorCodelist.where((element) => element
                                              .toLowerCase()
                                              .contains(pattern.toLowerCase()))
                                          : filtersOptionsList[index] ==
                                                  'Vendor Name'
                                              ? vendorNameList.where((element) =>
                                                  element.toLowerCase().contains(
                                                      pattern.toLowerCase()))
                                              : filtersOptionsList[index] ==
                                                      'Buyer'
                                                  ? buyerList.where((element) =>
                                                      element
                                                          .toLowerCase()
                                                          .contains(pattern.toLowerCase()))
                                                  : filtersOptionsList[index] == 'Transporter'
                                                      ? transporterList.where((element) => element.toLowerCase().contains(pattern.toLowerCase()))
                                                      : filterList;
                                },
                                itemBuilder: (context, item) {
                                  var checked = filtersOptionsList[index] ==
                                          'Series'
                                      ? selectedSeriesList.contains(item)
                                      : filtersOptionsList[index] ==
                                              'Vendor Code'
                                          ? selectedVendorCodelist
                                              .contains(item)
                                          : filtersOptionsList[index] ==
                                                  'Vendor Name'
                                              ? selectedVendorNameList
                                                  .contains(item)
                                              : filtersOptionsList[index] ==
                                                      'Buyer'
                                                  ? selectedBuyerList
                                                      .contains(item)
                                                  : filtersOptionsList[index] ==
                                                          'Transporter'
                                                      ? selectedTransporterList
                                                          .contains(item)
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
                          //       suggestions: filtersOptionsList[index] == 'Series'
                          //           ? seriesList
                          //           : filtersOptionsList[index] == 'Vendor Code'
                          //               ? vendorCodelist
                          //               : filtersOptionsList[index] == 'Vendor Name'
                          //                   ? vendorNameList
                          //                   : filtersOptionsList[index] == 'Buyer'
                          //                       ? buyerList
                          //                       : filtersOptionsList[index] ==
                          //                               'Transporter'
                          //                           ? transporterList
                          //                           : filterList,
                          //       suggestionsAmount: 100,
                          //       maxHeight: 300,
                          //       clearOnSubmit: true,
                          //       textSubmitted: (value) {},
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
                          //             'Vendor Code')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] ==
                          //             'Vendor Name')
                          //           return item
                          //                       .toLowerCase()
                          //                       .contains(query.toLowerCase()) ||
                          //                   item
                          //                       .toLowerCase()
                          //                       .startsWith(query.toLowerCase())
                          //               ? true
                          //               : false;
                          //         else if (filtersOptionsList[index] == 'Buyer')
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
                          //         else
                          //           return false;
                          //       },
                          //       itemSorter: (a, b) {
                          //         return a.compareTo(b);
                          //       },
                          //       itemSubmitted: (item) {},
                          //       itemBuilder: (context, item) {
                          //         var checked = filtersOptionsList[index] ==
                          //                 'Series'
                          //             ? selectedSeriesList.contains(item)
                          //             : filtersOptionsList[index] == 'Vendor Code'
                          //                 ? selectedVendorCodelist.contains(item)
                          //                 : filtersOptionsList[index] ==
                          //                         'Vendor Name'
                          //                     ? selectedVendorNameList
                          //                         .contains(item)
                          //                     : filtersOptionsList[index] == 'Buyer'
                          //                         ? selectedBuyerList.contains(item)
                          //                         : filtersOptionsList[index] ==
                          //                                 'Transporter'
                          //                             ? selectedTransporterList
                          //                                 .contains(item)
                          //                             : filterList.contains(item);
                          //         return Container(
                          //           padding: EdgeInsets.all(5.0),
                          //           child: CheckboxListTile(
                          //             value: checked,
                          //             title: Text(item),
                          //             controlAffinity:
                          //                 ListTileControlAffinity.leading,
                          //             onChanged: (checked) {
                          //               setState(() {
                          //                 _filterList(item, checked,
                          //                     filtersOptionsList[index]);
                          //               });
                          //             },
                          //           ),
                          //         );
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
                        'selectedVendorCodelist': selectedVendorCodelist,
                        'selectedVendorNameList': selectedVendorNameList,
                        'selectedBuyerList': selectedBuyerList,
                        'selectedTransporterList': selectedTransporterList,
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
      setState(() {});
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
      widget.purchaseList.forEach((element) {
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
            widget.purchaseList.forEach((element) {
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
      // if (selectedSeriesList.length > 0) {
      //   // if (filterList.length > 0 ||
      //   //     selectedBuyerList.length > 0 ||
      //   //     selectedVendorCodelist.length > 0 ||
      //   //     selectedVendorNameList.length > 0 ||
      //   //     selectedTransporterList.length > 0 ||
      //   //     fromDateString != null ||
      //   //     toDateString != null) {
      //   //   List tempList = [];
      //   //   filterList.forEach((element) {
      //   //     tempList.add(element);
      //   //   });
      //   //   tempList.forEach((element) {
      //   //     if (selectedSeriesList.contains(element.series)) {
      //   //       if (!filterList.contains(element)) {
      //   //         filterList.add(element);
      //   //       }
      //   //     } else if (filterList.contains(element)) {
      //   //       filterList.remove(element);
      //   //     }
      //   //   });
      //   // } else
      //   widget.purchaseList.forEach((element) {
      //     if (selectedSeriesList.contains(element.series) &&
      //         !filterList.contains(element)) {
      //       filterList.add(element);
      //     }
      //   });
      // }
      // if (selectedVendorCodelist.length > 0) {
      //   // if (filterList.length > 0 ||
      //   //     selectedBuyerList.length > 0 ||
      //   //     selectedVendorNameList.length > 0 ||
      //   //     selectedSeriesList.length > 0 ||
      //   //     selectedTransporterList.length > 0 ||
      //   //     fromDateString != null ||
      //   //     toDateString != null) {
      //   //   List tempList = [];
      //   //   filterList.forEach((element) {
      //   //     tempList.add(element);
      //   //   });
      //   //   tempList.forEach((element) {
      //   //     if (selectedVendorCodelist.contains(element.vendorCode)) {
      //   //       if (!filterList.contains(element)) {
      //   //         filterList.add(element);
      //   //       }
      //   //     } else if (filterList.contains(element)) {
      //   //       filterList.remove(element);
      //   //     }
      //   //   });
      //   // } else
      //   widget.purchaseList.forEach((element) {
      //     if (selectedVendorCodelist.contains(element.vendorCode) &&
      //         !filterList.contains(element)) {
      //       filterList.add(element);
      //     }
      //   });
      // }
      // if (selectedVendorNameList.length > 0) {
      //   // if (filterList.length > 0 ||
      //   //     selectedBuyerList.length > 0 ||
      //   //     selectedVendorCodelist.length > 0 ||
      //   //     selectedSeriesList.length > 0 ||
      //   //     selectedTransporterList.length > 0 ||
      //   //     fromDateString != null ||
      //   //     toDateString != null) {
      //   //   List tempList = [];
      //   //   filterList.forEach((element) {
      //   //     tempList.add(element);
      //   //   });
      //   //   tempList.forEach((element) {
      //   //     if (selectedVendorNameList.contains(element.vendorName)) {
      //   //       if (!filterList.contains(element)) {
      //   //         filterList.add(element);
      //   //       }
      //   //     } else if (filterList.contains(element)) {
      //   //       filterList.remove(element);
      //   //     }
      //   //   });
      //   // } else
      //   widget.purchaseList.forEach((element) {
      //     if (selectedVendorNameList.contains(element.vendorName) &&
      //         !filterList.contains(element)) {
      //       filterList.add(element);
      //     }
      //   });
      // }
      // if (selectedTransporterList.length > 0) {
      //   // if (filterList.length > 0 ||
      //   //     selectedBuyerList.length > 0 ||
      //   //     selectedVendorCodelist.length > 0 ||
      //   //     selectedVendorNameList.length > 0 ||
      //   //     selectedSeriesList.length > 0 ||
      //   //     fromDateString != null ||
      //   //     toDateString != null) {
      //   //   print("In If");
      //   //   List tempList = [];
      //   //   filterList.forEach((element) {
      //   //     tempList.add(element);
      //   //   });
      //   //   tempList.forEach((element) {
      //   //     if (selectedTransporterList.contains(element.transporter)) {
      //   //       if (!filterList.contains(element)) {
      //   //         filterList.add(element);
      //   //       }
      //   //     } else if (filterList.contains(element)) {
      //   //       filterList.remove(element);
      //   //     }
      //   //   });
      //   // } else {
      //   // print("In Else");
      //   widget.purchaseList.forEach((element) {
      //     if (selectedTransporterList.contains(element.transporter) &&
      //         !filterList.contains(element)) {
      //       filterList.add(element);
      //     }
      //   });
      //   // }
      // }
      // if (selectedBuyerList.length > 0) {
      //   // if (filterList.length > 0 ||
      //   //     selectedVendorCodelist.length > 0 ||
      //   //     selectedVendorNameList.length > 0 ||
      //   //     selectedSeriesList.length > 0 ||
      //   //     selectedTransporterList.length > 0 ||
      //   //     fromDateString != null ||
      //   //     toDateString != null) {
      //   //   List tempList = [];
      //   //   filterList.forEach((element) {
      //   //     tempList.add(element);
      //   //   });
      //   //   tempList.forEach((element) {
      //   //     if (selectedBuyerList.contains(element.buyer)) {
      //   //       if (!filterList.contains(element)) {
      //   //         filterList.add(element);
      //   //       }
      //   //     } else if (filterList.contains(element)) {
      //   //       filterList.remove(element);
      //   //     }
      //   //   });
      //   // } else
      //   widget.purchaseList.forEach((element) {
      //     if (selectedBuyerList.contains(element.buyer) &&
      //         !filterList.contains(element)) {
      //       filterList.add(element);
      //     }
      //   });
      // }
      // if (fromDateString != null && toDateString != null) {
      //   widget.purchaseList.forEach((element) {
      //     if (element.dateTime != null &&
      //         (fromDate.isBefore(element.dateTime) ||
      //             fromDate.isAtSameMomentAs(element.dateTime)) &&
      //         (toDate.isAfter(element.dateTime) ||
      //             toDate.isAtSameMomentAs(element.dateTime)) &&
      //         !filterList.contains(element)) {
      //       filterList.add(element);
      //     }
      //   });
      // } else {
      //   if (fromDateString != null) {
      //     // if (filterList.length > 0 ||
      //     //     selectedBuyerList.length > 0 ||
      //     //     selectedVendorCodelist.length > 0 ||
      //     //     selectedVendorNameList.length > 0 ||
      //     //     selectedSeriesList.length > 0 ||
      //     //     selectedTransporterList.length > 0 ||
      //     //     toDateString != null) {
      //     //   List tempList = [];
      //     //   filterList.forEach((element) {
      //     //     tempList.add(element);
      //     //   });
      //     //   tempList.forEach((element) {
      //     //     if (element.dateTime != null &&
      //     //         (fromDate.isBefore(element.dateTime) ||
      //     //             fromDate.isAtSameMomentAs(element.dateTime))) {
      //     //       // if (selectedBuyerList.contains(element.Buyer)) {
      //     //       if (!filterList.contains(element)) {
      //     //         filterList.add(element);
      //     //       }
      //     //     } else if (filterList.contains(element)) {
      //     //       filterList.remove(element);
      //     //     }
      //     //   });
      //     // } else
      //     widget.purchaseList.forEach((element) {
      //       if (element.dateTime != null &&
      //           (fromDate.isBefore(element.dateTime) ||
      //               fromDate.isAtSameMomentAs(element.dateTime)) &&
      //           !filterList.contains(element)) {
      //         filterList.add(element);
      //       }
      //     });
      //   }
      //   if (toDateString != null) {
      //     // if (filterList.length > 0 ||
      //     //     selectedBuyerList.length > 0 ||
      //     //     selectedVendorCodelist.length > 0 ||
      //     //     selectedVendorNameList.length > 0 ||
      //     //     selectedSeriesList.length > 0 ||
      //     //     selectedTransporterList.length > 0 ||
      //     //     fromDateString != null) {
      //     //   List tempList = [];
      //     //   filterList.forEach((element) {
      //     //     tempList.add(element);
      //     //   });
      //     //   tempList.forEach((element) {
      //     //     if (element.dateTime != null &&
      //     //         (toDate.isAfter(element.dateTime) ||
      //     //             toDate.isAtSameMomentAs(element.dateTime))) {
      //     //       if (!filterList.contains(element)) {
      //     //         filterList.add(element);
      //     //       }
      //     //     } else if (filterList.contains(element)) {
      //     //       filterList.remove(element);
      //     //     }
      //     //   });
      //     // } else
      //     widget.purchaseList.forEach((element) {
      //       if (element.dateTime != null &&
      //           (toDate.isAfter(element.dateTime) ||
      //               toDate.isAtSameMomentAs(element.dateTime)) &&
      //           !filterList.contains(element)) {
      //         filterList.add(element);
      //       }
      //     });
      //   }
      // }
    } else {
      filterList = [];
      widget.purchaseList.forEach((element) {
        filterList.add(element);
      });
    }
    print("Series==${filterList.length}");
    setState(() {});
  }
}
