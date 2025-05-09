import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/externals/all_courses.dart';
import 'package:study_app/pages/manage_quiz_screen.dart';
import 'package:study_app/pages/search_page.dart';
import 'package:study_app/utils/colors.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = [
      Category('Design', 'assets/images/design.svg', '10 Courses', 'Design your thoughts independently'),
      Category('Marketing', 'assets/images/marketing.svg', '10 Courses', 'Show your marketing skills'),
      Category('Engineering', 'assets/images/engineering.svg', '10 Courses', 'Convert your idea into implementation'),
      Category('IT', 'assets/images/it.svg', '25 Courses', 'Skills better then knowledge'),
      Category('Teaching', 'assets/images/teaching.svg', '20 Courses', 'Teach better learn best'),
      Category('Medical', 'assets/images/medical.svg', '20 Courses', 'Know from scratch for your future'),
    ];
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 5.0,
        title: Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Color(0xFFF35E7A),
          ),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 25),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => SearchPage())),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 15.0, // Space between columns
            mainAxisSpacing: 15.0, // Space between rows
          ),
          children: [
            //const SizedBox(height: 20),
            // Display each category with spacing
            ...categories
                .map((category) => GestureDetector(
                      onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => 
                  /*McqQuestion(
                  questionNo: '1', 
                  question: 'OOPs stands for?', 
                  optionNo: ['A', 'B', 'C', 'D'], 
                  options: [
                    'Object Orientation Programming',
                    'Object Overview programming',
                    'Obejct Oriented Programming',
                    'None of the above',
                  ],
                  courseName: category.name.toString(),
                  ansOption: 'C',
                )*/
                ManageQuizScreen(category: category, courses: courseDetails[category.name.toString().toLowerCase()]!,),
                )),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width / 2,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                height: MediaQuery.of(context).size.height / 9,
                                padding: EdgeInsets.all(30),
                                child: SvgPicture.asset(
                                  category.logo.toString(),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(234, 242, 242, 244),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(children: [
                                  Text(
                                    category.name.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    category.courses.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
