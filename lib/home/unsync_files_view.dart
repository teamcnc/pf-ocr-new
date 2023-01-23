import 'package:flutter/material.dart';
import 'package:ocr/camera/controller/file_controller.dart';
import 'package:ocr/home/RootDashboard.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:ocr/user/login/UserLogin.dart';
import 'package:ocr/user/model/user_model.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/buttons.dart';
import 'package:ocr/utils/file_operations/upload_documents.dart';
import 'package:ocr/utils/shared_preference.dart';
import 'package:provider/provider.dart';

import 'purchase/view/purchase_list.dart';
import 'sales/view/sales_list.dart';

class UnsyncFiles extends StatefulWidget {
  OnNavigateRoot onNavigate;
  FileController fileController;
  String selectedTab;
  UnsyncFiles({this.onNavigate, this.fileController, this.selectedTab});
  @override
  _UnsyncFilesState createState() => _UnsyncFilesState();
}

class _UnsyncFilesState extends State<UnsyncFiles>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation colorAnimation;
  Animation rotateAnimation;
  User _user;

  String tabName = "sales";
  bool isRReload = false;

  _showSyncDoneDialog(var counts) async {
    return await showDialog(
        context: context,
        builder: (BuildContext popupContext) {
          return AlertDialog(
            title: Text('$counts Documents Uploaded Successfully!'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appTheame,
                ),
                // color: AppColors.appTheame,
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  "See Files",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                // color: AppColors.appTheame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appTheame,
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          );
        });
  }

  void showFilesPopUp(List fileDetails) async {
    await showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          // title: Container(
          //   width: MediaQuery.of(context).size.width,
          //   alignment: Alignment.center,
          //   child: Text(
          //     "All Files",
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 17,
          //     ),
          //   ),
          // ),
          content: SingleChildScrollView(
            child: Container(
              height: fileDetails.length == 1
                  ? 77
                  : (fileDetails.length < 5
                      ? fileDetails.length * 60.0
                      : 300.0),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    alignment: Alignment.center,
                    child: Text(
                      "All Files",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: fileDetails.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${fileDetails[index]['filename']}",
                            ),
                            Text(
                              "${fileDetails[index]['status']}",
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appTheame,
              ),
              // color: AppColors.appTheame,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  syncFiles() async {
    if (!controller.isAnimating) {
      setState(() {
        controller.forward();
        _user.isUploadingFiles = true;
      });
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar1 = SnackBar(
          content: Text(
        'Uploading documents',
      ));

      ScaffoldMessenger.of(context).showSnackBar(snackBar1);

      String counts =
          await UploadDocuments.fetchFiles(this.context, FileController());
      _user.isUploadingFiles = false;
      if (this.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        setState(() {
          controller.stop();
          controller.reset();
        });
        if (counts == '0/0') {
          final snackBar3 = SnackBar(
            content: Text(
              "No Documents to Sync!",
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar3);
        } else {
          bool isShowFiles = await _showSyncDoneDialog(counts);
          if (isShowFiles == true) {
            if (NetworkConnect.currentUser.totalFiles != null &&
                NetworkConnect.currentUser.totalFiles.length > 0)
              showFilesPopUp(NetworkConnect.currentUser.totalFiles);
            else
              setState(() {});
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar2 = SnackBar(
          content: Text(
        'Uploading documents is in progress',
      ));

      if (NetworkConnect.currentUser.totalFiles != null &&
          NetworkConnect.currentUser.totalFiles.length > 0)
        showFilesPopUp(NetworkConnect.currentUser.totalFiles);
      else
        setState(() {});
      // ScaffoldMessenger.of(context).showSnackBar(snackBar2);
    }
  }

  listenStreams() {
    widget.fileController.fileListStream.listen((event) {
      print("Event Listen=$event");
      if (event['status'] == true) {
        if (event['from'] == tabName) {
          if (this.mounted)
            setState(() {
              isRReload = true;
            });
          else
            isRReload = true;
          Future.delayed(Duration(milliseconds: 500), () {
            if (this.mounted)
              setState(() {
                isRReload = false;
              });
            else
              isRReload = true;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 360.0, end: 0.0).animate(controller);
    _user = context.read<User>();
    if (widget.fileController != null) {
      listenStreams();
    }
    if (widget.selectedTab != null) tabName = widget.selectedTab;
    if (NetworkConnect.currentUser.auth == 'P') {
      tabName = "purchase";
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: AppColors.background,
      child: Column(
        children: [
          SizedBox(height: 10),
          //two tabs sales and purchase
          Row(
            children: [
              SizedBox(width: 20),
              if (NetworkConnect.currentUser.auth == 'S' ||
                  NetworkConnect.currentUser.auth == 'B')
                Expanded(
                  child: AppButtons.tabBarButton(
                      onTap: () {
                        setState(() {
                          tabName = "sales";
                        });
                      },
                      // heigth: 56,
                      isSelected: tabName == "sales",
                      title: "Sales"),
                ),
              if (NetworkConnect.currentUser.auth == 'B') SizedBox(width: 10),
              if (NetworkConnect.currentUser.auth == 'P' ||
                  NetworkConnect.currentUser.auth == 'B')
                Expanded(
                  child: AppButtons.tabBarButton(
                      onTap: () {
                        setState(() {
                          tabName = "purchase";
                        });
                      },
                      // heigth: 56,
                      isSelected: tabName == "purchase",
                      title: "Purchase"),
                ),
              SizedBox(width: 20),
            ],
          ),
          SizedBox(height: 15),

          Expanded(
              child: isRReload == false
                  ? tabName == "sales"
                      ? SalesList(
                          fromUnsync: true,
                          onNavigate: (value) {
                            widget.onNavigate(value, "sales");
                          },
                        )
                      : tabName == "purchase"
                          ? PurchaseList(
                              fromUnsync: true,
                              onNavigate: (value) {
                                widget.onNavigate(value, "purchase");
                              },
                            )
                          : Container()
                  : Container())
        ],
      ),
    ));
  }
}
