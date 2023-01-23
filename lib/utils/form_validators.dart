class FormValidators {
  static RegExp nameReg = RegExp('^[a-zA-Z]*\$');
  static RegExp _nameRegExp = RegExp('^[a-zA-Z.\' ]*\$');
  static RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  static RegExp _regExp = RegExp('^[0-9]*\$');
  static RegExp _regExpPostal = RegExp('^[0-9a-zA-Z- ]*\$');
  static RegExp _regExpPassword = RegExp(
      '^((?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{8,}))');

  static String manditoryValidator(String value) {
    if (value.trim().length < 1) {
      return 'This Field Must Not Be Empty';
    }
    return null;
  }

  static String validDetails(String value, String errorDetails) {
    return value.trim().length < 1 ? errorDetails : null;
  }

  static String firstNameValidator(String name) {
    if (!RegExp('^[a-zA-Z \']*\$').hasMatch(name)) {
      return 'Invalid Name';
    } else if (!nameReg.hasMatch(name.substring(0, 1))) {
      return 'Invalid Name';
    }
    return null;
  }

  static String nameValidator(String name) {
    if (!_nameRegExp.hasMatch(name)) {
      return 'Invalid Name';
    } else if (!nameReg.hasMatch(name.substring(0, 1))) {
      return 'Invalid Name';
    }
    return null;
  }

  static String pfNumberValidator(String name) {
    if (!RegExp('^[0-9a-zA-Z-/ ]*\$').hasMatch(name) || name.length != 26) {
      return 'Invalid Number';
    }
    return null;
  }

  static String emailValidator(String email) {
    if (!regex.hasMatch(email))
      return 'Incorrect mail id';
    else
      return null;
  }

  static String mobileValidator(String mobNo) {
    if (!_regExp.hasMatch(mobNo)) {
      return 'Invalid Mobile Number';
    } else if (mobNo.trim().substring(0, 1) == '0') {
      return "Don't use zero at begining";
    } else if (mobNo.trim().length > 0 && mobNo.trim().length != 10) {
      return 'Minimum 10 digits required';
    }
    return null;
  }

  static String postalCodeValidator(String postalCode) {
    if (postalCode.length > 0 && postalCode.length != 6) {
      return "Must be 6 digits";
    } else if (postalCode == "000000") {
      return "Enter valid pincode";
    } else if (postalCode.length == 6) {
      if (!_regExpPostal.hasMatch(postalCode)) {
        return 'Invalid Postal Code';
      }
    }
    // if (!_regExpPostal.hasMatch(postalCode) || postalCode.trim().length > 12) {
    //   return 'Invalid Postal Code';
    // } else if (postalCode.trim().length < 1) {
    //   return '';
    // }
    return null;
  }

  static String passwordValidator(String password) {
    if (!_regExpPassword.hasMatch(password.trim())) {
      return 'Note: Minimum 8 characters required.↵[1 A-Z, 1 a-z, 1 0-9, 1 ~-)]';
    }
    return null;
  }

  static String inValidPassword(String password) {
    if (!_regExpPassword.hasMatch(password.trim())) {
      return 'Invalid Password';
    }
    return null;
  }

  static String numberValidator(String mobNo) {
    if (!_regExp.hasMatch(mobNo)) {
      return 'Invalid Number';
    }
    return null;
  }
}
