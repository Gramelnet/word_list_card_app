import 'package:flutter/material.dart';
import 'package:wordlistcardapp/screens/home_screen.dart';

void main () => runApp(MyApp());

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
