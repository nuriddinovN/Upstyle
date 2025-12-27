import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_style/features/auth/presentation/provider/auth_provider.dart';
import 'package:up_style/features/chat/presentation/screens/explore_screen.dart';
import 'package:up_style/features/chat/presentation/screens/portfolio_screen.dart';
import 'package:up_style/features/profile/presentation/profile_screen.dart';
import 'package:up_style/features/chat/presentation/screens/chat_rooms_screen.dart';
import '../../../core/theme/app_theme.dart';

class CreatorNavigationScreen extends StatefulWidget {
  const CreatorNavigationScreen({super.key});

  @override
  State<CreatorNavigationScreen> createState() =>
      _CreatorNavigationScreenState();
}

class _CreatorNavigationScreenState extends State<CreatorNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ExploreScreen(), // Browse all upcycled items
    const PortfolioScreen(), // Creator's own work
    const ChatRoomsScreen(), // Messages
    const ProfileScreen(), // Profile (with switch to user mode)
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
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: CupertinoIcons.search,
                selectedIcon: CupertinoIcons.search_circle_fill,
                label: 'Explore',
                index: 0,
              ),
              _buildNavItem(
                icon: CupertinoIcons.folder,
                selectedIcon: CupertinoIcons.folder_fill,
                label: 'Portfolio',
                index: 1,
              ),
              _buildNavItem(
                icon: CupertinoIcons.chat_bubble,
                selectedIcon: CupertinoIcons.chat_bubble_fill,
                label: 'Chats',
                index: 2,
              ),
              _buildNavItem(
                icon: CupertinoIcons.person,
                selectedIcon: CupertinoIcons.person_fill,
                label: 'Profile',
                index: 3,
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

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
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
