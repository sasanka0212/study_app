import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/pages/search_page.dart';
import 'package:study_app/widgets/category_card_vertical.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = [
      Category('Design', 'assets/images/design.svg', '10 Courses'),
      Category('Marketing', 'assets/images/marketing.svg', '10 Courses'),
      Category('Engineering', 'assets/images/engineering.svg', '10 Courses'),
      Category('IT', 'assets/images/it.svg', '25 Courses'),
      Category('Teaching', 'assets/images/teaching.svg', '20 Courses'),
      Category('Medical', 'assets/images/medical.svg', '20 Courses'),
    ];
    return Scaffold(
      backgroundColor: Color.fromARGB(223, 237, 237, 240),
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
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchPage())),
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
                .map((category) => Material(
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
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
