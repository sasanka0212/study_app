import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
        () => NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            controller.selectedIndex.value = index;
          },
          destinations: const [
            //first page
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            //second page
            NavigationDestination(
                icon: Icon(Iconsax.category), label: 'Category'),
            //fourth page
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  //set screens according to bottom navigation
  final screens = [
    const Home(),
    const Categories(),
    const UserProfile(),
  ];
}
