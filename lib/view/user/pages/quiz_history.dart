import 'package:flutter/material.dart';
import 'package:study_app/classes/quiz.dart';

class QuizHistory extends StatefulWidget {
  final Quiz quiz;
  const QuizHistory({super.key, required this.quiz});

  @override
  State<QuizHistory> createState() => _QuizHistoryState();
}

class _QuizHistoryState extends State<QuizHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemBuilder: (context, index) {},
        ),
      )
    );
  }
}
