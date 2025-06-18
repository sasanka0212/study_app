import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/user_data.dart';
import 'package:study_app/firebase_services/auth.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/pages/user_cart.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late UserData _userData;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserName();
  }

  void _operate(int index) {
    switch(index) {
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserCart(uid: FirebaseAuth.instance.currentUser!.uid),),);
      case 4:
        AuthMethods().signOff(context);
      default:
    }
  }

  Future<void> _getUserName() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final email = FirebaseAuth.instance.currentUser!.email;
      final userInfo = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      List<UserData> userData =
          userInfo.docs.map((e) => UserData.fromMap(e.id, e.data())).toList();
      _userData = userData.first;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "PROFILE",
          style: GoogleFonts.raleway(
            color: textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // column for profile picture and its details
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_userData.photoUrl),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      _userData.name,
                      style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                    Text(
                      _userData.email,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                // user status component
                const SizedBox(
                  height: 25,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Complete Your Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "(2/5)",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 7,
                        margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                        decoration: BoxDecoration(
                            color: index == 0 ? primaryColor : Colors.black12,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: profileCards.length,
                    itemBuilder: (context, index) => SizedBox(
                      width: 160,
                      child: Card(
                        shadowColor: Colors.black12,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Icon(
                                profileCards[index].icon,
                                size: 30,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                profileCards[index].title,
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  profileCards[index].buttonText,
                                  style:
                                      GoogleFonts.nunito(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    separatorBuilder: (context, index) =>
                        const Padding(padding: EdgeInsets.only(right: 5)),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                ...List.generate(
                  optionCards.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      child: ListTile(
                        title: Text(optionCards[index].optionTitle),
                        leading: Icon(optionCards[index].leadingIcon),
                        trailing: IconButton(
                          onPressed: () {
                            _operate(index);
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                  ),
                ),
                /*SizedBox(height: 20,),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.logout),
                    style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(4),
                      shadowColor: WidgetStatePropertyAll(Colors.black12),
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    label: Text("Log out"),
                  ),
                ),*/
              ],
            ),
    );
  }
}

class ProfileCard {
  final String title;
  final String buttonText;
  final IconData icon;

  ProfileCard(
      {required this.title, required this.buttonText, required this.icon});
}

class OptionCard {
  final String optionTitle;
  final IconData leadingIcon;
  OptionCard({
    required this.optionTitle,
    required this.leadingIcon,
  });
}

List<OptionCard> optionCards = [
  OptionCard(
    optionTitle: "Activity",
    leadingIcon: Icons.insights,
  ),
  OptionCard(
    optionTitle: "Location",
    leadingIcon: Icons.gps_fixed,
  ),
  OptionCard(
    optionTitle: "Notification",
    leadingIcon: Icons.notifications_none,
  ),
  OptionCard(
    optionTitle: "Saved Courses",
    leadingIcon: Icons.shopping_cart_outlined,
  ),
  OptionCard(
    optionTitle: "Log Out",
    leadingIcon: Icons.logout,
  ),
];

List<ProfileCard> profileCards = [
  ProfileCard(
    title: 'Upload your profile',
    buttonText: 'Update',
    icon: Icons.person,
  ),
  ProfileCard(
    title: 'Enter educational details',
    buttonText: 'Update',
    icon: Icons.school,
  ),
  ProfileCard(
    title: 'Upload your resume',
    buttonText: 'Uplaod',
    icon: Icons.file_upload,
  ),
];
