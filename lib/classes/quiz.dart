import 'package:study_app/classes/question.dart';

class Quiz {
  final String id;
  final String title;
  final String categoryId;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.timeLimit,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> data) {
    return Quiz(
      id: id,
      title: data['title'] ?? "",
      categoryId: data['categoryId'] ?? "",
      timeLimit: data['timeLimit'] ?? "",
      questions: ((data['questions'] ?? []) as List)
          .map((e) => Question.fromMap(e))
          .toList(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdated = false}) {
    return {
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimit,
      'questions': questions
          .map(
            (e) => e.toMap(),
          )
          .toList(),
      'createdAt': createdAt,
      if(isUpdated) 'updatedAt': DateTime.now(),
    };
  }

  Quiz copyWith(
    {
      String? title,
      String? categoryId,
      int? timeLimit,
      List<Question>? questions,
      DateTime? createdAt,
    }) {
    return Quiz(
      id: id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt,
    );
  }
}
