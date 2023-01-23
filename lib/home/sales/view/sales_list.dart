import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ocr/home/RootDashboard.dart';
import 'package:ocr/home/sales/controller/controller.dart';
import 'package:ocr/home/sales/model/sales.dart';
import 'package:ocr/home/sales/view/sort.dart';
import 'package:ocr/main.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/VisionDetectorViews/image_view.dart';
import 'package:ocr/utils/VisionDetectorViews/text_detector_view.dart';
import 'package:ocr/utils/camera_view.dart';
import 'package:ocr/utils/file_operations/upload_documents.dart';
import 'package:ocr/home/sales/controller/filter_logic.dart';
import 'package:ocr/utils/navigation.dart';
import 'package:ocr/utils/shared_preference.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:camera/camera.dart';

import 'filters.dart';

class SalesList extends StatefulWidget {
  OnNavigate onNavigate;
  bool fromUnsync;
  SalesList({Key key, @required this.fromUnsync, this.onNavigate})
      : super(key: key);

  @override
  _SalesListState createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> {
  SalesController _salesController = SalesController();
  SalesFilterLogic _salesFilterLogic;
  List<Sales> storeSalesList = [];
  List<Sales> saleList = [];
  List<File> unsyncFiles = [];
  bool isLoading = true;
  Map<String, dynamic> filterMap = {};
  String sortedBy = 'Date', sortOrder = 'Assending';

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    if (widget.fromUnsync != true) globalSalesList = [];
    await Future.delayed(Duration(milliseconds: 1000));
    fetchFiles();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    EasyLoading.show();
    if (widget.fromUnsync == true)
      filterMap = salesUnsyncFilters;
    else
      filterMap = salesFilters;
    fetchFiles();
    listenStream();
  }

  fetchFiles() async {
    if (widget.fromUnsync == true) {
      unsyncFiles = await UploadDocuments.getAllFiles();
      isLoading = false;
      EasyLoading.dismiss();
      clearData();
      NetworkConnect.currentUser.salesID.forEach((element) {
        saleList.add(Sales.fromJSON(element['allinfo']));
        storeSalesList.add(Sales.fromJSON(element['allinfo']));
      });
      _refreshController.refreshCompleted();
      filterListItems();
      if (sortedBy != null) sortListItems();
      if (this.mounted) setState(() {});
    } else {
      if (globalSalesList != null && globalSalesList.length > 0) {
        clearData();
        globalSalesList.forEach((element) {
          if (!NetworkConnect.currentUser.salesID
              .any((sale) => sale['docentry'] == element.docEntry)) {
            saleList.add(element);
            storeSalesList.add(element);
          }
        });

        filterListItems();
        if (sortedBy != null) sortListItems();
        Future.delayed(Duration(milliseconds: 50), () {
          isLoading = false;
          EasyLoading.dismiss();
          if (this.mounted) setState(() {});
        });
      } else
        _salesController.getSalesList();
    }
  }

  listenStream() {
    _salesController.salesListStream.listen((event) async {
      isLoading = false;
      EasyLoading.dismiss();
      try {
        if (event.length > 0) {
          clearData();
          if (event != null) {
            globalSalesList = [];
            event.forEach((element) {
              globalSalesList.add(Sales.fromJSON(element));
              if (widget.fromUnsync == true) {
                if (NetworkConnect.currentUser.salesID
                    .any((sale) => sale['docentry'] == element['DocEntry'])) {
                  saleList.add(Sales.fromJSON(element));
                  storeSalesList.add(Sales.fromJSON(element));
                }
              } else {
                if (!NetworkConnect.currentUser.salesID
                    .any((sale) => sale['docentry'] == element['DocEntry'])) {
                  saleList.add(Sales.fromJSON(element));
                  storeSalesList.add(Sales.fromJSON(element));
                }
              }
            });
          }

          filterListItems();
          if (sortedBy != null) sortListItems();
          if (this.mounted) setState(() {});
        } else {
          EasyLoading.showToast("No Data Found!");
        }
      } catch (e) {
        EasyLoading.showToast("No Data Found!");
        if (this.mounted) setState(() {});
      }
      _refreshController.refreshCompleted();
    });
  }

  clearData() {
    storeSalesList = [];
    saleList = [];
  }

  var tempList = <Sales>[];

  @override
  Widget build(BuildContext context) {
    tempList.clear();
    tempList.addAll(saleList);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(
          completeDuration: Duration(milliseconds: 10),
          complete: Container(),
        ),
        controller: _refreshController,
        onRefresh: _onLoading,
        child: isLoading == true
            ? Container()
            : saleList.length == 0
                ? Center(child: Text("No Sales Available!"))
                : StatefulBuilder(
                    builder: (context, re) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: TextFormField(
                              onChanged: (query) async {
                                saleList = tempList.where((element) {
                                  return element.customerCode
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      element.customerName
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      element.docEntry
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      element.docNum
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      element.document
                                          .toLowerCase()
                                          .contains(query.toLowerCase());
                                }).toList();
                                re(() {});
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.appTheame,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: "Search here...",
                              ),
                            ),
                          ),
                          Expanded(
                            child: saleList.isEmpty
                                ? Center(
                                    child: Text("No Search Found"),
                                  )
                                : ListView.builder(
                                    itemCount: saleList.length,
                                    itemBuilder: (listContext, index) {
                                      return _buildCard(index, context);
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: Colors.white,
        selectedFontSize: 14,
        selectedLabelStyle: TextStyle(fontSize: 14, color: Colors.white),
        unselectedLabelStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        unselectedItemColor: Colors.white,
        unselectedIconTheme: IconThemeData(color: Colors.white),
        selectedIconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.appTheame,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.sort), label: "Sort"),
          BottomNavigationBarItem(
              icon: Icon(Icons.filter_list), label: "Filter"),
          BottomNavigationBarItem(
              icon: Icon(widget.fromUnsync == true
                  ? Icons.file_upload
                  : Icons.file_present),
              label: widget.fromUnsync == true ? "Pending" : "Scanned"),
        ],
        onTap: (index) async {
          if (index == 0) {
            showModalBottomSheet(
                context: context,
                builder: (botomContext) {
                  return SortFilters(
                    sortBy: sortedBy,
                    sortOrder: sortOrder,
                    onSorted: (sortList, sortBy, sortOrderValue) {
                      if (this.mounted)
                        setState(() {
                          sortedBy = sortBy;
                          sortOrder = sortOrderValue;
                          if (sortedBy != null) sortListItems();
                        });
                    },
                  );
                });
          } else if (index == 1) {
            Map<String, dynamic> temp = await NavigationActions.navigate(
                context,
                SalesFilters(
                  salesList: storeSalesList,
                  selectedCityList: filterMap['selectedCityList'],
                  selectedCustCodelist: filterMap['selectedCustCodelist'],
                  selectedCustNameList: filterMap['selectedCustNameList'],
                  selectedDriverList: filterMap['selectedDriverList'],
                  selectedNosList: filterMap['selectedNosList'],
                  selectedSalesEmpList: filterMap['selectedSalesEmpList'],
                  selectedSeriesList: filterMap['selectedSeriesList'],
                  selectedStateList: filterMap['selectedStateList'],
                  selectedTransporterList: filterMap['selectedTransporterList'],
                  fromDate: filterMap['fromDate'],
                  toDate: filterMap['toDate'],
                ));
            if (temp != null) {
              saleList = temp['filterList'];
              filterMap = temp;
              if (widget.fromUnsync == true)
                salesUnsyncFilters = filterMap;
              else
                salesFilters = filterMap;
              if (sortedBy != null) sortListItems();
            }
            setState(() {});
          } else {
            widget.onNavigate(true);
          }
        },
      ),
    );
  }

  _buildCard(int index, BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: EdgeInsets.only(left: 10),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 50,
                child: Center(
                  child: Text(
                    saleList[index].date ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      saleList[index].customerName,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            saleList[index].document ?? "-",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          "₹" + (saleList[index].amount ?? "-"),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      saleList[index].transporter,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      saleList[index].packages ?? "-",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.fromUnsync == false)
                    GestureDetector(
                        onTap: () async {
                          bool isDocSave = await NavigationActions.navigate(
                            context,
                            TakePictureScreen(
                              docNumber: saleList[index].docEntry,
                              type: "sales",
                              fileName: saleList[index].atcName,
                            ),
                          );

                          if (isDocSave == true) {
                            Map<String, dynamic> salesObj = {
                              'docentry': saleList[index].docEntry,
                              'atcentry': saleList[index].atcEntry,
                              'atctype': saleList[index].atcType,
                              'atcpath': saleList[index].atcPath,
                              'filename': saleList[index].atcName,
                              'allinfo': saleList[index].toJSON()
                            };
                            NetworkConnect.currentUser.salesID.add(salesObj);
                            EasyLoading.show();
                            SharedPrefManager.setCurrentUser(
                                NetworkConnect.currentUser);
                            fetchFiles();
                          }
                        },
                        child: Container(
                            height: double.infinity,
                            width: widget.fromUnsync == true ? 60 : 40,
                            decoration: BoxDecoration(
                                color: AppColors.orangeLight,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))),
                            child: Icon(Icons.camera))),
                  if (widget.fromUnsync == true)
                    GestureDetector(
                        onTap: () async {
                          File selectedFile;
                          unsyncFiles.forEach((element) {
                            List<String> pathElements = element.path.split('/');
                            if (saleList[index].docEntry ==
                                pathElements[pathElements.length - 2]) {
                              selectedFile = element;
                            }
                          });
                          bool isReload = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => ImageView(
                                        image: selectedFile,
                                        sale: saleList[index],
                                      )));

                          EasyLoading.show();
                          fetchFiles();
                        },
                        child: Container(
                          height: double.infinity,
                          width: widget.fromUnsync == true ? 60 : 40,
                          decoration: BoxDecoration(
                              color: AppColors.orangeLight,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          child: Icon(Icons.preview_outlined),
                        )),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  filterListItems() async {
    _salesFilterLogic = SalesFilterLogic(storeSalesList);
    if (filterMap != null && filterMap.isNotEmpty) {
      await _salesFilterLogic.setIncomingFilters(filterMap);
      saleList = _salesFilterLogic.filterList;
    }
  }

  sortListItems() {
    if (sortedBy == 'Date') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          if (first.dateTime != null && second.dateTime != null) {
            return first.dateTime.compareTo(second.dateTime);
          } else {
            return 0;
          }
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          if (first.dateTime != null && second.dateTime != null) {
            return first.dateTime.compareTo(second.dateTime);
          } else {
            return 0;
          }
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Document') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.document.compareTo(second.document);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.document.compareTo(second.document);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Document Number') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.docNum.compareTo(second.docNum);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.docNum.compareTo(second.docNum);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Customer Code') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.customerCode.compareTo(second.customerCode);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.customerCode.compareTo(second.customerCode);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Customer Name') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.customerName.compareTo(second.customerName);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.customerName.compareTo(second.customerName);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'City') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.city.compareTo(second.city);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.city.compareTo(second.city);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'State') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.state.compareTo(second.state);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.state.compareTo(second.state);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Sales Employee') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.salesEmployee.compareTo(second.salesEmployee);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.salesEmployee.compareTo(second.salesEmployee);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Transporter') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.transporter.compareTo(second.transporter);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.transporter.compareTo(second.transporter);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Driver') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.driver.compareTo(second.driver);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.driver.compareTo(second.driver);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    } else if (sortedBy == 'Packages') {
      if (sortOrder == 'Assending')
        saleList.sort((first, second) {
          return first.packages.compareTo(second.packages);
        });
      else {
        List<Sales> temp = saleList;
        saleList = [];
        temp.sort((first, second) {
          return first.packages.compareTo(second.packages);
        });
        temp.reversed.forEach((element) {
          saleList.add(element);
        });
      }
    }
    setState(() {});
  }

  swapItems(int first, int second) {
    var temp = saleList[first];
    saleList[first] = saleList[second];
    saleList[second] = temp;
  }
}
