import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocr/home/RootDashboard.dart';
import 'package:ocr/network/network_connect.dart';
import 'package:ocr/user/login/UserLogin.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/shared_preference.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin
// with UserMixins
{
  String access, refresh;
  bool isDataLoaded = false;

  var _visible = true;
  var delegate;

  AnimationController animationController;
  Animation<double> animation;
  bool textShow = false;

  @override
  void initState() {
    SharedPrefManager.getSharedPref().then((value) => getSharedPref());
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation.addListener(() => this.setState(() {}));
    animationController.forward();
    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  startTime() async {
    var _duration = Duration(seconds: 1);
    return Timer(_duration, redirectTo);
  }

  showText() {
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        textShow = true;
      });
    });
  }

  void getSharedPref() async {
    print("inside getSharedPref");
    SharedPrefManager.getCurrentUser().then((value) {
      if (value != null) {
        NetworkConnect.currentUser = value;
        access = value.token;
      }
    });
    setState(() {
      isDataLoaded = true;
    });
  }

  redirectTo() async {
    showText();
    await new Future.delayed(const Duration(milliseconds: 1), () async {
      do {
        print("1");
        await Future.delayed(Duration(seconds: 1));
      } while (isDataLoaded == false);
    });
    if (NetworkConnect.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserLogin(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFf4400),
      body: Center(
        child: Image.asset(
          "assets/images/name.png",
          width: animation.value * 150,
          height: animation.value * 70,
          // filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
