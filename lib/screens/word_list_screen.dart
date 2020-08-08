import 'package:flutter/material.dart';
import 'package:wordlistcardapp/db/database.dart';
import 'package:wordlistcardapp/main.dart';
import 'package:toast/toast.dart';
import 'edit_screen.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _wordList = List();

  @override
  void initState() {
    super.initState();
    _getAllWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("単語一覧"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            tooltip: "暗記済みの単語が下になるようにソート",
            onPressed: () => _sortWords(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewWord(),
        child: Icon(Icons.add),
        tooltip: "新しい単語の登録",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: _wordListWidget(),
      ),
    );
  }

  _addNewWord() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditScreen(
                  status: EditStatus.ADD,
                )));
  }

  void _getAllWords() async {
    _wordList = await database.allWords;
    setState(() {});
  }

  Widget _wordListWidget() {
    return ListView.builder(
        itemCount: _wordList.length,
        itemBuilder: (context, int position) => _wordItem(position));
  }

  Widget _wordItem(int position) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        title: Text(
          "${_wordList[position].strQuestion}",
        ),
        subtitle: Text(
          "${_wordList[position].strAnswer}",
          style: TextStyle(fontFamily: "Mont"),
        ),
        trailing:
        _wordList[position].isMemorized ? Icon(Icons.check_circle) : null,
        onTap: () => _editWord(_wordList[position]),
        onLongPress: () => _deleteWord(_wordList[position]),
      ),
    );
  }

  _deleteWord(Word selectedWord) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(selectedWord.strQuestion),
          content: Text("削除しますか？"),
          actions: <Widget>[
            FlatButton(
              child: Text("はい"),
              onPressed: () async {
                await database.deleteWord(selectedWord);
                Toast.show("削除が完了しました", context);
                _getAllWords();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("いいえ"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ));
  }

  _editWord(Word selectedWord) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditScreen(
                  status: EditStatus.EDIT,
                  word: selectedWord,
                )));
  }

  _sortWords() async {
    _wordList = await database.allWordsSorted;
    setState(() {

    });
  }
}
