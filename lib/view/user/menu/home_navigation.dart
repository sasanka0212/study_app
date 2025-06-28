import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/pages/categories.dart';
import 'package:study_app/view/user/pages/home.dart';
import 'package:study_app/view/user/pages/user_profile.dart';

class HomeNavigation extends StatelessWidget {
  const HomeNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    //create navigation controller instance
    final controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey, width: 0.3),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              elevation: 5,
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold);
                }
                return const TextStyle(color: Colors.grey, fontSize: 12);
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: Colors.white,);
                }
                return IconThemeData(color: Colors.black54);
              }),
            ),
            child: NavigationBar(
              height: 70,
              elevation: 0,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) {
                controller.selectedIndex.value = index;
              },
              backgroundColor: Colors.white,
              indicatorColor: primaryColor,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              
              destinations: const [
                //first page
                NavigationDestination(
                    icon: Icon(Icons.category_outlined, size: 30,), label: 'Category'),
                //second page
                NavigationDestination(icon: Icon(Icons.home_outlined, size: 30,), label: 'Home'),
                //fourth page
                NavigationDestination(icon: Icon(Icons.person_outline, size: 30,), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final screens = [
    const Categories(),
    const Home(),
    const UserProfile(),
  ];
}
