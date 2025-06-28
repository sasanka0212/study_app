import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/category.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/widgets/cart_box.dart';

class UserCart extends StatefulWidget {
  final String uid;
  const UserCart({super.key, required this.uid});

  @override
  State<UserCart> createState() => _UserCartState();
}

class _UserCartState extends State<UserCart> {
  List<String> _cid = [];
  List<Category> _purchasedCategories = [];
  List<int> _quizToCategory = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<List<String>> fetchCids(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('user_data')
        .doc(userId)
        .get();
    if (doc.exists && doc.data() != null) {
      List<dynamic> rawCids = doc.data()!['cid'] ?? [];
      return List<String>.from(rawCids); // Cast to List<String>
    }
    return [];
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      //final doc = await _firestore.collection('users').doc(widget.uid).get();
      List<String> cids = await fetchCids(widget.uid);
      setState(() {
        _cid = cids;
      });
      final List<Category> categories = [];
      for (String id in _cid) {
        final snapShot = await _firestore
            .collection('categories')
            .doc(id)
            .get();
        if (snapShot.exists && snapShot.data() != null) {
          categories.add(Category.fromMap(snapShot.id, snapShot.data()!));
        }
      }
      setState(() {
        _purchasedCategories = categories;
      });
      for (int i = 0; i < _cid.length; i++) {
        final snapShot = await _firestore
            .collection('quizzes')
            .where('categoryId', isEqualTo: _cid[i])
            .get();
        _quizToCategory.add(snapShot.size);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong",
            style: TextStyle(color: Colors.white),
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Your Cart",
          style: GoogleFonts.nunito(
            color: textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                    const SizedBox(width: 10),
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
          : Padding(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _purchasedCategories.length,
                itemBuilder: (context, index) {
                  final category = _purchasedCategories[index];
                  return CartBox(
                    categoryName: category.name,
                    totalQuiz: '${_quizToCategory[index]}',
                    url: category.logo,
                  );
                },
              ),
            ),
    );
  }
}
