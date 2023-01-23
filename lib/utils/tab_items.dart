import 'package:flutter/material.dart';

enum TabItem { 
  // dashBoard, 
  files, unsyncFiles}

Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
  // TabItem.dashBoard: GlobalKey<NavigatorState>(),
  TabItem.files: GlobalKey<NavigatorState>(),
  TabItem.unsyncFiles: GlobalKey<NavigatorState>(),
  
};

Map<TabItem, String> tabName = {
  // TabItem.dashBoard: 'Dashboard',
  TabItem.files: 'Files',
  TabItem.unsyncFiles: 'unsyncFiles',
  
};
