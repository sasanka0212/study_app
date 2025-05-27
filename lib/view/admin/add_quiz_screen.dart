import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/classes/question.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/externals/all_courses.dart';
import 'package:study_app/utils/colors.dart';

class AddQuizScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  const AddQuizScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
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
    optionsControllers.forEach((element) => element.dispose());
  }
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<QuestionFormItem> _questionsItem = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _addQuestion();
  }

  void _addQuestion() {
    setState(() {
      _questionsItem.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          optionsControllers: List.generate(4, (_) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionsItem[index].dispose();
      _questionsItem.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a category"),
        ),
      );
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

      //set questions to firebase firestore
      await _firestore.collection('quizzes').doc().set(
            Quiz(
              id: _firestore.collection('quizzes').doc().id,
              title: _titleController.text.trim(),
              categoryId: _selectedCategoryId!,
              timeLimit: int.parse(_timeLimitController.text),
              questions: questions,
              createdAt: DateTime.now(),
            ).toMap(),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Quiz added successfully",
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
            "Failed to add quiz",
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
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItem) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          widget.categoryName != null ? "Add ${widget.categoryName} Quiz" : 'Add Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quiz Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                SizedBox(
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
                    prefixIcon: Icon(
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
                SizedBox(
                  height: 16,
                ),
                if (widget.categoryId == null)
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('categories')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error");
                      }
                      //if no data(category) is present
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        );
                      }
                      final categories = snapshot.data!.docs
                          .map((doc) => Category.fromMap(
                              doc.id, doc.data() as Map<String, dynamic>))
                          .toList();

                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: "Category",
                          hintText: "Select category",
                          prefixIcon: Icon(
                            Icons.category,
                            color: primaryColor,
                          ),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (val) {
                          val == null ? "Please select a category" : null;
                        },
                      );
                    },
                  ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _timeLimitController,
                  decoration: InputDecoration(
                    labelText: "Time Limit (in minutes)",
                    hintText: "Enter time limit",
                    prefixIcon: Icon(
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
                SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Questions",
                          style: TextStyle(
                            fontSize: 20,
                            color: textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          label: Text("Add QUestion"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ..._questionsItem.asMap().entries.map((entry) {
                      final index = entry.key;
                      final QuestionFormItem question = entry.value;
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Question ${index + 1}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_questionsItem.length > 1)
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.redAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            width: 1, color: Colors.redAccent),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _removeQuestion(index);
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                controller: question.questionController,
                                decoration: InputDecoration(
                                  labelText: "Question Title",
                                  hintText: "Enter question",
                                  prefixIcon: Icon(
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
                              SizedBox(
                                height: 16,
                              ),
                              ...question.optionsControllers
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final optionIndex = entry.key;
                                final cotroller = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
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
                                            labelText:
                                                "Option ${optionIndex + 1}",
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
                    SizedBox(
                      height: 32,
                    ),
                    Center(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveQuiz,
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Save Quiz",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
