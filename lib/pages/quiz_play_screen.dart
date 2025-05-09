import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study_app/classes/question.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/externals/all_courses.dart';
import 'package:study_app/utils/colors.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizPlayScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  Map<int, int?> _selectedAnswers = {};

  int _totalMinutes = 0;
  int _remainingMinutes = 0;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _totalMinutes = questions[widget.quiz.name.toString()]! .length;
    _remainingMinutes = _totalMinutes;
    _remainingSeconds = 0;

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } 
        else {
          if (_remainingMinutes > 0) {
            _remainingMinutes--;
            _remainingSeconds = 59;
          } else {
            _timer?.cancel();
            _finishQuiz();
          }
        }
      });
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedAnswers[_currentQuestionIndex] == null) {
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = optionIndex;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex <
        questions[widget.quiz.name.toString()]!.length - 1) {
            _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    int correctAnswers = _calculateScore();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Quiz Completed"),
      ),
    );
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: QuizResultScreen(
          quiz: widget.quiz,
          totalQuestions: questions[widget.quiz.name.toString()]!.toList().length,
          correctAnswers: correctAnswers,
          selectedAnswers: _selectedAnswers,
        ),
      ),
    );*/
  }

  int _calculateScore() {
    int correctAns = 0;
    for (int i = 0; i < questions[widget.quiz.name.toString()]!.length; i++) {
      final selectedAns = _selectedAnswers[i];
      if (selectedAns != null &&
          selectedAns ==
              questions[widget.quiz.name.toString()]!
                  [i].correctIndex) {
        correctAns++;
      }
    }
    return correctAns;
  }

  Color _getTimerColor() {
    double timerProgress = 1 -
        ((_remainingMinutes * 60 + _remainingSeconds) / (_totalMinutes * 60));
    if (timerProgress < 0.4) return Colors.green;
    if (timerProgress < 0.6) return Colors.orange;
    if (timerProgress < 0.8) return Colors.deepOrangeAccent;
    return Colors.redAccent;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: textPrimaryColor,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 55,
                          width: 55,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.grey[300],
                            value:
                                (_remainingMinutes * 60 + _remainingSeconds) /
                                    (_totalMinutes * 60),
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getTimerColor(),
                            ),
                          ),
                        ),
                        Text(
                          '$_remainingMinutes:${_remainingSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getTimerColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: (_currentQuestionIndex + 1) /
                        questions[widget.quiz.name.toString()]!.length,
                  ),
                  duration: Duration(milliseconds: 300),
                  builder: (context, progress, child) {
                    return LinearProgressIndicator(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(10),
                        right: Radius.circular(10),
                      ),
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
                      minHeight: 6,
                    );
                  },
                ),
              ],),
            ),
            Expanded(
              child: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    questions[widget.quiz.name.toString()]!.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final question =
                      questions[widget.quiz.name.toString()]![index];
                  return _createQuestionCard(question, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createQuestionCard(Question question, int index) {
    return AnimatedContainer(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question ${index + 1}",
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            question.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswers[index] == optionIndex;
            final isCorrect = _selectedAnswers[index] == question.correctIndex;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected
                      ? isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : Colors.redAccent.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? isCorrect
                            ? Colors.green
                            : Colors.redAccent
                        : Colors.grey.shade300,
                  ),
                ),
                child: ListTile(
                  onTap: _selectedAnswers[index] == null
                      ? () => _selectAnswer(optionIndex)
                      : null,
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? isCorrect
                              ? Colors.green
                              : Colors.redAccent
                          : _selectedAnswers[index] != null
                              ? Colors.grey.shade500
                              : textPrimaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? isCorrect
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.close,
                              color: Colors.redAccent,
                            )
                      : null,
                ),
              ),
            );
          }),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                _selectedAnswers[index] != null ? _nextQuestion() : null;
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(primaryColor),
                elevation: WidgetStatePropertyAll(6),
              ),
              child: Text(
                index == questions[widget.quiz.name.toString()]!.toList().length - 1 
                ? "Finish Quiz"
                :"Next Question",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
