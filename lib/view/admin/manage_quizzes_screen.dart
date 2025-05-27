import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/admin/add_quiz_screen.dart';
import 'package:study_app/view/admin/edit_quiz_scree.dart';

class ManageQuizzesScreen extends StatefulWidget {
  final String? categoryId;
  final Category? category;
  final String? categoryName;
  const ManageQuizzesScreen({
    super.key,
    this.categoryId,
    this.category,
    this.categoryName,
  });

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String? _selectedCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;
  String? _selectedCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCategory = widget.categoryName;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      final categories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();

      setState(() {
        _categories = categories;
        if (widget.categoryId != null) {
          _initialCategory = categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse: () => Category(
              id: widget.categoryId!,
              name: "Unknown",
              description: "",
              logo: "",
            ),
          );

          _selectedCategoryId = _initialCategory!.id;
        }
      });
    } catch (e) {
      print("Error fetching categories $e");
    }
  }

  Stream<QuerySnapshot> _getQuizStream() {
    Query query = _firestore.collection('quizzes');
    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where('categoryId', isEqualTo: filterCategoryId);
    }

    if (_searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: _searchQuery);
    }
    return query.snapshots();
  }

  Widget _buildTitle() {
    String? categoryId = _selectedCategoryId ?? widget.categoryId;
    if (categoryId == null) {
      return Text(
        "All Quizzes",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return StreamBuilder(
      stream: _firestore.collection('categories').doc(categoryId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "Loading!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        }
        final category = Category.fromMap(
            categoryId, snapshot.data!.data() as Map<String, dynamic>);
        return Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: _buildTitle(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddQuizScreen(
                            categoryId: widget.categoryId,
                            categoryName: widget.categoryName,
                          )));
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: primaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Search Quizzes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {
                _searchQuery = value.toLowerCase();
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              borderRadius: BorderRadius.circular(8),
              focusColor: Colors.white,
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: _selectedCategoryId,
              items: [
                DropdownMenuItem(
                  child: Text(
                    "All categories",
                  ),
                  value: null,
                ),
                if (_initialCategory != null &&
                    _categories.every((v) => v.id != _initialCategory!.id))
                  DropdownMenuItem(
                    child: Text(
                      _initialCategory!.name,
                    ),
                    value: _initialCategory!.id,
                  ),
                ..._categories.map((category) => DropdownMenuItem(
                      child: Text(category.name),
                      value: category.id,
                    )),
              ],
              onChanged: (value) => setState(() {
                _selectedCategoryId = value;
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getQuizStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error"),
                  );
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }
                final quizzes = snapshot.data!.docs
                    .map((doc) => Quiz.fromMap(
                        doc.id, doc.data() as Map<String, dynamic>))
                    .where((quiz) =>
                        _searchQuery.isEmpty ||
                        quiz.title.toLowerCase().contains(_searchQuery))
                    .toList();

                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: textSecondaryColor,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "No quizzes yet",
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(primaryColor),
                          ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddQuizScreen(
                                        categoryId: widget.categoryId,
                                        categoryName: widget.categoryName,
                                      ))),
                          child: Text(
                            "Add Quiz",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  shrinkWrap: true,
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final Quiz quiz = quizzes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.quiz_rounded,
                            color: primaryColor,
                          ),
                        ),
                        title: Text(
                          quiz.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
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
                                  color: textSecondaryColor,
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
                                Text("${quiz.timeLimit} mins"),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text("Edit"),
                                  leading: Icon(
                                    Icons.edit_outlined,
                                    color: primaryColor,
                                  ),
                                ),
                                value: "edit",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditQuizScreen(quiz: quiz),
                                    ),
                                  );
                                }),
                            PopupMenuItem(
                              child: ListTile(
                                title: Text("Delete"),
                                leading: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                              ),
                              value: "delete",
                            ),
                          ],
                          onSelected: (value) =>
                              _handleQuizAction(context, value, quiz),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizAction(
      BuildContext context, String value, Quiz quiz) async {
    if (value == 'edit') {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => EditQuizScreen()));
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Quiz"),
          content: Text("Are you aure you want to delete this quiz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _firestore.collection('quizzes').doc(quiz.id).delete();
      }
    }
  }
}
