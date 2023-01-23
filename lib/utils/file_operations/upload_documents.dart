import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocr/camera/controller/file_controller.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadDocuments {
  static Future<String> findLocalPath() async {
    var externalStorageDirectory;
    var path;
    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getExternalStorageDirectory();
    }
    path = externalStorageDirectory.path;
    // }
    Directory _appDocDirFolder = Directory('$path/Uploads/');
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      return null;
    }
  }

  static Future<PermissionStatus> checkPermission() async {
    var statuses = await Permission.storage.request();
    return statuses;
  }

  static Future<String> fetchFiles(BuildContext viewContext, FileController fileController) async {
    int successCount = 0, failureCount = 0;
    try {
      NetworkConnect.currentUser.totalFiles = [];
      var isPermissionGranted = await checkPermission();
      if (isPermissionGranted == PermissionStatus.granted) {
        List<File> allFiles = await getAllFiles();
        bool isListFull = await setFileList(allFiles);
        if (isListFull == true) {
          var uploadsPath = await findLocalPath();
          if (uploadsPath != null) {
            Directory docDir = Directory(uploadsPath);
            List<FileSystemEntity> uploadsEntities =
                await docDir.list().toList();
            final Iterable<Directory> uploadsDirectories =
                uploadsEntities.whereType<Directory>();
            for (int i = 0; i < uploadsDirectories.length; i++) {
              if (await uploadsDirectories.elementAt(i).list().length > 0) {
                List<FileSystemEntity> typeEntries =
                    await uploadsDirectories.elementAt(i).list().toList();
                final Iterable<Directory> types =
                    typeEntries.whereType<Directory>();
                for (int j = 0; j < types.length; j++) {
                  // _fileController.getFilePassword(pdffile, widget.docNumber, widget.type);
                  if (await types.elementAt(j).list().length > 0) {
                    List<FileSystemEntity> finalEntries =
                        await types.elementAt(j).list().toList();
                    final Iterable<Directory> unusedDir =
                        finalEntries.whereType<Directory>();
                    for (int k = 0; k < unusedDir.length; k++) {
                      unusedDir.elementAt(k).delete(recursive: true);
                    }
                    final List<File> files =
                        finalEntries.whereType<File>().toList();
                    for (int k = 0; k < files.length; k++) {
                      bool isUploaded =
                          await fileController.uploadFile(files[k]);
                      if (isUploaded) {
                        successCount++;
                        files[k].delete(recursive: true);
                      } else {
                        failureCount++;
                      }
                      ScaffoldMessenger.of(viewContext).removeCurrentSnackBar();
                      final snackBar1 = SnackBar(
                          content: Text(
                        'Success : $successCount | Failure : $failureCount Documents',
                      ));

                      ScaffoldMessenger.of(viewContext).showSnackBar(snackBar1);
                    }
                  } else {
                    types.elementAt(j).delete(recursive: true);
                  }
                }
              } else {
                uploadsDirectories.elementAt(i).delete(recursive: true);
              }
            }
          }
        }
      } else {
        // _widgetsCollection.showToastMessage(
        //     "No permission to download", _buildContext);
      }
    } catch (e) {
      print("$e");
    }
    return '$successCount/${successCount + failureCount}';
  }

  static Future<bool> setFileList(List<File> allFiles) async {
    try {
      await allFiles.forEach((image) {
        List<String> pathElements = image.path.split('/');
        Map<String, dynamic> fileObj;
        if (pathElements[pathElements.length - 3] == 'sales') {
          fileObj = NetworkConnect.currentUser.salesID.firstWhere((element) =>
              element['docentry'] == pathElements[pathElements.length - 2]);
        } else if (pathElements[pathElements.length - 3] == 'purchase') {
          fileObj = NetworkConnect.currentUser.purchaseID.firstWhere(
              (element) =>
                  element['docentry'] == pathElements[pathElements.length - 2]);
        }
        NetworkConnect.currentUser.totalFiles.add({
          'docentry': fileObj['docentry'],
          'filename': fileObj['filename'],
          'status': 'Pending'
        });
      });
      return true;
    } catch (e) {
      print("Exception = $e");
      return false;
    }
  }

  static Future<List<File>> getAllFiles() async {
    List<File> allFiles = [];
    try {
      var isPermissionGranted = await checkPermission();
      if (isPermissionGranted == PermissionStatus.granted) {
        var uploadsPath = await findLocalPath();
        if (uploadsPath != null) {
          Directory docDir = Directory(uploadsPath);
          List<FileSystemEntity> uploadsEntities = await docDir.list().toList();
          final Iterable<Directory> uploadsDirectories =
              uploadsEntities.whereType<Directory>();
          for (int i = 0; i < uploadsDirectories.length; i++) {
            if (await uploadsDirectories.elementAt(i).list().length > 0) {
              List<FileSystemEntity> typeEntries =
                  await uploadsDirectories.elementAt(i).list().toList();
              final Iterable<Directory> types =
                  typeEntries.whereType<Directory>();
              for (int j = 0; j < types.length; j++) {
                if (await types.elementAt(j).list().length > 0) {
                  List<FileSystemEntity> finalEntries =
                      await types.elementAt(j).list().toList();
                  final Iterable<Directory> unusedDir =
                      finalEntries.whereType<Directory>();
                  for (int k = 0; k < unusedDir.length; k++) {
                    unusedDir.elementAt(k).delete(recursive: true);
                  }
                  final List<File> files =
                      finalEntries.whereType<File>().toList();
                  for (int k = 0; k < files.length; k++) {
                    allFiles.add(files[k]);
                  }
                } else {
                  types.elementAt(j).delete(recursive: true);
                }
              }
            } else {
              uploadsDirectories.elementAt(i).delete(recursive: true);
            }
          }
        }
      } else {
        // _widgetsCollection.showToastMessage(
        //     "No permission to download", _buildContext);
      }
    } catch (e) {
      print("$e");
    }
    return allFiles;
  }

  static Future<bool> deleteAllFiles() async {
    try {
      var isPermissionGranted = await checkPermission();
      if (isPermissionGranted == PermissionStatus.granted) {
        var uploadsPath = await findLocalPath();
        if (uploadsPath != null) {
          Directory docDir = Directory(uploadsPath);
          docDir.delete(recursive: true);
        }
      } else {
        // _widgetsCollection.showToastMessage(
        //     "No permission to download", _buildContext);
      }
    } catch (e) {
      print("$e");
    }
    return true;
  }
}
