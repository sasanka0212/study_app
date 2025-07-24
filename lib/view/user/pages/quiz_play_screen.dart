import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/classes/question.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/view/user/pages/quiz_result_screen.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/pages/video_player_screen.dart';
import 'package:study_app/view/user/pages/youtube_tutorial.dart';
import 'package:study_app/view/user/widgets/custom_page_route.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  final Map<int, int?> _selectedAnswers = {};

  int _totalMinutes = 0;
  int _remainingMinutes = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _showTutorial = false;
  final Stopwatch _activeTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _totalMinutes = widget.quiz.questions.length;
    _remainingMinutes = _totalMinutes;
    _remainingSeconds = 0;

    _startTimer();
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    // initialize sharedPreferences
    final pref = await SharedPreferences.getInstance();
    final isFirstTime = pref.getBool('swipeTut') ?? true;

    if (isFirstTime) {
      setState(() {
        _showTutorial = true;
      });
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        _showTutorial = false;
      });
      await pref.setBool('swipeTut', false);
    }
  }

  void restart() {
    _timer?.cancel();
    _activeTimer.reset();
    _startTimer();
  }

  void resume() {
    var timer = _timer;
    if (timer == null || timer.isActive) return;
    _startTimer();
  }

  void _startTimer() {
    _activeTimer.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
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

  void _pauseTimer() {
    _timer?.cancel();
    _activeTimer.stop();
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedAnswers[_currentQuestionIndex] == null) {
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = optionIndex;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    _activeTimer.stop();
    int correctAnswers = _calculateScore();
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Quiz Completed",
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
      ),
    );*/
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          quiz: widget.quiz,
          totalQuestions: widget.quiz.questions.length,
          correctAnswers: correctAnswers,
          selectedAnswers: _selectedAnswers,
        ),
      ),
    );
  }

  int _calculateScore() {
    int correctAns = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final selectedAns = _selectedAnswers[i];
      if (selectedAns != null &&
          selectedAns == widget.quiz.questions[i].correctIndex) {
        correctAns++;
      }
    }
    return correctAns;
  }

  Color _getTimerColor() {
    double timerProgress =
        1 -
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
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: textPrimaryColor,
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 2, color: primaryColor),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            _timer!.isActive ? Icons.pause : Icons.play_arrow,
                            color: primaryColor,
                          ),
                        ),
                        onTap: () => setState(() {
                          if (_timer!.isActive) {
                            _pauseTimer();
                          } else {
                            resume();
                          }
                        }),
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
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end:
                          (_currentQuestionIndex + 1) /
                          widget.quiz.questions.length,
                    ),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, progress, child) {
                      return LinearProgressIndicator(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10),
                          right: Radius.circular(10),
                        ),
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          primaryColor,
                        ),
                        minHeight: 6,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.quiz.questions.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final question = widget.quiz.questions[index];
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
    int totalQs = widget.quiz.questions.length;
    return Stack(
      children: [
        GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dy < 0) {
              _nextQuestion();
            }
          },
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx < 0) {
              Navigator.push(
                context,
                CustomPageRoute(
                  child: VideoPlayerScreen(
                    question: question, 
                    totalQuestions: widget.quiz.questions.length, 
                    index: index,
                  )
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${index + 1}/$totalQs",
                  style: const TextStyle(
                    color: textSecondaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      question.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 280,
                  child: SingleChildScrollView(
                    child: Column(
                      children: question.options.asMap().entries.map((entry) {
                        final optionIndex = entry.key;
                        final option = entry.value;
                        final isSelected =
                            _selectedAnswers[index] == optionIndex;
                        final isCorrect =
                            _selectedAnswers[index] == question.correctIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
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
                                  ? () {
                                      _selectAnswer(optionIndex);
                                    }
                                  : null,
                              title: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 14,
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
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                          )
                                        : const Icon(
                                            Icons.close,
                                            color: Colors.redAccent,
                                          )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Spacer(),
                /*
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        child: YoutubeTutorial(
                            question: question,
                            totalQuestions: totalQs,
                            index: index),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Quick Tutorial',
                          style: GoogleFonts.raleway(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.next_plan,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
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
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      index == widget.quiz.questions.length - 1
                          ? "Finish Quiz"
                          : "Next Question",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
        if (_showTutorial)
          Container(
            color: Colors.black.withOpacity(0.7),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swipe_up_outlined,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  "Swipe down or right to interact!",
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
