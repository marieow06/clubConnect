import 'package:flutter/material.dart';
import 'classes/enums.dart';
import 'pages/studentLogin.dart';
import 'pages/home.dart';
import 'pages/clubs.dart';
import 'pages/admin.dart';
import 'pages/createAcc.dart';
import 'pages/forgotPassword.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Login(role: AppRole.student),
      '/forgot_password': (context) => forgotPass(),
      '/admin': (context) => Admin(role: AppRole.admin),
      '/createAcc': (context) => Register(role: AppRole.student),
      '/home': (context) => Home(),
      '/clubs': (context) => Clubs(),
    },
  ));
}
