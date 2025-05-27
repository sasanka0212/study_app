import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/admin/manage_categories_screen.dart';
import 'package:study_app/view/admin/manage_quizzes_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount =
        await _firebaseFirestore.collection('categories').count().get();
    final quizzesCount =
        await _firebaseFirestore.collection('quizzes').count().get();
    //get latest quizzes
    final latestQuizzes = await _firebaseFirestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    final categories = await _firebaseFirestore.collection('categories').get();
    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quizCount = await _firebaseFirestore
            .collection('quizzes')
            .where('categoryId', isEqualTo: category.id)
            .count()
            .get();
        //return a map
        return {
          'name': category.data()['name'] as String,
          'count': quizCount.count,
        };
      }),
    );
    return {
      'totalCategories': categoriesCount.count,
      'totalQuizzes': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'categoryData': categoryData,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
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
            SizedBox(
              height: 16,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              title,
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 32,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _fetchStatistics(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          if (snapShot.hasError) {
            return Center(
              child: Text("An error occurred"),
            );
          }

          final Map<String, dynamic> stats = snapShot.data!;
          final List<dynamic> categoryData = stats['categoryData'];
          final List<QueryDocumentSnapshot> latestQuizzes =
              stats['latestQuizzes'];

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Here's your quiz application dashboard",
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total Categories",
                          stats['totalCategories'].toString(),
                          Icons.category_rounded,
                          primaryColor,
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _buildStatCard(
                          "Total Quizzes",
                          stats['totalQuizzes'].toString(),
                          Icons.quiz_rounded,
                          secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                color: primaryColor,
                                size: 24,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "Category Statistics",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ListView.builder(
                            itemCount: categoryData.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final category = categoryData[index];
                              final totalQuizzes = categoryData.fold<int>(
                                0,
                                (total, item) => (total + item['count'] as int),
                              );
                              final percentage = totalQuizzes > 0
                                  ? (category['count'] as int) /
                                      totalQuizzes *
                                      100
                                  : 0.0;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['name'] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "${category['count']} ${category['count'] as int == 1 ? "quiz" : "quizzes"}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${percentage.toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: primaryColor,
                                size: 24,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "Recent Activity",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ListView.builder(
                            itemCount: latestQuizzes.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final quiz = latestQuizzes[index].data() as Map<String, dynamic>;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: 16,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.quiz_rounded,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            quiz['title'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4,),
                                          Text(
                                            "Created on ${_formatDate(quiz['createdAt'].toDate())}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                color: primaryColor,
                                size: 24,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "Quiz Actions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            shrinkWrap: true,
                            children: [
                              _buildDashboardCard(
                                context, 
                                "Quizzes", 
                                Icons.quiz_rounded, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageQuizzesScreen(),)),
                              ),
                              _buildDashboardCard(
                                context, 
                                "Categories", 
                                Icons.category_rounded, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageCategoriesScreen(),)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
