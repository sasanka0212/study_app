class Question {
  final String text; //name of the question
  final List<String> options; //list of options
  final int correctIndex; //index of the correct answer

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
    );
  }

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      text: data['text'] ?? "",
      options: List<String>.from(data['options'] ?? []),
      correctIndex: data['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
    };
  }

  Question copyWith({String? text, List<String>? options, int? correctIndex}) {
    return Question(
      text: text ?? this.text, //?? -> otherwise
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}
