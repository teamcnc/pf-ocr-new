import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:ocr/home/purchase/model/purchase.dart';
import 'package:ocr/home/sales/model/sales.dart';
import 'package:ocr/user/model/user_model.dart';
import 'package:provider/provider.dart';

import 'home/RootDashboard.dart';
import 'spash_screen/SplashScreen.dart';
import 'utils/AppColors.dart';

Map<String, dynamic> salesFilters = {};
Map<String, dynamic> purchaseFilters = {};
Map<String, dynamic> salesUnsyncFilters = {};
Map<String, dynamic> purchaseUnsyncFilters = {};
List<Sales> globalSalesList = [];
List<Purchase> globalPurchaseList = [];

void main() {
  loadMainFunction();
}

Future<void> loadMainFunction() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stetho.initialize();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => User()),
  ], child: OCR()));
}

class OCR extends StatefulWidget {
  @override
  _OCRState createState() => _OCRState();
}

class _OCRState extends State<OCR> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.appTheame,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
      builder: EasyLoading.init(),
      routes: {
        '/root_dashboard': (BuildContext context) => RootDashboard(),
      },
    );
  }
}
