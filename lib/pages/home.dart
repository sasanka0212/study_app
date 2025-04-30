import 'package:flutter/material.dart';
import 'package:study_app/externals/links.dart';
import 'package:study_app/menu/home_navigation.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/widgets/course_box.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Icon favorite = Icon(Icons.favorite_outline);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50, left: 20, right: 30, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(5),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (favorite.icon == Icons.favorite_outline) {
                            favorite = Icon(Icons.favorite_rounded);
                          } else {
                            favorite = Icon(Icons.favorite_outline);
                          }
                        });
                      },
                      child: Icon(
                        favorite.icon,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Let's Start",
                style: TextStyle(
                  color: Color(0xFFF35E7A),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Be the first!",
                style: TextStyle(
                  color: newBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  CourseBox(
                    lvl: 'Level 1',
                    title: 'Python Basics',
                    gradientColor: redGradientColor,
                    state: Icon(Icons.done),
                    imageUrl:
                        'https://imgs.search.brave.com/KVObnqX1GH8mCDH-u4t_sTv_sPhuXpryiyIFQxjuUdE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/dmVjdG9ybG9nby56/b25lL2xvZ29zL3B5/dGhvbi9weXRob24t/aWNvbi5zdmc',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CourseBox(
                    lvl: 'Level 1',
                    title: 'Java Advanced',
                    gradientColor: blueGradientColor,
                    state: Icon(Icons.play_arrow),
                    imageUrl:
                        'https://imgs.search.brave.com/eLMJ8qprrX8ujnvWdEiyW4Z_gWbATBsPKhWiVjr_6Z8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly91cGxv/YWQud2lraW1lZGlh/Lm9yZy93aWtpcGVk/aWEvaXQvMi8yZS9K/YXZhX0xvZ28uc3Zn',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CourseBox(
                    lvl: 'Level 2',
                    title: 'App Development using Flutter',
                    gradientColor: redGradientColor,
                    state: Icon(Icons.lock_rounded),
                    imageUrl:
                        'https://imgs.search.brave.com/esa9ihfcvoRJ212gf36XT2Rz8W0cUVqhEY23ppJO910/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9yYXcu/Z2l0aHVidXNlcmNv/bnRlbnQuY29tL2Ru/ZmllbGQvZmx1dHRl/cl9zdmcvN2QzNzRk/NzEwNzU2MWNiZDkw/NmQ3YzBjYTI2ZmVm/MDJjYzAxZTdjOC9l/eGFtcGxlL2Fzc2V0/cy9mbHV0dGVyX2xv/Z28uc3ZnP3Nhbml0/aXplPXRydWU',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CourseBox(
                    lvl: 'Level 1',
                    title: 'Getting Started with Figma',
                    state: Icon(Icons.done),
                    gradientColor: blueGradientColor,
                    imageUrl:
                        'https://imgs.search.brave.com/Cw7Uw4d-7CL2cDKMniS2oWCf59xdnLFUi1BXIibyguY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly91cGxv/YWQud2lraW1lZGlh/Lm9yZy93aWtpcGVk/aWEvY29tbW9ucy8z/LzMzL0ZpZ21hLWxv/Z28uc3Zn',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
