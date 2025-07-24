import 'package:flutter/material.dart';
import 'package:study_app/utils/colors.dart';

class ProfileBox extends StatelessWidget {
  final String imageUrl;
  const ProfileBox({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      decoration: BoxDecoration(color: primaryColor),
      padding: const EdgeInsets.only(left: 10),
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 37,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: MediaQuery.of(context).size.width * 0.28,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 15,
                    child: Icon(Icons.edit, color: Colors.black, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
