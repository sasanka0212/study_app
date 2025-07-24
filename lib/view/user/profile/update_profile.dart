import 'package:flutter/material.dart';
import 'package:study_app/classes/user_data.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/widgets/profile_box.dart';

class UpdateProfile extends StatefulWidget {
  final UserData userData;
  const UpdateProfile({super.key, required this.userData});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _emailController = TextEditingController(text: widget.userData.email);
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          elevation: 2,
          shadowColor: Colors.black45,
          // I use flexible space to add liner-gradient color to appbar
          flexibleSpace: Container(
            decoration: BoxDecoration(color: primaryColor),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_outlined, color: Colors.black),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileBox(imageUrl: widget.userData.photoUrl),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(right: 16, left: 16),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 0.2,
                          ),
                        ),
                        labelText: "Name",
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter Name" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 0.2,
                          ),
                        ),
                        labelText: "Email",
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter Email" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 0.2,
                          ),
                        ),
                        labelText: "Mobile Number",
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter Mobile Number" : null,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
