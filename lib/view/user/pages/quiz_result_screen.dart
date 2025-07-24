import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/classes/user_score.dart';
import 'package:study_app/view/user/widgets/chart_column.dart';
import 'package:study_app/view/user/classes/user_quiz_data.dart';
import 'package:study_app/view/user/classes/user_result.dart';

class QuizResultScreen extends StatefulWidget {
  final Quiz quiz;
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, int?> selectedAnswers;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.selectedAnswers,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //List<UserScore> _historyScoreList = [];
  List<int> _historyScoreList = [];
  int _currentScore = 0;
  double _growth = 0;
  late IconData icon;
  bool _isLoading = false;
  int _bestScore = 0;
  List<UserQuizData> _listData = [];
  List<int> _scores = [];

  Widget _createStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: textSecondaryColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<List<int>> _getScores() async {
    List<int> scores = [];
    try {
      final snapShot = await _firestore
          .collection('quiz_result')
          .doc(widget.quiz.id)
          .collection('user_result')
          .get();
      _listData = snapShot.docs
          .map((doc) => UserQuizData.fromMap(doc.id, doc.data()))
          .toList();
      for (UserQuizData data in _listData) {
        scores.add(data.score);
      }
    } catch (e) {
      SnackBar(content: Text('Something went wrong'));
    }
    return scores;
  }

  Future<void> _saveQuizData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      /*
      await _firestore.collection('quiz_data').doc(widget.quiz.id).set({
        'users': FieldValue.arrayUnion([
          {
            'userId': _auth.currentUser!.uid,
            'score': ((widget.correctAnswers / widget.totalQuestions) * 100)
                .round(),
            'time': DateTime.now(),
          },
        ]),
      }, SetOptions(merge: true));
      */
      _currentScore = ((widget.correctAnswers / widget.totalQuestions) * 100)
          .round();
      final snapShot = await _firestore
          .collection('user_data')
          .doc(_auth.currentUser!.uid)
          .collection('quiz_data')
          .doc(widget.quiz.id)
          .get();
      if (snapShot.exists) {
        for (Map<String, dynamic> data in snapShot.data()!['history']) {
          _historyScoreList.add(data['score']);
        }
        print(_historyScoreList.length);
        int maxScore = _historyScoreList.reduce((a, b) => a > b ? a : b);
        _bestScore = maxScore > _currentScore ? maxScore : _currentScore;
        int diff = maxScore - _currentScore;
        _growth = diff < 0
            ? (((_currentScore - maxScore) / maxScore) * 100).toPrecision(2)
            : (((maxScore - _currentScore) / maxScore) * 100).toPrecision(2);
        icon = diff >= 0
            ? diff == 0
                  ? Icons.check
                  : Icons.arrow_downward
            : Icons.arrow_upward;
      } else {
        icon = Icons.thumb_up;
        _growth = 100;
        _bestScore = _currentScore;
      }
      await _firestore
          .collection('user_data')
          .doc(_auth.currentUser!.uid)
          .collection('quiz_data')
          .doc(widget.quiz.id)
          .set({
            'history': FieldValue.arrayUnion([
              {'score': _currentScore, 'time': DateTime.now()},
            ]),
            'latest': {'score': _currentScore, 'time': DateTime.now()},
          }, SetOptions(merge: true));
      await _firestore
          .collection('quiz_result')
          .doc(widget.quiz.id)
          .collection('user_result')
          .doc(_auth.currentUser!.uid)
          .set(
            UserQuizData(
              userId: _auth.currentUser!.uid,
              quizId: widget.quiz.id,
              score: _currentScore,
              totalQuestions: widget.quiz.questions.length,
              submittedAt: Timestamp.now(),
            ).toMap(),
          );
      //await _firestore.collection('quiz_data').doc(widget.quiz.id);
      /*
        UserQuizData userQuizData = UserQuizData.fromMap(
          snapShot.id,
          snapShot.data() as Map<String, dynamic>,
        );
        userQuizData.stats.add(
          UserResult(
            userId: FirebaseAuth.instance.currentUser!.uid,
            correct: widget.correctAnswers,
            time: DateTime.now(),
          ),
        );
        await _firestore
            .collection('quiz_data')
            .doc(widget.quiz.id)
            .update(userQuizData.toMap());
      } else {
        await _firestore
          .collection('quiz_data')
          .doc(widget.quiz.id)
          .set(
            UserQuizData(
              quizId: widget.quiz.id,
              stats: [
                UserResult(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                  correct: widget.correctAnswers,
                  time: DateTime.now(),
                ),
              ],
            ).toMap(),
          );
      }*/
      _scores = await _getScores();
      SnackBar(content: Text('Result added'));
    } catch (e) {
      SnackBar(content: Text('Something went wrong'));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAnsRow(String label, String answer, Color ansColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ansColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            answer,
            style: TextStyle(color: ansColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  IconData _getPerformanceIcon(double score) {
    if (score >= 0.9) return Icons.emoji_events;
    if (score >= 0.8) return Icons.star;
    if (score >= 0.6) return Icons.thumb_up;
    if (score >= 0.4) return Icons.trending_up;
    return Icons.refresh;
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.redAccent;
  }

  String _getPerformanceMsg(double score) {
    if (score >= 0.9) return "Oustanding!";
    if (score >= 0.8) return "Exelent";
    if (score >= 0.6) return "Very Good!";
    if (score >= 0.4) return "Good Effort!";
    return "Keep Practising!";
  }

  @override
  void initState() {
    super.initState();
    _saveQuizData();
  }

  @override
  Widget build(BuildContext context) {
    double score = widget.correctAnswers / widget.totalQuestions;
    int scorePercent = (score * 100).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Quiz Result',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Animate(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: CircularPercentIndicator(
                            radius: 100,
                            lineWidth: 15,
                            animation: true,
                            animationDuration: 1500,
                            percent: score,
                            center: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$scorePercent%',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${((widget.correctAnswers / widget.totalQuestions) * 100).toInt()}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            progressColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(
                    delay: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPerformanceIcon(score),
                          color: _getScoreColor(score),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPerformanceMsg(score),
                          style: TextStyle(
                            fontSize: 22,
                            color: _getScoreColor(score),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    curve: Curves.bounceOut,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _createStatCard(
                      "Correct",
                      widget.correctAnswers.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _createStatCard(
                      "Incorrect",
                      (widget.totalQuestions - widget.correctAnswers)
                          .toString(),
                      Colors.redAccent,
                      Icons.cancel,
                    ),
                  ),
                ],
              ),
            ).animate().scaleY(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
            ),
            _isLoading
                ? SizedBox(
                    height: 100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  )
                : ChartColumn(
                    currentScore: _currentScore,
                    bestScore: _bestScore,
                    growth: _growth,
                    icon: icon,
                    quiz: widget.quiz,
                    scores: _scores,
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_sharp, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        "Detailed Analysis",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.quiz.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final selectedAns = widget.selectedAnswers[index];
                    final isCorrect =
                        selectedAns != null &&
                        selectedAns == question.correctIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.redAccent,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            "Question ${index + 1}",
                            style: const TextStyle(
                              color: textPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            question.text,
                            style: const TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                                right: 5,
                                left: 20,
                              ),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: textPrimaryColor,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnsRow(
                                    "Your Answer:",
                                    selectedAns != null
                                        ? question.options[selectedAns]
                                        : "You haven't select any answer",
                                    isCorrect ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAnsRow(
                                    "Correct Answer:",
                                    question.options[question.correctIndex],
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideX(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 300),
                      delay: Duration(milliseconds: 100 * index),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          primaryColor,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        elevation: const WidgetStatePropertyAll(5),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        size: 24,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      label: const Text(
                        'Try Again!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
