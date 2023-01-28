import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:ocr/home/purchase/model/purchase.dart';
import 'package:ocr/home/sales/model/sales.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/camera_view.dart';
import 'package:ocr/utils/file_operations/upload_documents.dart';
import 'package:ocr/utils/navigation.dart';
import 'package:ocr/utils/shared_preference.dart';

class ImageView extends StatefulWidget {
  File image;
  Sales sale;
  Purchase purchase;
  ImageView({Key key, @required this.image, this.sale, this.purchase})
      : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  File image;
  Sales sale;
  Purchase purchase;
  StreamController<int> _streamController = StreamController<int>.broadcast();
  int pages = 0, currentIndex = 0;
  PDFViewController pdfViewController;

  @override
  void initState() {
    if (widget.image != null) image = widget.image;
    if (widget.purchase != null) purchase = widget.purchase;
    if (widget.sale != null) sale = widget.sale;

    super.initState();
  }

  update(int c, t) {
    pages = t;
    _streamController.sink.add(c);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.appTheame,
          title: Text("File"),
          actions: [
            IconButton(
                icon: Icon(Icons.camera),
                onPressed: () async {
                  if (sale != null) {
                    bool isDocSave = await NavigationActions.navigate(
                        context,
                        TakePictureScreen(
                          docNumber: sale.docEntry,
                          type: "sales",
                          fileName: sale.atcName,
                          incomingFile: image,
                        ));

                    if (isDocSave == true) {
                      EasyLoading.show();
                      setState(() {
                        image = null;
                      });
                      var unsyncFiles = await UploadDocuments.getAllFiles();
                      Future.delayed(Duration(seconds: 1), () {
                        setState(() {
                          unsyncFiles.forEach((element) {
                            List<String> pathElements = element.path.split('/');
                            if (sale.docEntry ==
                                pathElements[pathElements.length - 2]) {
                              image = element;
                            }
                          });
                        });
                        EasyLoading.dismiss();
                      });
                    }
                  } else {
                    bool isDocSave = await NavigationActions.navigate(
                        context,
                        TakePictureScreen(
                          docNumber: purchase.docEntry,
                          type: "purchase",
                          fileName: purchase.atcName,
                          incomingFile: image,
                        ));

                    if (isDocSave == true) {
                      EasyLoading.show();
                      setState(() {
                        image = null;
                      });
                      var unsyncFiles = await UploadDocuments.getAllFiles();
                      setState(() {
                        unsyncFiles.forEach((element) {
                          List<String> pathElements = element.path.split('/');
                          if (purchase.docEntry ==
                              pathElements[pathElements.length - 2]) {
                            image = element;
                          }
                        });
                      });
                      EasyLoading.dismiss();
                    }
                  }
                }),
            IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () async {
                  // var unsyncFiles = await UploadDocuments.getAllFiles();
                  // unsyncFiles.remove(image);

                  if (sale != null) {
                    NetworkConnect.currentUser.salesID.removeWhere(
                        (element) => element['docentry'] == sale.docEntry);
                  } else {
                    NetworkConnect.currentUser.purchaseID.removeWhere(
                        (element) => element['docentry'] == purchase.docEntry);
                  }
                  // SharedPrefManager.setCurrentUser(NetworkConnect.currentUser);
                  SharedPrefManager.updateCurrentUser(
                      NetworkConnect.currentUser);
                  if (await image.exists()) {
                    await image.delete();
                  }
                  Navigator.pop(context, true);
                })
          ],
        ),
        body: Column(
          children: [
            if (image != null) ...{
              SizedBox(height: 2),
              SizedBox(
                height: 30,
                child: StreamBuilder<int>(
                  key: UniqueKey(),
                  initialData: 0,
                  stream: _streamController.stream,
                  builder: (context, snapShot) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pages, (index) {
                          print(snapShot.data);
                          return GestureDetector(
                            onTap: () {
                              if (pages > 1) {
                                pdfViewController.setPage(index);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: snapShot.data == (index)
                                    ? AppColors.appTheame
                                    : Colors.transparent,
                              ),
                              width: 30,
                              height: 30,
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  color: snapShot.data == (index)
                                      ? Colors.white
                                      : AppColors.appTheame,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: PDFView(
                  key: UniqueKey(),
                  filePath: image.path,
                  fitEachPage: true,
                  pageSnap: true,
                  fitPolicy: FitPolicy.BOTH,
                  enableSwipe: true,
                  pageFling: false,
                  onViewCreated: (c) => pdfViewController = c,
                  onPageChanged: (c, t) {
                    update(c, t);
                  },
                ),
              ),
            },
          ],
        ),
        floatingActionButton: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (purchase != null) ...{
                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.all(0),
                        leading: Container(
                            width: 50,
                            child: Text(
                              purchase.date,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                        title: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            purchase.vendorName,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      (purchase.document ?? "-"),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.visible,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Text(
                                    "₹" + (purchase.amount ?? "-"),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              purchase.transporter ?? '-',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              purchase.packages ?? "-",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                )
              },
              if (sale != null) ...{
                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.all(0),
                      leading: Container(
                          width: 50,
                          child: Text(
                            sale.date ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                      title: Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          sale.customerName,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    sale.document ?? "-",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.visible,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  "₹" + (sale.amount ?? "-"),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            sale.transporter,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            sale.packages ?? "-",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              },
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
