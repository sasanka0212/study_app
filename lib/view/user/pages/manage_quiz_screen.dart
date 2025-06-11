import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/externals/all_courses.dart';
import 'package:study_app/view/user/pages/categories.dart';
import 'package:study_app/view/user/pages/quiz_play_screen.dart';
import 'package:study_app/utils/colors.dart';

class ManageQuizScreen extends StatefulWidget {
  final Category category;
  const ManageQuizScreen({
    super.key,
    required this.category,
  });

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  String _selectedCourseId = "";
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  bool _isSave = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('categoryId', isEqualTo: widget.category.id)
          .get();
      setState(() {
        _quizzes =
            snapShot.docs.map((e) => Quiz.fromMap(e.id, e.data())).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load quizzes")),
      );
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
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
                      leading: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isSave = !_isSave;
                              });
                            },
                            icon: Icon(_isSave
                                ? Iconsax.save_add
                                : Iconsax.save_add_copy),
                          ),
                        ),
                      ],
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
                            widget.category.description,
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
                                widget.category.name,
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
                          physics: const NeverScrollableScrollPhysics(),
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
    return Animate(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        child: InkWell(
          onTap: () async {
            final isEnter = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Start Quiz",
                  style: GoogleFonts.raleway(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "Do you want to start the quiz?",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                icon: Icon(
                  Icons.start_outlined,
                  color: primaryColor,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "Start",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
            if (isEnter == true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => QuizPlayScreen(quiz: quiz)));
            }
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
                        quiz.title,
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
                                "${quiz.questions.length} Questions",
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                              ),
                              Text(
                                "${quiz.timeLimit} mins",
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
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.5, end: 0, duration: const Duration(milliseconds: 300))
        .fadeIn();
  }
}
