import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ocr/camera/controller/file_controller.dart';
import 'package:ocr/home/files_view.dart';
import 'package:ocr/home/unsync_files_view.dart';
import 'package:ocr/main.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:ocr/user/login/UserLogin.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/file_operations/upload_documents.dart';
import 'package:ocr/utils/shared_preference.dart';
import 'package:ocr/utils/tab_items.dart';

typedef OnNavigate = Function(bool);
typedef OnNavigateRoot = Function(bool, String);

class RootDashboard extends StatefulWidget {
  bool fromUnsync;
  final remoteData;
  // final NotificationAppLaunchDetails notificationAppLaunchDetails;
  RootDashboard({this.remoteData, this.fromUnsync});

  @override
  _RootDashboardState createState() => _RootDashboardState();
}

class _RootDashboardState extends State<RootDashboard>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation colorAnimation;
  Animation rotateAnimation;

  var _isVisible;
  String selectedTab, referenceId;
  final GlobalKey<ScaffoldState> dKey = GlobalKey<ScaffoldState>();
  // TabItem _currentTab;
  var completeProfile;
  bool fromUnsync = false;
  FileController _fileController = FileController();
  BuildContext dialogContext;

  @override
  void initState() {
    _isVisible = true;
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 360.0, end: 0.0).animate(controller);
    // listenStreams();
  }

  listenStreams() {
    _fileController.fileListStream.listen((event) {
      // print("Event Listen=$event");
      if (event == true) {
        if (fromUnsync == true) {
          setState(() {
            fromUnsync = null;
          });
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              fromUnsync = true;
            });
          });
        }
      }
    });
  }

  _showSyncDoneDialog(var counts) async {
    return await showDialog(
        context: context,
        builder: (BuildContext popUpContext) {
          return AlertDialog(
            title: Text('$counts Documents Uploaded Successfully!'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appTheame,
                ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appTheame,
                ),
                // color: AppColors.appTheame,
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

  void showFilesPopUp() async {
    await showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: FileStatusList(),
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
      });
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar1 = SnackBar(
          content: Text(
        'Uploading documents',
      ));

      ScaffoldMessenger.of(context).showSnackBar(snackBar1);

      String counts =
          await UploadDocuments.fetchFiles(this.context, _fileController);
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
          EasyLoading.dismiss();
          if (dialogContext != null) Navigator.pop(dialogContext);
          bool isShowFiles = await _showSyncDoneDialog(counts);
          if (isShowFiles == true) {
            if (NetworkConnect.currentUser.totalFiles != null &&
                NetworkConnect.currentUser.totalFiles.length > 0)
              await showFilesPopUp();
            else
              setState(() {});
            dialogContext = null;
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
        await showFilesPopUp();
      else
        setState(() {});
      dialogContext = null;
      // ScaffoldMessenger.of(context).showSnackBar(snackBar2);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      key: dKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appTheame,
        title: Text(fromUnsync == false
            ? "Files"
            : fromUnsync == true
                ? "Unsync Files"
                : "Unsync Files"),
        centerTitle: false,
        actions: [
          //sync the files
          GestureDetector(
            onTap: syncFiles,
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: AppColors.appTheame,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                  )
                ],
              ),
              child: Row(
                children: [
                  AnimatedSync(
                    animation: rotateAnimation,
                    callback: syncFiles,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    controller.isAnimating ? "Syncing..." : "Sync",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          //logout btn
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )),
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: 60,
                            child: Divider(
                              thickness: 3.5,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Are you sure you want Sign out.",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Scanned data might be deleted",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(
                                    MediaQuery.of(context).size.width / 2.3,
                                    40,
                                  ),
                                  backgroundColor: AppColors.appTheame,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.appTheame,
                                  fixedSize: Size(
                                    MediaQuery.of(context).size.width / 2.3,
                                    40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              onPressed: () {
                                // salesFilters = {};
                                // purchaseFilters = {};
                                // salesUnsyncFilters = {};
                                // purchaseUnsyncFilters = {};
                                // globalSalesList = [];
                                // globalPurchaseList = [];
                                SharedPrefManager.logout(null);
                                // NetworkConnect.currentUser = null;
                                // await UploadDocuments.deleteAllFiles();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => UserLogin()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Text("Confirm"),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: NetworkConnect.currentUser.auth != 'N'
          ? fromUnsync == false
              ? FilesView(
                  selectedTab: selectedTab,
                  onNavigate: (value, tabNameValue) {
                    setState(() {
                      fromUnsync = !fromUnsync;
                      selectedTab = tabNameValue;
                    });
                  },
                )
              : fromUnsync == true
                  ? UnsyncFiles(
                      selectedTab: selectedTab,
                      onNavigate: (value, tabNameValue) {
                        setState(() {
                          fromUnsync = !fromUnsync;
                          selectedTab = tabNameValue;
                        });
                      },
                      fileController: _fileController,
                    )
                  : Container()
          : Container());
}

class FileStatusList extends StatefulWidget {
  const FileStatusList({
    Key key,
  }) : super(key: key);

  @override
  _FileStatusListState createState() => _FileStatusListState();
}

class _FileStatusListState extends State<FileStatusList> {
  startTimer() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      print("Callledddd FileStatusList=========>");
      if (this.mounted)
        setState(() {});
      else
        timer.cancel();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Container(
            height: 150,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: NetworkConnect.currentUser.totalFiles.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${NetworkConnect.currentUser.totalFiles[index]['filename']}",
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          Text(
                            "${NetworkConnect.currentUser.totalFiles[index]['status']}",
                          ),
                        ],
                      ),
                      if (NetworkConnect.currentUser.totalFiles[index]
                              ['status'] ==
                          'Failure')
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            "${NetworkConnect.currentUser.totalFiles[index]['reason'] ?? 'Reason not specified!'}",
                            overflow: TextOverflow.visible,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class AnimatedSync extends AnimatedWidget {
  VoidCallback callback;
  AnimatedSync({Key key, Animation<double> animation, this.callback})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Transform.rotate(
      angle: animation.value,
      child: GestureDetector(
          child: Icon(
            Icons.sync,
            // color: Colors.black,
          ), // <-- Icon
          onTap: () => callback()),
    );
  }
}
