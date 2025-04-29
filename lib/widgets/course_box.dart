import 'package:flutter/material.dart';
import 'package:study_app/externals/links.dart';
import 'package:study_app/utils/colors.dart';

class CourseBox extends StatelessWidget {
  final String lvl;
  final String title;
  final String imageUrl;
  final LinearGradient gradientColor;
  final Icon state;
  const CourseBox({
    super.key,
    required this.lvl,
    required this.title,
    required this.imageUrl,
    required this.gradientColor,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 40),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 16, left: 16),
              //using MediaQuery to save the screen constraints
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: gradientColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white54,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      state.icon,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    lvl,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(242, 249, 247, 247),
                    ),
                  ),
                  Text(
                    title,
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
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Image.network(
                    imageUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
