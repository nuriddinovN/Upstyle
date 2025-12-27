import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:up_style/features/auth/presentation/provider/auth_provider.dart';
import 'package:up_style/features/creator/presentation/provider/creators_provider.dart';
import 'package:up_style/features/home/presentation/provider/categories_provider.dart';
import 'package:up_style/features/home/presentation/provider/statistics_provider.dart';
import 'package:up_style/features/warderobe/presentation/provider/item_provider.dart';
import 'package:up_style/features/chat/presentation/provider/chat_provider.dart'; // NEW
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await configureDependencies();

  runApp(const UpstyleApp());
}

class UpstyleApp extends StatelessWidget {
  const UpstyleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => sl<CreatorsProvider>()), // NEW
        ChangeNotifierProvider(create: (_) => sl<ChatProvider>()), // NEW
      ],
      child: MaterialApp.router(
        title: 'Upstyle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
