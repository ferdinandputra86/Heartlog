import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heartlog/screens/index.dart';
import 'package:heartlog/constants/index.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            BerandaScreen(),
            DiaryScreen(),
            StatisticScreen(),
            ProfileScreen(),
          ],
        );
      }),
      extendBody:
          true, // Penting: membuat body menyatu dengan navbar (mengurangi terpotongnya navbar)
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: const [
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
              backgroundColor: AppColors.background,
              indicatorColor: AppColors.primary.withOpacity(0.3),
              height: 65, // Tinggi navbar yang lebih kecil
              elevation: 0,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected:
                  (index) => controller.selectedIndex.value = index,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Iconsax.home, color: AppColors.textSecondary),
                  selectedIcon: Icon(Iconsax.home, color: AppColors.primary),
                  label: 'Beranda',
                ),
                const NavigationDestination(
                  icon: Icon(
                    Iconsax.book_saved,
                    color: AppColors.textSecondary,
                  ),
                  selectedIcon: Icon(
                    Iconsax.book_saved,
                    color: AppColors.primary,
                  ),
                  label: 'Diari',
                ),
                const NavigationDestination(
                  icon: Icon(Iconsax.chart, color: AppColors.textSecondary),
                  selectedIcon: Icon(Iconsax.chart, color: AppColors.primary),
                  label: 'Statistik',
                ),
                const NavigationDestination(
                  icon: Icon(Iconsax.user, color: AppColors.textSecondary),
                  selectedIcon: Icon(Iconsax.user, color: AppColors.primary),
                  label: 'Profil',
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
