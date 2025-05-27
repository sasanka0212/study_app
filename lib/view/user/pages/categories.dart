import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/classes/user_data.dart';
import 'package:study_app/externals/all_courses.dart';
import 'package:study_app/view/user/pages/manage_quiz_screen.dart';
import 'package:study_app/view/user/pages/search_page.dart';
import 'package:study_app/utils/colors.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final _firebaseFirestore = FirebaseFirestore.instance;
  String _seletecdFilter = "All";
  List<Category> _allCategories = [];
  List<String> _categoryfilters = ['All'];
  List<Category> _filteredCategories = [];
  final _searchController = TextEditingController();
  String _userName = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
    _getUserName();
  }

  Future<void> _getUserName() async {
    final email = await FirebaseAuth.instance.currentUser!.email;
    final userInfo = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    List<UserData> userData =
        userInfo.docs.map((e) => UserData.fromMap(e.id, e.data())).toList();
    setState(() {
      _userName = userData.first.name;
    });
  }

  Future<void> _fetchCategories() async {
    final snapshot = await _firebaseFirestore
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .get();
    setState(() {
      _allCategories = snapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      _categoryfilters = ['All'] +
          _allCategories.map((category) => category.name).toSet().toList();
      _filteredCategories = _allCategories;
    });
  }

  void _filterCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        final matchesSearch = category.name
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            category.description.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = categoryFilter == null ||
            categoryFilter == 'All' ||
            category.name.toLowerCase() == categoryFilter.toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  /*
  @override
  Widget build(BuildContext context) {
    final List<Category> categories = [
      Category(
        id: 'c1',
        logo: 'assets/images/design.svg',
        description: 'Design your thoughts independently',
        name: 'Design',
      ),
      Category(
        id: 'c2',
        logo: 'assets/images/marketing.svg',
        description: 'Show your marketing skills',
        name: 'Marketing',
      ),
      Category(
        id: 'c3',
        logo: 'assets/images/engineering.svg',
        description: 'Convert your idea into implementation',
        name: 'Engineering',
      ),
      Category(
        id: 'c4',
        logo: 'assets/images/it.svg',
        description: 'Skills better then knowledge',
        name: 'IT',
      ),
      Category(
        id: 'c5',
        logo: 'assets/images/teaching.svg',
        description: 'Teach better learn best',
        name: 'Teaching',
      ),
      Category(
        id: 'c6',
        logo: 'assets/images/medical.svg',
        description: 'Know from scratch for your future',
        name: 'Medical',
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
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
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
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
                            ManageQuizScreen(
                          category: category,
                          courses: courseDetails[
                              category.name.toString().toLowerCase()]!,
                        ),
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
                                    "10 Courses",
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
  */
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 225,
            pinned: true,
            floating: true,
            centerTitle: false,
            backgroundColor: primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            title: Text(
              "QuickStudy",
              style: GoogleFonts.raleway(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: kToolbarHeight + 16,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, $_userName!",
                            style: GoogleFonts.raleway(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Here's all you need for",
                            style: GoogleFonts.robotoSerif(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _filterCategories(value),
                              decoration: InputDecoration(
                                hintText: "Search categories...",
                                hintStyle: GoogleFonts.robotoSerif(
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: primaryColor,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          _filterCategories('');
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: primaryColor,
                                        ),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryfilters.length,
                itemBuilder: (context, index) {
                  final filter = _categoryfilters[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: GoogleFonts.raleway(
                          color: _seletecdFilter == filter
                              ? Colors.white
                              : textPrimaryColor,
                        ),
                      ),
                      selected: _seletecdFilter == filter,
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      onSelected: (value) {
                        setState(() {
                          _seletecdFilter = filter;
                        });
                        _filterCategories(
                          _searchController.text,
                          categoryFilter: filter,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: _filteredCategories.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "No categories found",
                        style: TextStyle(
                          color: textSecondaryColor,
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCategoryCard(
                        _filteredCategories[index],
                        index,
                      ),
                      childCount: _filteredCategories.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return Animate(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageQuizScreen(category: category),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: category.logo != ''
                      ? Image.network(
                          category.logo,
                          height: 48,
                          width: 48,
                        )
                      : Icon(
                          Icons.quiz,
                          size: 48,
                          color: primaryColor,
                        ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  category.name,
                  style: GoogleFonts.raleway(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  category.description,
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }
}
