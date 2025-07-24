import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/pages/manage_quiz_screen.dart';
import 'package:study_app/view/user/widgets/course_box.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Icon favorite = const Icon(Icons.favorite_outline);
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Category> _favCategories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final snapShot = await _firestore
          .collection('categories')
          .get();
      setState(() {
        _favCategories = snapShot.docs
            .map((doc) => Category.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong!",
            style: GoogleFonts.nunito(
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Material(
                elevation: 5.0,
                shadowColor: Colors.black12,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: Image.asset(
                    'assets/images/appbarlogo.png',
                    height: 45,
                    width: 45,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              border: Border.all(
                color: primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(5),
            child: const Icon(
              Icons.settings,
              color: primaryColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            //onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => )),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(5),
              child: const Icon(
                Icons.person,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: 
      _isLoading
      ? Center(
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeWidth: 3,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Loading",
                  style: GoogleFonts.nunito(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        )
        : ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 30, bottom: 20),
        children: [
          const SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 10,
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
                  /* Column(
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
                  ), */
                ],
              ), 
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                  itemCount: _favCategories.length,
                  itemBuilder: (context, index) {
                    final category = _favCategories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: CourseBox(
                        lvl: category.description, 
                        title: category.name, 
                        imageUrl: category.logo, 
                        gradientColor: (index % 2 == 0) ? redGradientColor : blueGradientColor, 
                        state: const Icon(Icons.play_arrow),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageQuizScreen(category: category),),),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
