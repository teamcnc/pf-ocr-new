import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AppColors.dart';

class TextFields {
  static TextFormField circularField(
          {TextEditingController controller,
          bool obsecureText,
          String hintText,
          String titleText,
          void onTap(),
          void onChanged(value),
          String validator(value),
          int maxLength,
          TextStyle textStyle,
          List<TextInputFormatter> inputFormator,
          TextInputType keyboardType}) =>
      TextFormField(
        controller: controller,
        obscureText: obsecureText ?? false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          counter: Offstage(),
          fillColor: AppColors.grey,
          focusedBorder: OutlineInputBorder(
            // borderSide: BorderSide(
            //     // color: AppColors.appOrange,
            //     width: 2.0),
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(40.0),
          ),
          hintText: hintText,
          labelText: titleText,
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(fontSize: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.0),
              borderSide: BorderSide(color: Colors.transparent)),
          filled: true,
          contentPadding: EdgeInsets.all(12),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.0),
              borderSide: BorderSide(color: Colors.transparent)),
        ),
        style: textStyle,
        onChanged: onChanged,
        onTap: onTap,
        validator: validator,
        maxLength: maxLength,
        inputFormatters: inputFormator,
        keyboardType: keyboardType,
      );
}
