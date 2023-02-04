// import 'package:flutter/material.dart';
// import 'package:ocr/utils/AppColors.dart';
// import 'package:ocr/utils/tab_items.dart';

// class BottomNavigation extends StatefulWidget {
//   BottomNavigation({this.currentTab, this.onSelectTab});

//   final TabItem currentTab;
//   final ValueChanged<TabItem> onSelectTab;

//   @override
//   _BottomNavigationState createState() => _BottomNavigationState();
// }

// class _BottomNavigationState extends State<BottomNavigation> {
//   double hightValue = 32;
//   double widthValue = 34;

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       elevation: 0,
//       selectedItemColor: Colors.white,
//       selectedFontSize: 14,
//       selectedLabelStyle: TextStyle(fontSize: 14, color: Colors.white),
//       unselectedLabelStyle: TextStyle(
//         color: Colors.white,
//         fontSize: 14,
//       ),
//       unselectedItemColor: Colors.white,
//       unselectedIconTheme: IconThemeData(color: Colors.white),
//       selectedIconTheme: IconThemeData(color: Colors.white),
//       backgroundColor: AppColors.appTheame,
//       showSelectedLabels: true,
//       showUnselectedLabels: true,
//       items: [
//         BottomNavigationBarItem(icon: Icon(Icons.file_upload), label: "FILES"),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.sync_problem), label: "UNSYNC FILES"),
//       ],
//       currentIndex: widget.currentTab.index,
//       onTap: (index) {
//         widget.onSelectTab(TabItem.values[index]);
//       },
//     );
//   }
// }
