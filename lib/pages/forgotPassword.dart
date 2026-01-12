import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final Map<String, Map<String, String>> schoolInfo = {
    'PC west': {
      'id': 'PC_west',
      'domain': '@putmancityschools.org'
    },
    'Western heights': {
      'id': 'Western_heights',
      'domain': '@westernheights.k12.ok.us'
    },
    'Francis Tuttle': {
      'id': 'Francis_Tuttle',
      'domain': '@francistuttle.edu'
    },
  };

  String? selelctSchool;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController adminEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/pictures/Catbckgrnd.webp',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: <Widget>[
                          // Stroked text as border.
                          Text(
                            'Forgot Password',
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'YoungSerif',
                              letterSpacing: 3.0,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 10.0
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            'Forgot Password',
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'YoungSerif',
                              letterSpacing: 3.0,
                              color: Color(0xFFFFDC79),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: adminEmail,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          labelText: 'Admin Email',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select School',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        value: selelctSchool,
                        items: schoolInfo.keys.map((String school) {
                          return DropdownMenuItem<String>(
                            value: school,
                            child: Text(school),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selelctSchool = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a school';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
