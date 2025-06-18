import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/question.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/utils/colors.dart';

class EditQuizScreen extends StatefulWidget {
  final Quiz quiz;
  const EditQuizScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class QuestionFormItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionsControllers;
  int correctOptionIndex;

  QuestionFormItem({
    required this.questionController,
    required this.optionsControllers,
    required this.correctOptionIndex,
  });

  void dispose() {
    questionController.dispose();
    for (var element in optionsControllers) {
      element.dispose();
    }
  }
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedCategoryId;
  late List<QuestionFormItem> _questionsItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItem) {
      item.dispose();
    }
    super.dispose();
  }

  void _initData() {
    _titleController = TextEditingController(text: widget.quiz.title);
    _timeLimitController =
        TextEditingController(text: widget.quiz.timeLimit.toString());
    _questionsItem = widget.quiz.questions.map((question) {
      return QuestionFormItem(
        questionController: TextEditingController(text: question.text),
        optionsControllers: question.options
            .map((option) => TextEditingController(text: option))
            .toList(),
        correctOptionIndex: question.correctIndex,
      );
    }).toList();
  }

  void _addQuestion() {
    setState(() {
      _questionsItem.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          optionsControllers: List.generate(
            4,
            (_) => TextEditingController(),
          ),
          correctOptionIndex: 0,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added 1 Question", style: GoogleFonts.raleway(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.blueAccent,
          showCloseIcon: true,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    if (_questionsItem.length > 1) {
      setState(() {
        _questionsItem[index].dispose();
        _questionsItem.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Quiz must have at least one question",
          ),
        ),
      );
    }
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final questions = _questionsItem
          .map(
            (item) => Question(
              text: item.questionController.text.trim(),
              options: item.optionsControllers
                  .map((option) => option.text.trim())
                  .toList(),
              correctIndex: item.correctOptionIndex,
            ),
          )
          .toList();

      final updateQuiz = widget.quiz.copyWith(
        questions: questions,
        title: _titleController.text,
        timeLimit: int.parse(_timeLimitController.text),
        createdAt: widget.quiz.createdAt,
      );

      //set questions to firebase firestore
      await _firestore.collection('quizzes').doc(widget.quiz.id).update(
            updateQuiz.toMap(isUpdated: true),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Quiz updated successfully",
            style: GoogleFonts.raleway(
              color: Colors.white,
            ),
          ),
          backgroundColor: secondaryColor,
        ),
      );
      //return back to main screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update quiz",
            style: GoogleFonts.raleway(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Edit Quiz",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateQuiz,
            icon: const Icon(
              Icons.save,
              color: primaryColor,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Quiz Details",
              style: TextStyle(
                color: textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "Enter quiz title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(
                  Icons.title,
                  color: primaryColor,
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                return (value == null || value.isEmpty)
                    ? "Please enter quiz title"
                    : null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _timeLimitController,
              decoration: InputDecoration(
                labelText: "Time Limit (in minutes)",
                hintText: "Enter time limit",
                prefixIcon: const Icon(
                  Icons.timer,
                  color: primaryColor,
                ),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Please enter time limit";
                }
                final num = int.tryParse(val);
                if (num == null || num <= 0) {
                  return "Please enter valid time limit";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Questions",
                      style: TextStyle(
                        fontSize: 20,
                        color: textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      label: const Text("Add QUestion"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                ..._questionsItem.asMap().entries.map((entry) {
                  final index = entry.key;
                  final QuestionFormItem question = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Question ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_questionsItem.length > 1)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        width: 1, color: Colors.redAccent),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _removeQuestion(index);
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: question.questionController,
                            decoration: InputDecoration(
                              labelText: "Question Title",
                              hintText: "Enter question",
                              prefixIcon: const Icon(
                                Icons.question_answer,
                                color: primaryColor,
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter question";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ...question.optionsControllers
                              .asMap()
                              .entries
                              .map((entry) {
                            final optionIndex = entry.key;
                            final cotroller = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    activeColor: primaryColor,
                                    value: optionIndex,
                                    groupValue: question.correctOptionIndex,
                                    onChanged: (val) {
                                      setState(() {
                                        question.correctOptionIndex = val!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: cotroller,
                                      decoration: InputDecoration(
                                        labelText: "Option ${optionIndex + 1}",
                                        hintText: "Enter option",
                                        fillColor: textBoxColor,
                                        filled: true,
                                        enabledBorder: InputBorder.none,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(
                  height: 32,
                ),
                Center(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateQuiz,
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(primaryColor),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save Quiz",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
