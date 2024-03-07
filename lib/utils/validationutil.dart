import 'package:flutter/material.dart';

class ValidationUtil{

  static bool isEmailValid(String emailText){
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailText);
  }


}