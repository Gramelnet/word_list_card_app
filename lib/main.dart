import 'package:flutter/material.dart';
import 'package:wordlistcardapp/db/database.dart';
import 'package:wordlistcardapp/screens/home_screen.dart';

MyDatabase database;

void main () {
  database = MyDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "シンプル単語帳",
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "Kosugi"
      ),
      home: HomeScreen(),
    );
  }
}
