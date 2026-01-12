import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart'; // Required for auto-login routing

void main() async {
  // 1. Ensure bindings are initialized (Required before Hive init)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Offline Database
  await Hive.initFlutter();
  
  // 3. Open necessary boxes (Database tables)
  await Hive.openBox('settings'); // For app settings & session data
  await Hive.openBox('reports');  // For Mulika tool
  await Hive.openBox('users');    // For Login/Signup System
  
  // 4. Session Logic: Check if we should auto-login
  Widget startScreen = const LandingScreen(); // Default to Landing
  final settings = Hive.box('settings');

  // Check if a user is logged in
  if (settings.containsKey('lastLoggedInUser')) {
    final String? lastActiveStr = settings.get('lastActiveTime');
    
    if (lastActiveStr != null) {
      final DateTime lastActive = DateTime.parse(lastActiveStr);
      final DateTime now = DateTime.now();
      final int daysInactive = now.difference(lastActive).inDays;
      
      // If inactive for less than 30 days, auto-login to Home
      if (daysInactive < 30) {
        startScreen = const HomeScreen();
      } else {
        // Session expired (older than 30 days), clear the session
        settings.delete('lastLoggedInUser'); 
      }
    }
  }

  runApp(
    // 5. Wrap App in Provider to handle State (Language Switching)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      // Pass the calculated startScreen to the app
      child: CyberMfukoniApp(startScreen: startScreen),
    ),
  );
}

class CyberMfukoniApp extends StatelessWidget {
  // Accept the dynamic start screen determined in main()
  final Widget startScreen;

  const CyberMfukoniApp({super.key, this.startScreen = const LandingScreen()});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Mfukoni',
      debugShowCheckedModeBanner: false,
      
      // 6. Cyber Green Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1117), // Dark cyber background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Cyber Green
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      
      // 7. Use the dynamic start screen (Home or Landing)
      home: startScreen,
    );
  }
}

// ---------------------------------------------------------
// STATE MANAGEMENT (Language Logic)
// ---------------------------------------------------------
class AppState extends ChangeNotifier {
  String _language = 'English'; // Options: English, Kiswahili, Sheng
  
  String get language => _language;

  void toggleLanguage() {
    if (_language == 'English') {
      _language = 'Kiswahili';
    } else if (_language == 'Kiswahili') {
      _language = 'Sheng';
    } else {
      _language = 'English';
    }
    notifyListeners();
  }

  // Simple translator logic for the Home Screen
  String t(String key) {
    Map<String, Map<String, String>> dict = {
      'welcome': {
        'English': 'Digital Bodyguard',
        'Kiswahili': 'Mlinzi wa Kidijitali',
        'Sheng': 'Bazu wa Mtaa',
      },
      'scan': {
        'English': 'Scan Link',
        'Kiswahili': 'Changanua Kiungo',
        'Sheng': 'Cheki Link',
      }
    };
    return dict[key]?[_language] ?? key;
  }
}