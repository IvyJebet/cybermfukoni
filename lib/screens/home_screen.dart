import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'dart:async'; 
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:intl/intl.dart'; 
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

// Feature Screens
import 'chonjo_screen.dart';
import 'digital_boma_screen.dart';
import 'mulika_screen.dart';
import 'landing_screen.dart';

// ---------------------------------------------------------
// LOCALIZATION ENGINE (English & Kiswahili)
// ---------------------------------------------------------
class AppLocale {
  static String get(String key) {
    final box = Hive.box('settings');
    String lang = box.get('language', defaultValue: 'English');
    return _localizedValues[lang]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'nav_news': 'News', 'nav_chonjo': 'Chonjo', 'nav_mulika': 'Mulika', 'nav_boma': 'Boma', 'nav_profile': 'Agent',
      'welcome': 'Welcome, Agent', 'live_feed': 'Live Intel Feed',
      'refresh_success': 'Intel Feed Refreshed', 'conn_failed': 'Connection Failed. Check internet.',
      'no_intel': 'No recent intel found.', 'just_now': 'Just now', 'ago': 'ago', 'recent': 'Recent',
      'level': 'Clearance: Level 1', 'active_since': 'Active since',
      'device_status': 'Device Status', 'scan_now': 'SCAN NOW',
      'preferences': 'PREFERENCES', 'language': 'Language', 'alerts': 'Intel Alerts', 'on': 'On', 'off': 'Off',
      'community': 'COMMUNITY', 'recruit': 'Recruit Agent', 'share_app': 'Share App',
      'help': 'Help & Support', 'contact_hq': 'Contact HQ', 'logout': 'Deactivate Session',
      'version': 'Cyber Mfukoni v1.0.0', 'select_lang': 'Select Language',
      'scan_safe': 'System Secure. No threats found.', 'scan_init': 'Initializing protocols...',
      'scan_root': 'Checking Root Access...', 'scan_wifi': 'Analyzing WiFi Encryption...',
      'scan_app': 'Verifying App Integrity...', 'scan_complete': 'Scan Complete: System Secure',
      'wa_us': 'WhatsApp HQ', 'email_hq': 'Email HQ', 'faqs': 'FAQs', 'close': 'Close', 'support_title': 'Agent Support',
      'recruit_msg': '🕵️ Join the Cyber Mfukoni Agency!\n\nI use this app to spot scams and protect my data. Download it here to secure your digital boma:\nhttps://cybermfukoni.co.ke/download',
    },
    'Kiswahili': {
      'nav_news': 'Habari', 'nav_chonjo': 'Chonjo', 'nav_mulika': 'Mulika', 'nav_boma': 'Boma', 'nav_profile': 'Ajenti',
      'welcome': 'Karibu, Ajenti', 'live_feed': 'Taarifa za Usalama',
      'refresh_success': 'Taarifa Zimesasishwa', 'conn_failed': 'Muunganisho umeshindikana. Angalia mtandao.',
      'no_intel': 'Hakuna taarifa mpya.', 'just_now': 'Sasa hivi', 'ago': 'iliyopita', 'recent': 'Hivi karibuni',
      'level': 'Daraja: Ngazi 1', 'active_since': 'Amejiunga',
      'device_status': 'Hali ya Kifaa', 'scan_now': 'KAGUA SASA',
      'preferences': 'MAPENDEKEZO', 'language': 'Lugha', 'alerts': 'Arifa za Usalama', 'on': 'Imewashwa', 'off': 'Imezimwa',
      'community': 'JAMII', 'recruit': 'Sajili Ajenti', 'share_app': 'Shiriki Programu',
      'help': 'Msaada', 'contact_hq': 'Wasiliana na Makao Makuu', 'logout': 'Ondoka',
      'version': 'Cyber Mfukoni v1.0.0', 'select_lang': 'Chagua Lugha',
      'scan_safe': 'Mfumo Uko Salama.', 'scan_init': 'Inaanza kukagua...',
      'scan_root': 'Inakagua Root Access...', 'scan_wifi': 'Inachambua WiFi...',
      'scan_app': 'Inathibitisha Programu...', 'scan_complete': 'Ukaguzi Umekamilika: Mfumo Salama',
      'wa_us': 'Tutumie WhatsApp', 'email_hq': 'Baruapepe Makao Makuu', 'faqs': 'Maswali', 'close': 'Funga', 'support_title': 'Msaada kwa Ajenti',
      'recruit_msg': '🕵️ Jiunge na Cyber Mfukoni!\n\nNinatumia programu hii kutambua matapeli na kulinda data zangu. Pakua hapa kulinda boma lako la kidijitali:\nhttps://cybermfukoni.co.ke/download',
    }
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeNewsTab(),      
    const ChonjoScreen(),     
    const MulikaScreen(),     
    const DigitalBomaScreen(),
    const UserProfileTab(),   
  ];

  @override
  void initState() {
    super.initState();
    _refreshSession();
  }

  void _refreshSession() {
    final settings = Hive.box('settings');
    settings.put('lastActiveTime', DateTime.now().toString());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        final theme = Theme.of(context);
        return Scaffold(
          // Uses Theme.scaffoldBackgroundColor (Dark)
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // Cyber Surface
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: theme.colorScheme.surface,
                  indicatorColor: theme.primaryColor.withOpacity(0.15),
                  labelTextStyle: MaterialStateProperty.all(
                    GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)
                  ),
                  iconTheme: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return IconThemeData(color: theme.primaryColor);
                    }
                    return const IconThemeData(color: Colors.grey);
                  }),
                ),
                child: NavigationBar(
                  height: 70,
                  elevation: 0,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  destinations: [
                    _buildNavItem(Icons.newspaper_rounded, Icons.newspaper_outlined, AppLocale.get('nav_news')),
                    _buildNavItem(Icons.verified_rounded, Icons.verified_outlined, AppLocale.get('nav_chonjo')),
                    _buildNavItem(Icons.radar_rounded, Icons.radar_outlined, AppLocale.get('nav_mulika')),
                    _buildNavItem(Icons.shield_rounded, Icons.shield_outlined, AppLocale.get('nav_boma')),
                    _buildNavItem(Icons.account_circle_rounded, Icons.account_circle_outlined, AppLocale.get('nav_profile')),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildNavItem(IconData selected, IconData unselected, String label) {
    return NavigationDestination(
      icon: Icon(unselected),
      selectedIcon: Icon(selected).animate().scale(duration: 200.ms),
      label: label,
    );
  }
}

// ---------------------------------------------------------
// TAB 1: REAL-TIME NEWS FEED
// ---------------------------------------------------------
class HomeNewsTab extends StatefulWidget {
  const HomeNewsTab({super.key});

  @override
  State<HomeNewsTab> createState() => _HomeNewsTabState();
}

class _HomeNewsTabState extends State<HomeNewsTab> {
  List<Map<String, dynamic>> newsList = [];
  final Box _newsBox = Hive.box('settings');
  Timer? _refreshTimer;
  bool _isLoading = false;
  String _userName = "Agent";

  final String apiKey = "09fdf54e4e4b4841bd28830f31bad3dd"; 

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initializeNewsSystem();
  }

  void _loadUser() {
    final email = Hive.box('settings').get('lastLoggedInUser');
    if (email != null) {
      final user = Hive.box('users').get(email);
      if (user != null) {
        setState(() {
          _userName = user['name'].toString().split(' ')[0]; 
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _initializeNewsSystem() {
    int? lastSavedMonth = _newsBox.get('news_month');
    int currentMonth = DateTime.now().month;

    if (lastSavedMonth != currentMonth) {
      _newsBox.put('news_data', <Map<String, dynamic>>[]); 
      _newsBox.put('news_month', currentMonth);
    }

    var storedNews = _newsBox.get('news_data');
    if (storedNews != null && storedNews.isNotEmpty) {
      try {
        newsList = List<Map<String, dynamic>>.from(
          storedNews.map((e) => Map<String, dynamic>.from(e))
        );
      } catch (e) {
        debugPrint("Cache Error: $e");
      }
      setState(() {});
    }

    _fetchRealNews();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchRealNews();
    });
  }

  Future<void> _fetchRealNews({bool isManual = false}) async {
    if (_isLoading) return;
    if (mounted) setState(() => _isLoading = true);
    
    try {
      String dateStr = DateTime.now().subtract(const Duration(hours: 48)).toIso8601String();

      final url = Uri.parse(
        "https://newsapi.org/v2/everything?"
        "q=(cybersecurity OR 'data breach' OR malware OR hacking OR ransomware OR 'kenya cyber')&" 
        "from=$dateStr&"      
        "sortBy=publishedAt&" 
        "language=en&"
        "apiKey=$apiKey"
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['articles'] != null) {
          List incoming = data['articles'];
          List<Map<String, dynamic>> cleanList = [];
          
          for (var article in incoming) {
            if (_isRelevant(article)) {
              cleanList.add({
                'title': article['title'] ?? "Cyber Alert",
                'description': article['description'] ?? "No details available. Tap to read full report.",
                'source': article['source']['name'] ?? "Unknown",
                'timeRaw': article['publishedAt'],
                'image': article['urlToImage'] ?? "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=1000", 
                'url': article['url'],
              });
            }
          }
          _mergeAndSaveNews(cleanList);
          
          if (isManual && mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocale.get('refresh_success')), backgroundColor: const Color(0xFF1B5E20))
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (isManual && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.get('conn_failed')), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isRelevant(dynamic article) {
    String title = (article['title'] ?? "").toString().toLowerCase();
    if (title.contains("cyber") || title.contains("hack") || title.contains("malware") || 
        title.contains("breach") || title.contains("ransomware") || title.contains("phish") ||
        title.contains("security") || title.contains("fraud") || title.contains("data")) {
      return true;
    }
    return false;
  }

  void _mergeAndSaveNews(List<Map<String, dynamic>> incoming) {
    bool hasNew = false;
    for (var item in incoming) {
      if (!newsList.any((e) => e['title'] == item['title'])) {
        newsList.add(item);
        hasNew = true;
      }
    }

    if (hasNew || incoming.isNotEmpty) {
      newsList.sort((a, b) => (b['timeRaw'] ?? "").compareTo(a['timeRaw'] ?? ""));
      if (newsList.length > 50) newsList = newsList.sublist(0, 50);
      _newsBox.put('news_data', newsList);
      if (mounted) setState(() {});
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return AppLocale.get('just_now');
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final diff = DateTime.now().difference(date);
      
      if (diff.inMinutes < 1) return AppLocale.get('just_now');
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ${AppLocale.get('ago')}";
      if (diff.inHours < 24) return "${diff.inHours}h ${AppLocale.get('ago')}";
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) { return AppLocale.get('recent'); }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("Launch Error: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open link. Browser not found."), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${AppLocale.get('welcome')} $_userName", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                    Row(
                      children: [
                        Text(AppLocale.get('live_feed'), style: GoogleFonts.poppins(color: theme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)), // Adjusted Size
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
                          .animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 800.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor, 
                    borderRadius: BorderRadius.circular(12), 
                    border: Border.all(color: Colors.white10)
                  ),
                  child: IconButton(
                    icon: _isLoading 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor))
                      : Icon(Icons.refresh, color: theme.primaryColor),
                    onPressed: () => _fetchRealNews(isManual: true),
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: newsList.isEmpty 
              ? Center(child: _isLoading 
                  ? CircularProgressIndicator(color: theme.primaryColor)
                  : Text(AppLocale.get('no_intel'), style: const TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final news = newsList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _launchURL(news['url']),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              news['image'],
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Container(
                                height: 160, color: Colors.grey.shade900, 
                                child: const Icon(Icons.broken_image, color: Colors.grey)
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4)
                                        ),
                                        child: Text(news['source'], style: TextStyle(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(_formatTime(news['timeRaw']), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    news['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    news['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// TAB 5: AGENT HQ (Fully Functional & Localized)
// ---------------------------------------------------------
class UserProfileTab extends StatefulWidget {
  const UserProfileTab({super.key});

  @override
  State<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab> {
  String _userName = "Agent";
  String _joinDate = "Unknown";
  String _language = "English";
  bool _alertsEnabled = true;
  
  String _scanStatus = "PENDING"; 
  String _scanMessage = "Last scan was 3 days ago.";
  Color _scanColor = Colors.orange;
  
  final Box _settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final email = _settingsBox.get('lastLoggedInUser');
    if (email != null) {
      final user = Hive.box('users').get(email);
      if (user != null) {
        setState(() {
          _userName = user['name'] ?? "Agent";
          _joinDate = user['joinedAt'] != null 
              ? DateFormat('MMM yyyy').format(DateTime.parse(user['joinedAt'])) 
              : "Unknown";
        });
      }
    }

    setState(() {
      _language = _settingsBox.get('language', defaultValue: "English");
      _alertsEnabled = _settingsBox.get('notifications', defaultValue: true);
    });
  }

  void _recruitAgent() async {
    final String message = AppLocale.get('recruit_msg');
    await Share.share(message, subject: "Cyber Mfukoni Invite");
  }

  void _runSecurityScan() async {
    if (_scanStatus == "SCANNING") return;

    setState(() {
      _scanStatus = "SCANNING";
      _scanColor = Colors.blue;
      _scanMessage = AppLocale.get('scan_init');
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _scanMessage = AppLocale.get('scan_root'));
    
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _scanMessage = AppLocale.get('scan_wifi'));

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _scanMessage = AppLocale.get('scan_app'));

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _scanStatus = "SAFE";
      _scanColor = Colors.green;
      _scanMessage = AppLocale.get('scan_safe');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocale.get('scan_complete')), backgroundColor: const Color(0xFF1B5E20))
    );
  }

  // --- HELPER: OPEN EXTERNAL URLS (FIXED) ---
  Future<void> _launchExternal(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      // Use externalApplication to allow opening other apps like WhatsApp/Gmail
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open app."), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocale.get('select_lang'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),
            _buildLanguageOption("English", "Default", "en"),
            const Divider(),
            _buildLanguageOption("Kiswahili", "Swahili", "sw"),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String langName, String sub, String code) {
    bool isSelected = _language == langName;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade200,
        child: Text(code.toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
      ),
      title: Text(langName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.black54)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20)) : null,
      onTap: () {
        setState(() => _language = langName);
        _settingsBox.put('language', langName);
        Navigator.pop(context);
      },
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(AppLocale.get('support_title'), style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: Text(AppLocale.get('wa_us'), style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launchExternal("https://wa.me/254700000000"); // Replace with valid number
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text(AppLocale.get('email_hq'), style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launchExternal("mailto:support@cybermfukoni.co.ke");
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer, color: Colors.orange),
              title: Text(AppLocale.get('faqs'), style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocale.get('close')))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor.withOpacity(0.4)]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: theme.primaryColor),
                boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]
              ),
              child: Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(image: AssetImage('assets/avatar.png'))
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.shield, color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(AppLocale.get('level'), style: GoogleFonts.sourceCodePro(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        Text("${AppLocale.get('active_since')} $_joinDate", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ).animate().scale(),

            const SizedBox(height: 30),

            Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _scanColor.withOpacity(0.5))
              ),
              child: Row(
                children: [
                  _scanStatus == "SCANNING" 
                    ? SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: _scanColor, strokeWidth: 3))
                    : Icon(_scanStatus == "SAFE" ? Icons.gpp_good : Icons.warning_amber_rounded, color: _scanColor, size: 30),
                  
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppLocale.get('device_status')}: $_scanStatus", style: TextStyle(fontWeight: FontWeight.bold, color: _scanColor)),
                        const SizedBox(height: 2),
                        Text(_scanMessage, style: TextStyle(fontSize: 12, color: Colors.grey[400]), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (_scanStatus != "SCANNING")
                    TextButton(
                      onPressed: _runSecurityScan, 
                      child: Text(AppLocale.get('scan_now'), style: TextStyle(color: theme.primaryColor))
                    )
                ],
              ),
            ),

            Text(AppLocale.get('preferences'), style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 10),
            
            _buildActionItem(context, Icons.language, AppLocale.get('language'), _language, _showLanguageSelector),
            
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(15)),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.notifications_active, color: theme.primaryColor),
                ),
                title: Text(AppLocale.get('alerts'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text(_alertsEnabled ? AppLocale.get('on') : AppLocale.get('off'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                activeColor: theme.primaryColor,
                value: _alertsEnabled,
                onChanged: (val) {
                  setState(() => _alertsEnabled = val);
                  _settingsBox.put('notifications', val);
                },
              ),
            ),

            const SizedBox(height: 20),
            Text(AppLocale.get('community'), style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 10),

            _buildActionItem(context, Icons.person_add, AppLocale.get('recruit'), AppLocale.get('share_app'), _recruitAgent),
            _buildActionItem(context, Icons.help_outline, AppLocale.get('help'), AppLocale.get('contact_hq'), _showSupportDialog),
            
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                   final settings = Hive.box('settings');
                   settings.delete('lastLoggedInUser');
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingScreen()), (route) => false);
                }, 
                icon: const Icon(Icons.power_settings_new),
                label: Text(AppLocale.get('logout')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(AppLocale.get('version'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: theme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}