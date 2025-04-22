import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/cart_service.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/reset_password_screen.dart';
import 'screens/catalog_screen.dart';
import 'providers/theme_provider.dart';
import 'widgets/menu.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PostWare',
          theme: themeProvider.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
            '/catalog': (context) => const CatalogScreen(),
          },
        );
      },
    );
  }
}
