import 'pages/studentlogin.dart';
import 'package:flutter/material.dart';
import 'classes/enums.dart';
import 'pages/home.dart';
import 'pages/clubs.dart';
import 'pages/admin.dart';
import 'pages/Register.dart';
import 'pages/forgotPassword.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Login(role: AppRole.student),
      '/forgot_password': (context) => forgotPassword(),
      '/admin': (context) => Admin(role: AppRole.admin),
      '/createAcc': (context) => Register(role: AppRole.student),
      '/home': (context) => Home(),
      '/clubs': (context) => Clubs(),
    },
  ));
}
