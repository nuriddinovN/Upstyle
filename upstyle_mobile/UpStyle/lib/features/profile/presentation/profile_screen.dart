// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_style/features/auth/presentation/provider/auth_provider.dart';
import 'package:up_style/features/auth/domain/entities/user.dart';
import 'package:up_style/features/creator/presentation/provider/creators_provider.dart';
import 'package:up_style/features/creator/presentation/screens/become_creator_screen.dart';
import 'package:up_style/features/home/presentation/provider/statistics_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer2<AuthProvider, StatisticsProvider>(
            builder: (context, authProvider, statisticsProvider, child) {
              final user = authProvider.user;
              final statistics = statisticsProvider.statistics;

              return Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: user?.profileImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    user!.profileImageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 16),

                        // User Name
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // User Email
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),

                        // Creator Badge
                        if (user?.isCreator == true) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user?.role == UserRole.creator
                                      ? 'Creator Mode'
                                      : 'Creator',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistics Cards
                  if (statistics != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Wardrobe Stats',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Items',
                                  statistics.totalItems.toString(),
                                  Icons.checkroom,
                                  AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Upcycled',
                                  statistics.totalUpcycled.toString(),
                                  Icons.recycling,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Upstyled',
                                  statistics.totalUpStyled.toString(),
                                  Icons.auto_awesome,
                                  Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Clothing',
                                  statistics.totalClothing.toString(),
                                  Icons.local_laundry_service,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Menu Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Creator Section
                        if (user?.isCreator == true) ...[
                          // Mode Switch
                          _buildMenuItem(
                            icon: user?.role == UserRole.creator
                                ? Icons.person
                                : Icons.workspace_premium,
                            title: user?.role == UserRole.creator
                                ? 'Switch to User Mode'
                                : 'Switch to Creator Mode',
                            onTap: () => _switchMode(user!),
                            textColor: AppTheme.primaryColor,
                          ),
                          const Divider(height: 32),
                        ],

                        // Become Creator (if not already)
                        if (user?.isCreator == false)
                          _buildMenuItem(
                            icon: Icons.star_outline,
                            title: 'Become a Creator',
                            subtitle: 'Help others with upcycling',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BecomeCreatorScreen(),
                                ),
                              );
                            },
                            textColor: Colors.amber[700],
                          ),

                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          onTap: () {
                            // TODO: Navigate to edit profile
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {
                            // TODO: Navigate to notifications settings
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () {
                            // TODO: Navigate to help
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () {
                            _showAboutDialog();
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Sign Out',
                          onTap: () {
                            _showSignOutDialog(authProvider);
                          },
                          textColor: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor ?? AppTheme.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary.withOpacity(0.5),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _switchMode(User user) async {
    final creatorsProvider = context.read<CreatorsProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    bool success;
    if (user.role == UserRole.creator) {
      success = await creatorsProvider.switchToUserMode();
    } else {
      success = await creatorsProvider.switchToCreatorMode();
    }

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (success) {
      // Reload user
      await context.read<AuthProvider>().refreshUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.role == UserRole.creator
                ? '✅ Switched to User Mode'
                : '✅ Switched to Creator Mode',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${creatorsProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Upstyle'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upstyle v1.0.0'),
            SizedBox(height: 8),
            Text(
              'Transform your wardrobe with AI-powered styling and upcycling suggestions.',
            ),
            SizedBox(height: 16),
            Text(
              'Built with Flutter and Firebase',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
