import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/features/home/screens/home_screen.dart';
import 'package:speak_up/features/learn/learn_screen.dart';
import 'package:speak_up/features/expect/screens/expect_screen.dart';
import 'package:speak_up/features/profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  final int currentIndex;

  const MainScreen({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(),
      LearnScreen(),
      ExpectScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navigation,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.iconHome,
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.iconBook,
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Học',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.iconDiscover,
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.iconProfile,
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/learn');
        break;
      case 2:
        context.go('/expect');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
