import 'package:flutter/material.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/externals/all_courses.dart';
import 'package:study_app/pages/quiz_play_screen.dart';
import 'package:study_app/utils/colors.dart';

class ManageQuizScreen extends StatefulWidget {
  final Category category;
  final Set<Map<String, Object>> courses;
  const ManageQuizScreen({
    super.key,
    required this.category,
    required this.courses,
  });

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  String _selectedCourseId = "";
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchQuizzes();
  }

  void _fetchQuizzes() {
    if (widget.courses.isNotEmpty) {
      for (var map in widget.courses) {
        // Iterate over each map's entries
        _quizzes.add(Quiz(map['id'].toString(), map['name'].toString()));
        _isLoading = false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No courses available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(225, 97, 113, 234),
              ),
            )
          : _quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: Color.fromARGB(144, 174, 174, 193),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "No quizzes are available in this category",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(144, 174, 174, 193),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Go back",
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(225, 97, 113, 234),
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.category.desc.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        background: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                widget.category.name.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = _quizzes[index];
                            return _buildQuizCard(quiz, index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) => QuizPlayScreen(quiz: quiz),
              ),);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: primaryColor,
                  size: 32,
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.name.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.question_answer_outlined,
                              size: 16,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${questions[quiz.name.toString()]!.toList().length} Questions",
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                            ),
                            Text(
                              "${questions[quiz.name.toString()]!.toList().length} mins",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
