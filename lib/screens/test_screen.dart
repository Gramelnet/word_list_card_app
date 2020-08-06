import 'package:flutter/material.dart';
import 'package:wordlistcardapp/db/database.dart';
import 'package:wordlistcardapp/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludedMemorizedWords;

  TestScreen({this.isIncludedMemorizedWords});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;
  String _textQuestion = "テスト";
  String _textAnswer = "こたえ";
  bool _isMemorized = false;

  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFavVisible = false;

  List<Word> _testDataList = List();
  TestStatus _testStatus;

  int _index = 0; // 今何問目か
  Word _currentWord;

  @override
  void initState() {
    super.initState();
    _getTestData();
  }

  void _getTestData() async {
    if (widget.isIncludedMemorizedWords) {
      _testDataList = await database.allWords;
    } else {
      _testDataList = await database.allWordsExcludeMemorized;
    }

    _testDataList.shuffle();
    _testStatus = TestStatus.BEFORE_START;
    _index = 0;
    print(_testDataList.toString());

    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFavVisible = true;

      _numberOfQuestion = _testDataList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _finishTestScreen(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("かくにんテスト"),
            centerTitle: true,
          ),
          floatingActionButton: _isFavVisible
              ? FloatingActionButton(
            onPressed: () => _goNextStatus(),
            child: Icon(Icons.skip_next),
            tooltip: "次に進む",
          )
              : null,
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  _numberOfQuestionPart(),
                  SizedBox(
                    height: 20.0,
                  ),
                  _questionCardPart(),
                  _answerCardPart(),
                  SizedBox(
                    height: 10.0,
                  ),
                  _isMemorizedCheckPart(),
                ],
              ),
              _endMessage(),
            ],
          )),
    );
  }

  // テスト終了メッセージ
  Widget _endMessage() {
    if (_testStatus == TestStatus.FINISHED) {
      return Center(
        child: Text(
          "テスト終了",
          style: TextStyle(fontSize: 50.0),
        ),
      );
    } else {
      return Container();
    }
  }


  Widget _numberOfQuestionPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "のこり問題数",
          style: TextStyle(fontSize: 14.0),
        ),
        SizedBox(
          width: 20.0,
        ),
        Text(
          _numberOfQuestion.toString(),
          style: TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

  // 問題カード表示
  Widget _questionCardPart() {
    if (_isQuestionCardVisible == true) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[

          Image.asset("assets/images/image_flash_question.png"),
          Text(
            _textQuestion,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
          ),
        ],
      );
    } else {
      return Container();
    }
  }


  Widget _answerCardPart() {
    if (_isAnswerCardVisible == true) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset("assets/images/image_flash_answer.png"),
          Text(
            _textAnswer,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }


  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible == true) {
      // チェックボックスが右側の場合
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: CheckboxListTile(
          title: Text(
            "暗記済みの単語はチェック",
            style: TextStyle(fontSize: 12.0),
          ),
          value: _isMemorized,
          onChanged: (value) {
            setState(() {
              _isMemorized = value;
            });
          },
        ),
      );

      //    // チェックボックスが左側の場合
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        Checkbox(value: _isMemorized, onChanged: (value){
//          setState(() {
//            _isMemorized = value;
//          });
//        }),
//        Text("暗記済みの単語はチェック", style: TextStyle(fontSize: 12.0),)
//      ],
//    );
    } else {
      return Container();
    }
  }

  _goNextStatus() async {
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        _testStatus = TestStatus.SHOW_QUESTION;
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        await _updateMemorizedFlag();
        if (_numberOfQuestion <= 0) {
          setState(() {
            _isFavVisible = false;
            _testStatus = TestStatus.FINISHED;
          });
        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
      case TestStatus.FINISHED:
        break;
    }
  }

  void _showQuestion() {
    _currentWord = _testDataList[_index];
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFavVisible = true;
      _textQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestion -= 1;
    _index += 1;
  }

  void _showAnswer() {
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = true;
      _isCheckBoxVisible = true;
      _isFavVisible = true;
      _textAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  Future<void> _updateMemorizedFlag() async {
    var updateWord = Word(
        strQuestion: _currentWord.strQuestion,
        strAnswer: _currentWord.strAnswer,
        isMemorized: _isMemorized);
    await database.updateWord(updateWord);
  }

  Future<bool> _finishTestScreen() async{
    return await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("テストの終了"),
      content: Text("テストを終了しますか？"),
      actions: <Widget>[
        FlatButton(
          child: Text("はい"),
          onPressed: (){
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("いいえ"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    )) ?? false;
  }
}
