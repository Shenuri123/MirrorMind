import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/screen/screen.dart';

import '../diary/diary.dart';
import '../src/my_app.dart';

class Nav extends StatefulWidget {
  static String routeName = '/nav';
  const Nav({
    Key? key,
  }) : super(key: key);

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  final user = FirebaseAuth.instance.currentUser!;
  final List<Widget> _pages = [];
  int _currentIndex = 0;
  @override
  void initState() {
    _pages.add(HomeScreen());
    _pages.add(Explore());
    _pages.add(Diary());
    _pages.add(Chart());
    _pages.add(ProfileScreen());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.colorPrimary,
        unselectedItemColor: AppColors.colorTint600,
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/home.png'),
              size: 21, // Set the desired size of the icon
            ),
            label: 'Home',
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Explore'),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/explore.png'),
              size: 21, // Set the desired size of the icon
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/diary.png'),
              size: 21, // Set the desired size of the icon
            ),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/sleep.png'),
              size: 21, // Set the desired size of the icon
            ),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/profile.png'),
              size: 21, // Set the desired size of the icon
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}