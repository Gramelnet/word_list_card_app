import 'package:flutter/material.dart';
import 'package:moor_ffi/database.dart';
import 'package:wordlistcardapp/db/database.dart';
import 'package:wordlistcardapp/main.dart';
import 'package:wordlistcardapp/screens/word_list_screen.dart';
import 'package:toast/toast.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;
  final Word word;

  EditScreen({@required this.status, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = "";
  bool _isQuestionEnabled;

  @override
  void initState() {
    super.initState();
    if (widget.status == EditStatus.ADD) {
      _isQuestionEnabled = true;
      _titleText = "新しい単語の登録";
      questionController.text = "";
      answerController.text = "";
    } else {
      _isQuestionEnabled = false;
      _titleText = "登録した単語の編集";
      questionController.text = widget.word.strQuestion;
      answerController.text = widget.word.strAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backToWordListScreen(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(_titleText),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.done),
                tooltip: "登録",
                onPressed: () => _onWordRegistered(),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                Center(child: Text("問題と答えを入力して「登録」ボタンを押してください")),
                SizedBox(
                  height: 30.0,
                ),

                // 問題入力部分
                _questionInputPart(),
                SizedBox(
                  height: 50.0,
                ),

                // 答え入力部分
                _answerInputPart(),
              ],
            ),
          )),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            "問題",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            "答え",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0, fontFamily: "Mont"),
          ),
        ],
      ),
    );
  }

  Future<bool> _backToWordListScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
    return Future.value(false);
  }

  _onWordRegistered() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      print("ダメです");
      Toast.show("問題と答えの両方を入力してください", context, duration: Toast.LENGTH_LONG);
      return;
    }

    showDialog(context: context, builder: (_) =>
        AlertDialog(
          title: Text("登録"),
          content: Text("登録しますか？"),
          actions: <Widget>[
            FlatButton(
              child: Text("はい"),
              onPressed: () async {
                var word = Word(
                    strQuestion: questionController.text,
                    strAnswer: answerController.text);

                try {
                  await database.addWord(word);
                  print("登録完了");
                  questionController.clear();
                  answerController.clear();
                  Navigator.pop(context);
                  _backToWordListScreen();
                  // 登録完了メッセージ
                  Toast.show("登録が完了しました", context, duration: Toast.LENGTH_LONG);

                } on SqliteException catch (e) {
                  print("登録エラー");
                  Toast.show(
                      "すでに登録済みの単語です", context, duration: Toast.LENGTH_LONG);
                }
              },
            ),
            FlatButton(
              child: Text("いいえ"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ));
  }

  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      print("ダメです");
      Toast.show("問題と答えの両方を入力してください", context, duration: Toast.LENGTH_LONG);
      return;
    }

    showDialog(context: context, builder: (_) =>
        AlertDialog(
          title: Text("${questionController.text}の変更"),
          content: Text("変更してもいいですか？"),
          actions: <Widget>[
            FlatButton(
              child: Text("はい"),
              onPressed: () async {
                var word = Word(
                    strQuestion: questionController.text,
                    strAnswer: answerController.text,
                    isMemorized: false);
                try {
                  await database.updateWord(word);
                  Navigator.pop(context);
                  _backToWordListScreen();
                  Toast.show("編集が完了しました", context, duration: Toast.LENGTH_LONG);
                } on SqliteException catch (e) {
                  Toast.show(
                      "問題が発生しました : $e", context, duration: Toast.LENGTH_LONG);
                  return;
                }
              },
            ),
            FlatButton(
              child: Text("いいえ"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ));
  }
}