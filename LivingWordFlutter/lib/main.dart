import 'package:flutter/material.dart';
import 'package:living_word/features/auth/presentation/screens/signup_screen.dart';
import 'package:provider/provider.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/contacts/presentation/screens/contacts_screen.dart';
import 'features/contacts/providers/contacts_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/navigation_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactsProvider(), // Agrega ContactsProvider aquí
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Living Word App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/contacts': (context) => const ContactsScreen(),

  // Por implementar
      },
    );
  }
}