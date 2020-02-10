import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/vocabs.dart';
import '../views/question_frame.dart';
import '../views/answer_frame.dart';
import '../views/loading_frame.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.vocabs, this.tts})
      : super(key: key);

  final String title;
  final Vocabs vocabs;
  final FlutterTts tts;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuestionFrame qFrame;
  AnswerFrame aFrame;
  Vocabs vocabs;
  int counter;
  bool isShowAnswer;
  bool isLoading;
  TextEditingController userInputController;

  @override
  initState() {
    super.initState();

    counter = 1;
    isShowAnswer = false;
    isLoading = false;
    userInputController = TextEditingController();

    drawVocab().then((newVocab) {
      if (newVocab == null) {
        throw 'No vocab in DB';
      }

      setState(() {
        qFrame = QuestionFrame(
          questionNumber: counter.toString(),
          vocab: newVocab,
          showAnswer: showAnswer,
          userInputController: userInputController,
          flutterTts: widget.tts,
        );
        aFrame = AnswerFrame(
          vocab: newVocab,
          userInputController: userInputController,
        );
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    userInputController.dispose();
    super.dispose();
  }

  Future<Vocab> drawVocab() async {
    Vocab v;
    do {
      v = await widget.vocabs.drawWord();
    } while (!v.isWantedVocab());
    return v;
  }

  Future<void> displayNextWord() async {
    Vocab newVocab = await drawVocab();
    counter++;
    userInputController.clear();
    QuestionFrame qf = QuestionFrame(
      questionNumber: counter.toString(),
      vocab: newVocab,
      showAnswer: showAnswer,
      userInputController: userInputController,
      flutterTts: widget.tts,
    );

    AnswerFrame af = AnswerFrame(
      vocab: newVocab,
      userInputController: userInputController,
    );

    setState(() {
      isShowAnswer = false;
      qFrame = qf;
      aFrame = af;
    });
  }

  void showAnswer() {
    setState(() {
      isShowAnswer = !isShowAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingFrame();
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: isShowAnswer ? aFrame : qFrame,
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.visibility),
                        iconSize: 36.0,
                        color: Colors.black87,
                        tooltip: 'Show Answer',
                        onPressed: showAnswer,
                      ),
                    ),
                  ),
                  Container(
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.navigate_next),
                        iconSize: 36.0,
                        color: Colors.black87,
                        tooltip: 'Next Word',
                        onPressed: displayNextWord,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
