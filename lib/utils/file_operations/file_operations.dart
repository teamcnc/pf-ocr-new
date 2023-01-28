import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class FileOperations {
  String filename = '';

  Future<String> findLocalPath(var docNumber) async {
    var externalStorageDirectory;
    var path;
    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    }
    path = externalStorageDirectory.path;
    // }
    Directory _appDocDirFolder = Directory('$path/Uploads/');
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
    } else {
      //if folder not exists create folder and then return its path
      _appDocDirFolder = await _appDocDirFolder.create(recursive: true);
    }

    _appDocDirFolder = Directory('${_appDocDirFolder.path}$docNumber/');
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      filename = "${await _appDocDirFolder.list().length + 1}";
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      filename = "${await _appDocDirFolder.list().length + 1}";
      return _appDocDirNewFolder.path;
    }
  }

  Future<PermissionStatus> checkPermission() async {
    var statuses = await Permission.storage.request();
    return statuses;
  }

  void storeFile(File image, var docNumber) async {
    var isPermissionGranted = await checkPermission();
    if (isPermissionGranted == PermissionStatus.granted) {
      var path = await findLocalPath(docNumber);
      print("path=$path filename = $filename");
      await image.copy(File('$path$filename${getExtension(image.path)}').path);
    } else {
      // _widgetsCollection.showToastMessage(
      //     "No permission to download", _buildContext);
    }
  }

  Future<List<File>> fetchFiles(var docNumber) async {
    var isPermissionGranted = await checkPermission();
    if (isPermissionGranted == PermissionStatus.granted) {
      var path = await findLocalPath(docNumber);
      print("path=$path filename = $filename");
      Directory docDir = Directory(path);
      List<FileSystemEntity> entities = await docDir.list().toList();
      final Iterable<File> files = entities.whereType<File>();
      return files;
    } else {
      // _widgetsCollection.showToastMessage(
      //     "No permission to download", _buildContext);
    }
  }

  getExtension(String url) {
    final extension = p.extension(url, 1);
    return extension;
  }
}
