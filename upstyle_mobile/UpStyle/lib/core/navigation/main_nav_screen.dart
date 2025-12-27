import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_style/features/auth/presentation/provider/auth_provider.dart';
import 'package:up_style/features/auth/domain/entities/user.dart';
import 'package:up_style/features/creator/presentation/screens/creators_list_screen.dart';
import 'package:up_style/features/home/presentation/screens/home_screen.dart';
import 'package:up_style/features/profile/presentation/profile_screen.dart';
import 'package:up_style/features/warderobe/presentation/screens/wardrobe_screen.dart';
import 'package:up_style/features/warderobe/presentation/screens/add_item_screen.dart';
import 'package:up_style/features/chat/presentation/screens/chat_rooms_screen.dart';
import 'package:up_style/core/navigation/creator_navigation.dart';
import '../../../core/theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WardrobeScreen(),
    const AddItemScreenAI(), // Add Item screen
    const CreatorsListScreen(),
    const ChatRoomsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Redirect to auth if not authenticated
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authProvider.user;

        // Check if user is in creator mode
        if (user != null && user.role == UserRole.creator) {
          return const CreatorNavigationScreen();
        }

        // Regular user navigation - 6 equal tabs
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: CupertinoIcons.house,
                selectedIcon: CupertinoIcons.house_fill,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: CupertinoIcons.cube_box,
                selectedIcon: CupertinoIcons.cube_box_fill,
                label: 'Wardrobe',
                index: 1,
              ),
              _buildNavItem(
                icon: CupertinoIcons.add_circled,
                selectedIcon: CupertinoIcons.add_circled_solid,
                label: 'Add',
                index: 2,
              ),
              _buildNavItem(
                icon: CupertinoIcons.person_2,
                selectedIcon: CupertinoIcons.person_2_fill,
                label: 'Creators',
                index: 3,
              ),
              _buildNavItem(
                icon: CupertinoIcons.chat_bubble,
                selectedIcon: CupertinoIcons.chat_bubble_fill,
                label: 'Chats',
                index: 4,
              ),
              _buildNavItem(
                icon: CupertinoIcons.person,
                selectedIcon: CupertinoIcons.person_fill,
                label: 'Profile',
                index: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary.withOpacity(0.6),
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
