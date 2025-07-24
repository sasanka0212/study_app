import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/view/user/classes/user_result.dart';

class UserQuizData {
  final String userId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final Timestamp submittedAt;

  UserQuizData({
    required this.userId,
    required this.quizId, 
    required this.score,
    required this.totalQuestions,
    required this.submittedAt
  });

  factory UserQuizData.fromMap(String id, Map<String, dynamic> data) {
    return UserQuizData(
      userId: id, 
      quizId: data['quizId'],
      score: data['score'],
      totalQuestions: data['totalQuestions'],
      submittedAt: data['submittedAt']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId, 
      'score': score,
      'totalQuestions': totalQuestions,
      'submittedAt': submittedAt
    };
  }
}
