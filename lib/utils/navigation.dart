import 'package:flutter/material.dart';

class NavigationActions{
  static Future navigate(BuildContext context, Widget child) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => child),
      );

  static void navigateReplacement(BuildContext context, Widget child) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => child),
      );

  static void navigateRemoveUntil(BuildContext context, Widget child) =>
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => child),
          (Route<dynamic> route) => false);

}