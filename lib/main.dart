import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/screens/onboarding_screen.dart';
import 'package:notes_app/screens/pin_screen.dart';
import 'package:notes_app/services/theme_provider.dart';
import 'package:notes_app/services/university_setup_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await UniversitySetupService().initializeFaculties();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('fr'),
      useOnlyLangCode: true,
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final fontSize = themeProvider.fontSize;
        
        TextTheme buildTextTheme(TextTheme base, Color color) {
          return base.copyWith(
            bodyLarge: base.bodyLarge?.copyWith(fontSize: fontSize + 2, color: color),
            bodyMedium: base.bodyMedium?.copyWith(fontSize: fontSize, color: color),
            titleLarge: base.titleLarge?.copyWith(fontSize: fontSize + 6, color: color, fontWeight: FontWeight.bold),
            labelLarge: base.labelLarge?.copyWith(fontSize: fontSize, color: color),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "UniNotes",
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale, 
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF0A3D62),
            scaffoldBackgroundColor: const Color(0xFFF5F6FA),
            textTheme: buildTextTheme(ThemeData.light().textTheme, Colors.black87),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0A3D62),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF0A3D62), 
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blueGrey[700],
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: buildTextTheme(ThemeData.dark().textTheme, Colors.white),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blueGrey[800],
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blueGrey[700], 
              foregroundColor: Colors.white,
            ),
          ),
          home: hasSeenOnboarding 
              ? const AuthWrapper(key: ValueKey('AuthWrapper')) 
              : const OnboardingScreen(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint("Auth anonyme hors-ligne: $e");
      }
    }
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return const PinScreen();
    }
    // Écran de chargement imitant le style Splash Screen : Fond Noir + Logo dans carré blanc arrondi
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 192,
          height: 192,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(55),
          ),
          child: Center(
            child: Image.asset(
              'assets/applogo.png', // Utilise applogo
              height: 60, // Taille diminuée à 60
              width: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
