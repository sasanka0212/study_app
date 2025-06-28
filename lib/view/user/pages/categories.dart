import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/view/user/pages/manage_quiz_screen.dart';
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
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  double _opacity = 1.0;
  final double expandedHeight = 200;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _scrollController.addListener(() {
      setState(() {
        _opacity = _scrollController.offset <= 1 ? 1.0 : 0.0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final snapshot = await _firebaseFirestore
          .collection('categories')
          .orderBy('createdAt', descending: true)
          .get();
      final SharedPreferences pref = await SharedPreferences.getInstance();
      //final email = await FirebaseAuth.instance.currentUser!.email;
      //final userInfo = await FirebaseFirestore.instance
      //.collection('users')
      //.where('email', isEqualTo: email)
      //.get();
      //List<UserData> userData =
      //userInfo.docs.map((e) => UserData.fromMap(e.id, e.data())).toList();
      setState(() {
        _allCategories = snapshot.docs
            .map((doc) => Category.fromMap(doc.id, doc.data()))
            .toList();
        _categoryfilters = ['All'] +
            _allCategories.map((category) => category.name).toSet().toList();
        _filteredCategories = _allCategories;
        _userName = pref.getString('username')!;
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
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
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
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  centerTitle: false,
                  pinned: true,
                  floating: true,
                  backgroundColor: primaryColor,
                  
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
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
                  /*Text(
                    "QuickStudy",
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),*/
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    var top = constraints.biggest.height;
                    double opacity = (top - kToolbarHeight) / 200;
                    opacity = opacity.clamp(0.0, 1.0);
                    return FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: appbarGradientColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Opacity(
                          opacity: opacity,
                          child: SafeArea(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: kToolbarHeight + 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome, $_userName!",
                                        style: GoogleFonts.raleway(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "Here's all you need for",
                                        style: GoogleFonts.robotoSerif(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(color: primaryColor, width: 1),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _searchController,
                                          onChanged: (value) =>
                                              _filterCategories(value),
                                          decoration: InputDecoration(
                                            hintText: "Search categories...",
                                            hintStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.black38,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.search,
                                              color: primaryColor,
                                            ),
                                            suffixIcon: _searchController
                                                    .text.isNotEmpty
                                                ? IconButton(
                                                    onPressed: () {
                                                      _searchController.clear();
                                                      _filterCategories('');
                                                    },
                                                    icon: const Icon(
                                                      Icons.clear,
                                                      color: primaryColor,
                                                    ),
                                                  )
                                                : null,
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
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
                        ),
                      ),
                      collapseMode: CollapseMode.pin,
                    );
                  }),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categoryfilters.length,
                      itemBuilder: (context, index) {
                        final filter = _categoryfilters[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
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
                            checkmarkColor: Colors.white,
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
                  padding: const EdgeInsets.all(16),
                  sliver: _filteredCategories.isEmpty
                      ? const SliverToBoxAdapter(
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey, width: 0.2),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                      : const Icon(
                          Icons.quiz,
                          size: 48,
                          color: primaryColor,
                        ),
                ),
                const SizedBox(
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
                const SizedBox(
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
        .slideY(begin: 0.5, end: 0, duration: const Duration(milliseconds: 300))
        .fadeIn();
  }
}
