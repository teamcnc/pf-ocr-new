import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ocr/home/RootDashboard.dart';
import 'package:ocr/home/files_view.dart';
import 'package:ocr/home/purchase/controller/controller.dart';
import 'package:ocr/home/purchase/controller/filter_logic.dart';
import 'package:ocr/home/purchase/model/purchase.dart';
import 'package:ocr/home/purchase/view/filters.dart';
import 'package:ocr/home/purchase/view/sort.dart';
import 'package:ocr/home/unsync_files_view.dart';
import 'package:ocr/main.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/VisionDetectorViews/image_view.dart';
import 'package:ocr/utils/VisionDetectorViews/text_detector_view.dart';
import 'package:ocr/utils/camera_view.dart';
import 'package:ocr/utils/file_operations/upload_documents.dart';
import 'package:ocr/utils/navigation.dart';
import 'package:ocr/utils/shared_preference.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PurchaseList extends StatefulWidget {
  OnNavigate onNavigate;
  bool fromUnsync;
  PurchaseList({Key key, @required this.fromUnsync, this.onNavigate})
      : super(key: key);

  @override
  _PurchaseListState createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  PurchaseController _purchaseController = PurchaseController();
  PurchaseFilterLogic _purchaseFilterLogic;
  List<Purchase> storePurchaseList = [];
  List<Purchase> purchaseList = [];
  List<File> unsyncFiles = [];
  bool isLoading = true;

  Map<String, dynamic> filterMap = {};
  String sortedBy = 'Date', sortOrder = 'Assending';

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    // monitor network fetch
    if (widget.fromUnsync != true) globalPurchaseList = [];
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    fetchFiles();
    // _purchaseController.getPurchaseList();
    // items.add((items.length+1).toString());
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    EasyLoading.show();
    if (widget.fromUnsync == true)
      filterMap = purchaseUnsyncFilters;
    else
      filterMap = purchaseFilters;
    fetchFiles();
    listenStream();
  }

  fetchFiles() async {
    if (widget.fromUnsync == true) {
      unsyncFiles = await UploadDocuments.getAllFiles();
      isLoading = false;
      EasyLoading.dismiss();
      clearData();
      NetworkConnect.currentUser.purchaseID.forEach((element) {
        purchaseList.add(Purchase.fromJSON(element['allinfo']));
        storePurchaseList.add(Purchase.fromJSON(element['allinfo']));
      });
      _refreshController.refreshCompleted();
      filterListItems();
      if (sortedBy != null) sortListItems();
      if (this.mounted) setState(() {});
    } else {
      if (globalPurchaseList != null && globalPurchaseList.length > 0) {
        globalPurchaseList.forEach((element) {
          if (!NetworkConnect.currentUser.purchaseID
              .any((purchase) => purchase['docentry'] == element.docEntry)) {
            purchaseList.add(element);
            storePurchaseList.add(element);
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
        _purchaseController.getPurchaseList();
    }
  }

  listenStream() {
    _purchaseController.purchaseListStream.listen((event) {
      try {
        isLoading = false;
        EasyLoading.dismiss();
        if (event.length > 0) {
          clearData();
          globalPurchaseList = [];
          event.forEach((element) {
            globalPurchaseList.add(Purchase.fromJSON(element));
            if (widget.fromUnsync == true) {
              if (NetworkConnect.currentUser.purchaseID.any(
                  (purchase) => purchase['docentry'] == element['DocEntry'])) {
                purchaseList.add(Purchase.fromJSON(element));
                storePurchaseList.add(Purchase.fromJSON(element));
              }
            } else {
              if (!NetworkConnect.currentUser.purchaseID.any(
                  (purchase) => purchase['docentry'] == element['DocEntry'])) {
                purchaseList.add(Purchase.fromJSON(element));
                storePurchaseList.add(Purchase.fromJSON(element));
              }
            }
          });
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
    purchaseList = [];
    storePurchaseList = [];
    // filterMap = {};
    // sortedBy = 'Date';
    // sortOrder = 'Assending';
  }

  var tempList = <Purchase>[];

  @override
  Widget build(BuildContext context) {
    tempList.clear();
    tempList.addAll(purchaseList);
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
        // onLoading: _onLoading,
        child: isLoading == true
            ? Container()
            : purchaseList.length == 0
                ? Center(child: Text("No Purchase Available!"))
                : StatefulBuilder(builder: (context, re) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          child: TextFormField(
                            onChanged: (query) async {
                              purchaseList = tempList.where(
                                (element) {
                                  return (element.vendorCode
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      element.vendorName
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
                                          .contains(query.toLowerCase()));
                                },
                              ).toList();
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
                          child: purchaseList.isEmpty
                              ? Center(
                                  child: Text("No Search Found"),
                                )
                              : ListView.builder(
                                  itemCount: purchaseList.length,
                                  itemBuilder: (listContext, index) {
                                    return Card(
                                      elevation: 5,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              // color: ,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))
                                              // border: Border(
                                              //     bottom: BorderSide(color: AppColors.black3))
                                              ),
                                          padding: EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: 50,
                                                    // decoration: BoxDecoration(
                                                    //     border: Border.all(color: Colors.black)),
                                                    child: Text(
                                                      purchaseList[index].date,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Text(
                                                        purchaseList[index]
                                                            .vendorName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                        maxLines: 2,
                                                        // minFontSize: 14,
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              (purchaseList[
                                                                          index]
                                                                      .document ??
                                                                  "-")
                                                              //     +
                                                              // "======================="
                                                              ,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                          // Spacer(),
                                                          Text(
                                                            "₹" +
                                                                (purchaseList[
                                                                            index]
                                                                        .amount ??
                                                                    "-"),
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                        // _text,
                                                        purchaseList[index]
                                                                .transporter ??
                                                            '-',
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                        purchaseList[index]
                                                                .packages ??
                                                            "-",
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (widget.fromUnsync ==
                                                        false)
                                                      GestureDetector(
                                                          onTap: () async {
                                                            bool isDocSave =
                                                                await NavigationActions
                                                                    .navigate(
                                                                        context,
                                                                        TakePictureScreen(
                                                                          docNumber:
                                                                              purchaseList[index].docEntry,
                                                                          type:
                                                                              "purchase",
                                                                          fileName:
                                                                              purchaseList[index].atcName,
                                                                        ));

                                                            if (isDocSave ==
                                                                true) {
                                                              Map<String,
                                                                      dynamic>
                                                                  purchaseObj =
                                                                  {
                                                                'docentry':
                                                                    purchaseList[
                                                                            index]
                                                                        .docEntry,
                                                                'atcentry':
                                                                    purchaseList[
                                                                            index]
                                                                        .atcEntry,
                                                                'atctype':
                                                                    purchaseList[
                                                                            index]
                                                                        .atcType,
                                                                'atcpath':
                                                                    purchaseList[
                                                                            index]
                                                                        .atcPath,
                                                                'filename':
                                                                    purchaseList[
                                                                            index]
                                                                        .atcName,
                                                                'allinfo':
                                                                    purchaseList[
                                                                            index]
                                                                        .toJSON()
                                                              };
                                                              NetworkConnect
                                                                  .currentUser
                                                                  .purchaseID
                                                                  .add(
                                                                      purchaseObj);
                                                              EasyLoading
                                                                  .show();
                                                              SharedPrefManager
                                                                  .updateCurrentUser(
                                                                      NetworkConnect
                                                                          .currentUser);
                                                              fetchFiles();
                                                              // _purchaseController
                                                              //     .getPurchaseList();
                                                            }
                                                          },
                                                          // onTap: _read,
                                                          child: Container(
                                                              height: double
                                                                  .infinity,
                                                              width:
                                                                  widget.fromUnsync ==
                                                                          true
                                                                      ? 60
                                                                      : 40,
                                                              decoration: BoxDecoration(
                                                                  color: AppColors
                                                                      .orangeLight,
                                                                  borderRadius: BorderRadius.only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              15))),
                                                              child: Icon(Icons
                                                                  .camera))),
                                                    if (widget.fromUnsync ==
                                                        true)
                                                      GestureDetector(
                                                          onTap: () async {
                                                            File selectedFile;
                                                            unsyncFiles.forEach(
                                                                (element) {
                                                              List<String>
                                                                  pathElements =
                                                                  element.path
                                                                      .split(
                                                                          '/');
                                                              if (purchaseList[
                                                                          index]
                                                                      .docEntry ==
                                                                  pathElements[
                                                                      pathElements
                                                                              .length -
                                                                          2]) {
                                                                selectedFile =
                                                                    element;
                                                              }
                                                            });
                                                            bool isReload = await Navigator
                                                                    .of(context)
                                                                .push(
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            ImageView(
                                                                              image: selectedFile,
                                                                              purchase: purchaseList[index],
                                                                            )));
                                                            // if (isReload == true)
                                                            EasyLoading.show();
                                                            fetchFiles();
                                                          },
                                                          // onTap: _read,
                                                          child: Container(
                                                            height:
                                                                double.infinity,
                                                            width:
                                                                widget.fromUnsync ==
                                                                        true
                                                                    ? 60
                                                                    : 40,
                                                            decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .orangeLight,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            15),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            15))),
                                                            child: Icon(Icons
                                                                .preview_outlined),
                                                          )),
                                                  ],
                                                )),
                                              ],
                                            ),
                                          )),
                                    );
                                  }),
                        ),
                      ],
                    );
                  }),
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
                    // purchaseList: purchaseList,
                    sortBy: sortedBy,
                    sortOrder: sortOrder,
                    onSorted: (sortList, sortBy, sortOrderValue) {
                      if (this.mounted)
                        setState(() {
                          // purchaseList = sortList;
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
                PurchaseFilters(
                  purchaseList: storePurchaseList,
                  selectedBuyerList: filterMap['selectedBuyerList'],
                  selectedVendorCodelist: filterMap['selectedVendorCodelist'],
                  selectedVendorNameList: filterMap['selectedVendorNameList'],
                  selectedSeriesList: filterMap['selectedSeriesList'],
                  selectedTransporterList: filterMap['selectedTransporterList'],
                  fromDate: filterMap['fromDate'],
                  toDate: filterMap['toDate'],
                ));
            if (temp != null) {
              purchaseList = temp['filterList'];
              filterMap = temp;
              if (widget.fromUnsync == true)
                purchaseUnsyncFilters = filterMap;
              else
                purchaseFilters = filterMap;

              if (sortedBy != null) sortListItems();
              print("SalesList = ${purchaseList.length}");
            }
            setState(() {});
          } else {
            widget.onNavigate(true);
            // NavigationActions.navigateRemoveUntil(context,
            //     widget.fromUnsync == true ? FilesView() : UnsyncFiles());
          }
        },
      ),
      //   floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      //   floatingActionButton: Container(
      //     height: 50,
      //     margin: EdgeInsets.only(bottom: 30, left: 20),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       // shrinkWrap: true,
      //       // primary: false,
      //       // scrollDirection: Axis.horizontal,
      //       children: [
      //         Expanded(
      //           // alignment: Alignment.centerRight,
      //           child: FloatingActionButton.extended(
      //             heroTag: 'sort',
      //             backgroundColor: AppColors.appTheame,
      //             label: Text("Sort"),
      //             icon: Icon(Icons.sort),
      //             onPressed: () {
      //               showModalBottomSheet(
      //                   context: context,
      //                   builder: (botomContext) {
      //                     return SortFilters(
      //                       purchaseList: purchaseList,
      //                       sortBy: sortedBy,
      //                       sortOrder: sortOrder,
      //                       onSorted: (sortList, sortBy, sortOrderValue) {
      //                         if (this.mounted)
      //                           setState(() {
      //                             purchaseList = sortList;
      //                             sortedBy = sortBy;
      //                             sortOrder = sortOrderValue;
      //                           });
      //                       },
      //                     );
      //                   });
      //             },
      //           ),
      //         ),
      //         SizedBox(
      //           width: 10,
      //         ),
      //         Expanded(
      //           // alignment: Alignment.centerRight,
      //           child: FloatingActionButton.extended(
      //             heroTag: 'filter',
      //             backgroundColor: AppColors.appTheame,
      //             label: Text("Filter"),
      //             icon: Icon(Icons.filter_list),
      //             onPressed: () async {
      //               Map<String, dynamic> temp = await NavigationActions.navigate(
      //                   context,
      //                   PurchaseFilters(
      //                     purchaseList: storePurchaseList,
      //                     selectedBuyerList: filterMap['selectedBuyerList'],
      //                     selectedVendorCodelist:
      //                         filterMap['selectedVendorCodelist'],
      //                     selectedVendorNameList:
      //                         filterMap['selectedVendorNameList'],
      //                     selectedSeriesList: filterMap['selectedSeriesList'],
      //                     selectedTransporterList:
      //                         filterMap['selectedTransporterList'],
      //                     fromDate: filterMap['fromDate'],
      //                     toDate: filterMap['toDate'],
      //                   ));
      //               if (temp != null) {
      //                 purchaseList = temp['filterList'];
      //                 filterMap = temp;
      //                 if (sortedBy != null) sortListItems();
      //                 print("SalesList = ${purchaseList.length}");
      //               }
      //               setState(() {});
      //             },
      //           ),
      //         ),
      //         SizedBox(
      //           width: 10,
      //         ),
      //         Expanded(
      //           // alignment: Alignment.centerRight,
      //           child: FloatingActionButton.extended(
      //             heroTag: 'scanned',
      //             backgroundColor: AppColors.appTheame,
      //             label: Text(widget.fromUnsync == true ? "Pending" : "Scanned"),
      //             icon: Icon(widget.fromUnsync == true
      //                 ? Icons.file_upload
      //                 : Icons.file_present),
      //             onPressed: () async {
      //               NavigationActions.navigateRemoveUntil(context,
      //                   widget.fromUnsync == true ? FilesView() : UnsyncFiles());
      //             },
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
    );
  }

  filterListItems() async {
    _purchaseFilterLogic = PurchaseFilterLogic(storePurchaseList);
    if (filterMap != null && filterMap.isNotEmpty) {
      await _purchaseFilterLogic.setIncomingFilters(filterMap);
      purchaseList = _purchaseFilterLogic.filterList;
    }
  }

  sortListItems() {
    if (sortedBy == 'Date') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          if (first.dateTime != null && second.dateTime != null) {
            return first.dateTime.compareTo(second.dateTime);
          } else {
            return 0;
          }
          // return first.dateTime.compareTo(second.dateTime);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          if (first.dateTime != null && second.dateTime != null) {
            return first.dateTime.compareTo(second.dateTime);
          } else {
            return 0;
          }
          // return first.dateTime.compareTo(second.dateTime);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
      // for (int i = 0; i < purchaseList.length; i++) {
      //   int i, j;
      //   for (i = 0; i < purchaseList.length - 1; i++)

      //     // Last i elements are already in place
      //     for (j = 0; j < purchaseList.length - i - 1; j++)
      //       if (sortOrder == 'Assending') {
      //         if (purchaseList[j]
      //             .dateTime
      //             .isAfter(purchaseList[j + 1].dateTime)) swapItems(j, j + 1);
      //       } else if (purchaseList[j]
      //           .dateTime
      //           .isBefore(purchaseList[j + 1].dateTime)) swapItems(j, j + 1);
      // }
    } else if (sortedBy == 'Document') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.document.compareTo(second.document);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.document.compareTo(second.document);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    } else if (sortedBy == 'Document Number') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.docNum.compareTo(second.docNum);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.docNum.compareTo(second.docNum);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    } else if (sortedBy == 'Vendor Ref. No.') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.vendorRefNo.compareTo(second.vendorRefNo);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.vendorRefNo.compareTo(second.vendorRefNo);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    } else if (sortedBy == 'Vendor Code') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.vendorCode.compareTo(second.vendorCode);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.vendorCode.compareTo(second.vendorCode);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    } else if (sortedBy == 'Vendor Name') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.vendorName.compareTo(second.vendorName);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.vendorName.compareTo(second.vendorName);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    } else if (sortedBy == 'Buyer') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.buyer.compareTo(second.buyer);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.buyer.compareTo(second.buyer);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    } else if (sortedBy == 'Transporter') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.transporter.compareTo(second.transporter);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.transporter.compareTo(second.transporter);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    } else if (sortedBy == 'Packages') {
      if (sortOrder == 'Assending')
        purchaseList.sort((first, second) {
          return first.packages.compareTo(second.packages);
        });
      else {
        List<Purchase> temp = purchaseList;
        purchaseList = [];
        temp.sort((first, second) {
          return first.packages.compareTo(second.packages);
        });
        temp.reversed.forEach((element) {
          purchaseList.add(element);
        });
      }
    }
    setState(() {
      // widget.onSorted(purchaseList, selected, sortOrder);
    });
  }

  swapItems(int first, int second) {
    var temp = purchaseList[first];
    purchaseList[first] = purchaseList[second];
    purchaseList[second] = temp;
  }
}
