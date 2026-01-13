import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart'; 

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
    // Cyber Color Palette Constants
    const Color cyberBlack = Color(0xFF0D1117); // Deep GitHub-like dark
    const Color cyberSurface = Color(0xFF161B22); // Slightly lighter card color
    const Color cyberGreen = Color(0xFF00E676); // Neon Green for accents

    return MaterialApp(
      title: 'Cyber Mfukoni',
      debugShowCheckedModeBanner: false,
      
      // 6. Professional Dark Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: cyberBlack,
        primaryColor: cyberGreen,
        
        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: cyberGreen,
          secondary: cyberGreen,
          surface: cyberSurface,
          onPrimary: Colors.black, // Text on green buttons
          onSurface: Colors.white, // Text on dark cards
        ),

        // Modern Text Theme
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.grey[300],
          displayColor: Colors.white,
        ),

        // Card Styling (Glassy/Modern)
        // FIXED: Changed CardTheme to CardThemeData
        cardTheme: CardThemeData(
          color: cyberSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),

        // Input Fields Styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cyberSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cyberGreen, width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIconColor: Colors.grey[500],
        ),

        // Button Styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: cyberGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),

        // AppBar Styling
        appBarTheme: AppBarTheme(
          backgroundColor: cyberBlack,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
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