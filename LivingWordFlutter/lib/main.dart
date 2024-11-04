import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:living_word/core/services/firebase_messaging_service.dart';
import 'package:living_word/features/auth/presentation/screens/signup_screen.dart';
import 'package:living_word/features/sermonnotes/presentation/screens/sermon_notes_screen.dart';
import 'package:living_word/features/sermonnotes/providers/sermon_notes_provider.dart';
import 'package:provider/provider.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/contacts/presentation/screens/contacts_screen.dart';
import 'features/contacts/providers/contacts_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/navigation_provider.dart';
import 'features/newsletters/presentation/screens/newsletters_screen.dart';
import 'features/newsletters/providers/newsletters_provider.dart';
import 'features/prayers/data/repositories/prayer_repository.dart';
import 'features/prayers/presentation/screens/prayer_list_screen.dart';
import 'features/prayers/providers/prayer_provider.dart';
import 'features/videos/data/repositories/videos_repository.dart';
import 'features/videos/presentation/screens/videos_screen.dart';
import 'features/videos/providers/videos_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa Firebase
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository())),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ContactsProvider()),
        ChangeNotifierProvider(create: (_) => VideosProvider(VideoRepository())),
        ChangeNotifierProvider(create: (_) => PrayerProvider(PrayerRepository())),
        ChangeNotifierProvider(create: (_) => SermonNotesProvider()),
        ChangeNotifierProvider(create: (_) => NewslettersProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // Inicializa Firebase Messaging después de que la app haya arrancado
  FirebaseMessagingService _fcmService = FirebaseMessagingService();
  _fcmService.initialize().catchError((e) => print("Error initializing FCM: $e"));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determina la ruta inicial según el estado de autenticación
    final initialRoute = context.watch<AuthProvider>().isAuthenticated ? '/home' : '/login';

    return MaterialApp(
      title: 'Living Word App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/contacts': (context) => const ContactsScreen(),
        '/videos': (context) => const VideosScreen(),
        '/prayer-requests': (context) => const PrayerListScreen(),
        '/sermon-notes': (context) => const SermonNotesScreen(),
        '/newsletters': (context) => const NewsletterScreen(),

        // Agrega más rutas según sea necesario
      },
    );
  }
}