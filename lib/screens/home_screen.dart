import 'package:flutter/material.dart';
import 'package:wordlistcardapp/parts/button_with_icon.dart';
import 'package:wordlistcardapp/screens/test_screen.dart';
import 'package:wordlistcardapp/screens/word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isIncludedMemorizedWords = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Image.asset("assets/images/image_title.png"),
            ),
            Text(
              "シンプル単語帳",
              style: TextStyle(fontSize: 40.0),
            ),
            Text(
              "Simple Frashcard",
              style: TextStyle(fontSize: 24.0, fontFamily: "Mont"),
            ),
            SizedBox(
              height: 50.0,
            ),
            ButtonWithIcon(
              onPressed: () => _startTestScreen(context),
              icon: Icon(Icons.play_arrow),
              label: "かくにんテストをする",
              color: Colors.brown,
            ),
            SizedBox(
              height: 10.0,
            ),
            _radioButtons(),
            SizedBox(
              height: 30.0,
            ),
            ButtonWithIcon(
              onPressed: () => _startWordListScreen(context),
              icon: Icon(Icons.list),
              label: "単語一覧を見る",
              color: Colors.grey,
            ),
            SizedBox(
              height: 60.0,
            ),
            Text(
              "powered by Gramelnet",
              style: TextStyle(fontFamily: "Mont"),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  _radioButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: Column(
        children: <Widget>[
          RadioListTile(
            value: false,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を除外する",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          RadioListTile(
            value: true,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を含む",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  _onRadioSelected(value) {
    setState(() {
      isIncludedMemorizedWords = value;
    });
  }

  _startTestScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => TestScreen(
                  isIncludedMemorizedWords: isIncludedMemorizedWords,
                )));
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }
}
