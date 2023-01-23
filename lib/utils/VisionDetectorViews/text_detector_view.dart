import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr/camera/controller/file_controller.dart';
import 'package:ocr/utils/VisionDetectorViews/multi_images.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class TextDetectorView extends StatefulWidget {
  final String docNumber, type, fileName;
  File incomingFile;
  TextDetectorView(
      {this.docNumber, this.type, this.fileName, this.incomingFile});
  @override
  _TextDetectorViewState createState() => _TextDetectorViewState();
}

class _TextDetectorViewState extends State<TextDetectorView> {
  // TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;
  CustomPaint customPaint;
  String filename = '';
  FileController _fileController = FileController();

  listenStreams() {
    _fileController.fileListStream.listen((event) {
      EasyLoading.dismiss();
      if (event['status'] == "success") {
        EasyLoading.showToast("File Uploaded Successfully!");
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else if (event['status'] == "failed") {
        if (event['message'] != null) {
          EasyLoading.showToast("${event['message']}");
        } else
          EasyLoading.showToast("Something gone wrong!");
      } else {
        EasyLoading.showToast("Something gone wrong!");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listenStreams();
  }

  @override
  void dispose() async {
    super.dispose();
    // await textDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return AllImages(
      title: 'Images',
      incomingFile: widget.incomingFile,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(List<File> inputImage) async {
    if (isBusy) return;
    isBusy = true;
    // final recognisedText = await textDetector.processImage(inputImage);
    // print('Found ${recognisedText.blocks.length} textBlocks');
    // recognisedText.blocks.forEach((element) {
    //   print("Block==${element.text}");
    // });
    // print("inputImage=${inputImage.bytes}");
    // print("inputImage=${inputImage.filePath}");
    // print("inputImage=${inputImage.imageType}");
    // print("inputImage=${inputImage.inputImageData}");
    // if (inputImage.inputImageData?.size != null &&
    //     inputImage.inputImageData?.imageRotation != null) {
    //       print("----------------In Paint");
    // final painter = TextDetectorPainter(
    //     recognisedText,
    //     inputImage.inputImageData.size,
    //     inputImage.inputImageData.imageRotation);
    if (inputImage != null && inputImage.length > 0) {
      // EasyLoading.show(status: "Converting into PDF!");
      // final _image = File(inputImage.filePath);
      final _image = inputImage;
      // var finalPdf = pdfConverter(_image);
      await storeFile(inputImage);
      // var isPermissionGranted = await checkPermission();
      // if (isPermissionGranted == PermissionStatus.granted) {
      //   var path = await findLocalPath();

      //   final pdffile = File(path + "example.pdf");
      //   await pdffile.writeAsBytes(await finalPdf.save());
      //   EasyLoading.dismiss();
      //   EasyLoading.show();

      //   _fileController.getFilePassword(pdffile, widget.docNumber, widget.type);
      // } else {
      //   // _widgetsCollection.showToastMessage(
      //   //     "No permission to download", _buildContext);
      // }

      // var decodedImage = await decodeImageFromList(_image.readAsBytesSync());
      // final painter = TextDetectorPainter(
      //     recognisedText,
      //     Size(
      //         // 300, 400
      //         // MediaQuery.of(context).size.width,
      //         //   MediaQuery.of(context).size.height -80
      //         double.tryParse(decodedImage.width.toString()),
      //         double.tryParse(decodedImage.height.toString())),
      //     InputImageRotation.Rotation_0deg);

      // customPaint = CustomPaint(painter: painter);
      // print("customPaint.height = ${customPaint.size.height}");
      // print("customPaint.width = ${customPaint.size.width}");
    }

    // } else {
    //       print("----------------No Paint");
    //   customPaint = null;
    // }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
    // Navigator.of(context).pop();
  }

  Future<String> findLocalPath() async {
    var externalStorageDirectory;
    var path;
    // try {
    //   path = await ExtStorage.getExternalStoragePublicDirectory(
    //       ExtStorage.DIRECTORY_DOWNLOADS);
    // } catch (e) {
    //   print("e=$e");
    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getExternalStorageDirectory();
    }
    path = externalStorageDirectory.path;
    // }
    Directory _appDocDirFolderstart = Directory('${path}/Uploads/');
    if (await _appDocDirFolderstart.exists()) {
      //if folder already exists return path
    } else {
      //if folder not exists create folder and then return its path
      _appDocDirFolderstart =
          await _appDocDirFolderstart.create(recursive: true);
    }

    print("widget.type=${widget.type}");

    Directory _appDocDirFolder =
        Directory('${_appDocDirFolderstart.path}${widget.type}/');
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
    } else {
      //if folder not exists create folder and then return its path
      _appDocDirFolder = await _appDocDirFolder.create(recursive: true);
    }

    _appDocDirFolder =
        Directory('${_appDocDirFolder.path}${widget.docNumber}/');
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      // filename = "${await _appDocDirFolder.list().length + 1}";
      await _appDocDirFolder.delete(recursive: true);
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      // filename = "${await _appDocDirFolder.list().length + 1}";
      return _appDocDirNewFolder.path;
    }
  }

  Future<PermissionStatus> checkPermission() async {
    var statuses = await Permission.storage.request();
    return statuses;
  }

  void deleteUnusedFiles() async {
    try {
      var isPermissionGranted = await checkPermission();
      if (isPermissionGranted == PermissionStatus.granted) {
        var uploadsPath = await findDirectoryPath();
        if (uploadsPath != null) {
          Directory docDir = Directory(uploadsPath);
          List<FileSystemEntity> uploadsEntities = await docDir.list().toList();
          final Iterable<Directory> uploadsDirectories =
              uploadsEntities.whereType<Directory>();
          for (int i = 0; i < uploadsEntities.length; i++) {
            uploadsDirectories.forEach((element) {
              if (element.path != uploadsEntities[i].path) {
                uploadsEntities[i].delete(recursive: true);
              }
            });
          }
        }
      }
    } catch (e) {
      print("$e");
    }
  }

  Future<String> findDirectoryPath() async {
    var externalStorageDirectory;
    var path;
    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getExternalStorageDirectory();
    }
    path = externalStorageDirectory.path;

    return path;
  }

  void storeFile(List<File> image) async {
    var isPermissionGranted = await checkPermission();
    if (isPermissionGranted == PermissionStatus.granted) {
      var path = await findLocalPath();
      var finalPdf = pdfConverter(image);
      var rng = new Random();
      filename =
          // widget.fileName ??
          "${rng.nextInt(10000)}.pdf";
      print("path=$path filename = $filename");
      // if (await File(path + filename).exists()) {
      //   await File(path + filename).delete(recursive: true);
      //   // _deleteCacheDir();
      //   setState(() {});
      // }

      final pdffile = File(path + filename);
      // await image.copy(pdffile.path);
      await pdffile.writeAsBytes(await finalPdf.save());
      await deleteUnusedFiles();
      EasyLoading.dismiss();
      Navigator.pop(context, true);
      //   _fileController.getFilePassword(pdffile, widget.docNumber, widget.type);
    } else {
      // _widgetsCollection.showToastMessage(
      //     "No permission to download", _buildContext);
    }
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  void _clearCache() {
    setState(() {});
  }

  getExtension(String url) {
    final extension = p.extension(url, 1);
    return extension;
  }

  pw.Document pdfConverter(List<File> imageFile) {
    final pdf = pw.Document();

    imageFile.forEach((element) {
      final image = pw.MemoryImage(
        element.readAsBytesSync(),
      );

      pdf.addPage(
        pw.Page(
            margin: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            clip: true,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image)
                  // pw.Image(image),
                  ); // Center
            }),
      ); // Page
    });
    return pdf;
  }
}
