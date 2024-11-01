import 'package:flutter/material.dart';
import 'package:sqflite1/screens/AddUser.dart';
import 'package:sqflite1/screens/view_user.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ViewUser(),
      debugShowCheckedModeBanner: false,
    );
  }
}