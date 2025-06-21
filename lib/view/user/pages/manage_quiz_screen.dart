import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/view/user/pages/quiz_play_screen.dart';
import 'package:study_app/utils/colors.dart';

class ManageQuizScreen extends StatefulWidget {
  final Category category;
  const ManageQuizScreen({super.key, required this.category});

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  final String _selectedCourseId = "";
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  bool _isSave = false;
  late String _userid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userid = FirebaseAuth.instance.currentUser!.uid;
    _fetchQuizzes();
  }

  Future<bool> _isPurchased(String cid) async {
    final user = await _firestore.collection('user_data').doc(_userid).get();
    if (user.exists && user.data() != null) {
      List<String> cids = user.data()!['cid'] ?? [];
      for (String id in cids) {
        if (id == cid) {
          return true;
        }
      }
      return false;
    }
    return false;
  }

  Future<void> _fetchQuizzes() async {
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('categoryId', isEqualTo: widget.category.id)
          .get();
      //_isSave = await _isPurchased(widget.category.id);
      setState(() {
        _quizzes = snapShot.docs
            .map((e) => Quiz.fromMap(e.id, e.data()))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load quizzes")));
    }
  }

  Future<void> _updateItemToList(
    String userId,
    String itemId,
    bool isSave,
  ) async {
    try {
      final docRef = _firestore.collection('user_data').doc(userId);
      if (isSave) {
        await docRef.update({
          'cid': FieldValue.arrayUnion([itemId]),
        });
      } else {
        await docRef.update({
          'cid': FieldValue.arrayRemove([itemId]),
        });
      }
    } catch (e) {}
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 25),
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
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(225, 97, 113, 234),
              ),
            )
          : _quizzes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Color.fromARGB(144, 174, 174, 193),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No quizzes are available in this category",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(144, 174, 174, 193),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go back"),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSave = !_isSave;
                        });
                        _updateItemToList(_userid, widget.category.id, _isSave);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSave ? "Remove from cart" : "Add to cart",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              _isSave
                                  ? Iconsax.shopping_cart
                                  : Iconsax.shopping_cart_copy,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(225, 97, 113, 234),
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
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    background: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.category_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.category.name,
                            style: const TextStyle(
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
                    content: const Text(
                      "Do you want to start the quiz?",
                      style: TextStyle(fontSize: 16),
                    ),
                    icon: const Icon(Icons.start_outlined, color: primaryColor),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
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
                      builder: (builder) => QuizPlayScreen(quiz: quiz),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.question_answer_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("${quiz.questions.length} Questions"),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.timer_outlined, size: 16),
                                  Text("${quiz.timeLimit} mins"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
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
