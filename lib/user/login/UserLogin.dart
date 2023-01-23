import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ocr/home/RootDashboard.dart';
import 'package:ocr/user/controller/user_controller.dart';
import 'package:ocr/user/model/user_model.dart';
import 'package:ocr/utils/buttons.dart';
import 'package:ocr/utils/file_operations/upload_documents.dart';
import 'package:ocr/utils/form_validators.dart';
import 'package:ocr/utils/navigation.dart';
import 'package:ocr/utils/shared_preference.dart';
import 'package:ocr/utils/text_fields.dart';
import 'package:ocr/utils/text_styles.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  UserController _userController = UserController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController(
      // text:  'PF90'
      );
  TextEditingController _passwordController = TextEditingController(
      // text: '1234'
      );
  double screenHeight, screenWidth;

  loginPressed() {
    FocusScope.of(context).unfocus();
 
    if (_formKey.currentState.validate()) {
      EasyLoading.show();
      // _widgetsCollection.showMessageDialog();
      _userController.checkLogin(
          _usernameController.text.trim(), _passwordController.text.trim());
    }
  }

  Widget onLoggedIn(asyncData) {
    Future.delayed(
      Duration.zero,
      () async {
        print("asyncData=$asyncData");
        _userController.loginStreamSink.add(null);
        EasyLoading.dismiss();
        if (asyncData.length > 0) {
          // if (asyncData[0]['PW'] == _passwordController.text.trim()) {
          asyncData[0]['PW'] = _passwordController.text.trim();
          await UploadDocuments.deleteAllFiles();
          User _loggedInUser = User();
          _loggedInUser = User.fromJSON(asyncData[0]);
          SharedPrefManager.setCurrentUser(_loggedInUser);
          NavigationActions.navigateRemoveUntil(context, RootDashboard()
              // FilesView()
              );
          // } else
          //   EasyLoading.showToast("Invalid Password!");
        } else {
          EasyLoading.showToast("Invalid Credentials!");
        }
      },
    );
    return Container(
      height: 0,
      width: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Login"),
      // ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/name.png",
                      // height: screenHeight * 0.36,
                      // width: screenWidth - 20,
                      filterQuality: FilterQuality.medium,
                    ),
                    // Text("OCR", style: TextStyles.mainHeader),
                    // Text("Get Text Only", style: TextStyles.text18B4),
                  ],
                ),
                // SizedBox(height: 20),
                // Image.asset(
                //   "assets/images/logo.png",
                //   height: screenHeight * 0.36,
                //   // width: screenWidth - 20,
                //   filterQuality: FilterQuality.medium,
                // ),
                StreamBuilder(
                  stream: _userController.loginStream,
                  builder: (context, asyncData) {
                    return asyncData.data == null
                        ? Container()
                        : onLoggedIn(asyncData.data);
                  },
                ),
                SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User ID", style: TextStyles.text18B4),
                    SizedBox(height: 20),
                    TextFields.circularField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        // keyboardType:
                        //     TextInputType.numberWithOptions(decimal: true),
                        // inputFormator: [
                        //   // ignore: deprecated_member_use
                        //   BlacklistingTextInputFormatter(
                        //       new RegExp('[\\-|\\ ]'))
                        // ],
                        // maxLength: 10,
                        validator: (value) {
                          return FormValidators.manditoryValidator(value);
                        })
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Password", style: TextStyles.text18B4),
                    SizedBox(height: 20),
                    TextFields.circularField(
                        controller: _passwordController,
                        obsecureText: true,
                        validator: (value) {
                          return FormValidators.manditoryValidator(value);
                        })
                  ],
                ),
                SizedBox(height: 35),
                AppButtons.circularButton(
                    wigth: 190,
                    heigth: 50,
                    onTap: loginPressed,
                    title: "Login"),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
