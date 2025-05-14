import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heartlog/beranda.dart';
import 'package:heartlog/diary.dart';
import 'package:heartlog/profile.dart';
import 'package:heartlog/statistic.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: const [Beranda(), Diary(), Statistic(), Profile()],
        );
      }),
      extendBody:
          true, // Penting: membuat body menyatu dengan navbar (mengurangi terpotongnya navbar)
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1E0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: NavigationBar(
              backgroundColor: const Color(0xFFFFF1E0),
              indicatorColor: const Color(0xfffd745a).withOpacity(0.3),
              height: 65, // Tinggi navbar yang lebih kecil
              elevation: 0,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected:
                  (index) => controller.selectedIndex.value = index,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Iconsax.home, color: Color(0xFF666666)),
                  selectedIcon: Icon(Iconsax.home, color: Color(0xfffd745a)),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Iconsax.book_saved, color: Color(0xFF666666)),
                  selectedIcon: Icon(
                    Iconsax.book_saved,
                    color: Color(0xfffd745a),
                  ),
                  label: 'Diary',
                ),
                NavigationDestination(
                  icon: Icon(Iconsax.chart, color: Color(0xFF666666)),
                  selectedIcon: Icon(Iconsax.chart, color: Color(0xfffd745a)),
                  label: 'Stats',
                ),
                NavigationDestination(
                  icon: Icon(Iconsax.user, color: Color(0xFF666666)),
                  selectedIcon: Icon(Iconsax.user, color: Color(0xfffd745a)),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
}
