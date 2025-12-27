import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:up_style/core/navigation/main_nav_screen.dart';
import 'package:up_style/features/auth/presentation/provider/auth_provider.dart';
import 'package:up_style/features/home/presentation/screens/home_screen.dart';
import 'package:up_style/features/profile/presentation/profile_screen.dart';
import 'package:up_style/features/warderobe/presentation/screens/add_item_screen.dart';
import 'package:up_style/features/warderobe/presentation/screens/category_item_screen.dart';
import 'package:up_style/features/warderobe/presentation/screens/item_detail_screen.dart';
import 'package:up_style/features/warderobe/presentation/screens/wardrobe_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String main = '/main';
  static const String home = '/home';
  static const String wardrobe = '/wardrobe';
  static const String categoryItems = '/category-items'; // NEW
  static const String addItem = '/add-item';
  static const String profile = '/profile';
  static const String itemDetail = '/item-detail';

  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final path = state.uri.path;

      // Check authentication status
      if (authProvider.status == AuthStatus.authenticated) {
        // User is authenticated, allow access to protected routes
        if (path == onboarding || path == signup || path == login) {
          return main;
        }
      } else if (authProvider.status == AuthStatus.unauthenticated) {
        // User is not authenticated, redirect to onboarding
        if (path != onboarding && path != signup && path != login) {
          return onboarding;
        }
      } else if (authProvider.status == AuthStatus.emailNotVerified) {
        // Email not verified, stay on auth screens
        if (path != onboarding && path != signup && path != login) {
          return login;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app routes
      GoRoute(
        path: main,
        name: 'main',
        builder: (context, state) => const MainNavigationScreen(),
      ),

      // Individual screens (for direct navigation)
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Main Wardrobe screen (from bottom navigation)
      GoRoute(
        path: wardrobe,
        name: 'wardrobe',
        builder: (context, state) {
          final categoryId = state.extra as String?;
          return WardrobeScreen(categoryId: categoryId);
        },
      ),

      // NEW: Category Items screen (when clicking category from dashboard)
      // This is DIFFERENT from the main Wardrobe tab
      GoRoute(
        path: '$categoryItems/:categoryId/:categoryName',
        name: 'category-items',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final categoryName = state.pathParameters['categoryName']!;
          return CategoryItemsScreen(
            categoryId: categoryId,
            categoryName: Uri.decodeComponent(categoryName),
          );
        },
      ),

      GoRoute(
        path: addItem,
        name: 'add-item',
        builder: (context, state) => const AddItemScreenAI(),
      ),

      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '$itemDetail/:itemId',
        name: 'item-detail',
        builder: (context, state) {
          final itemId = state.pathParameters['itemId']!;
          return ItemDetailScreen(itemId: itemId);
        },
      ),
    ],
  );
}
