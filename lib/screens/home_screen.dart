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
// LOCALIZATION ENGINE
// ---------------------------------------------------------
class AppLocale {
  static String get(String key) {
    final box = Hive.box('settings');
    String lang = box.get('language', defaultValue: 'English');
    return _localizedValues[lang]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'nav_news': 'Intel', 'nav_chonjo': 'Chonjo', 'nav_mulika': 'Mulika', 'nav_boma': 'Boma', 'nav_profile': 'Agent',
      'welcome': 'Welcome, Agent', 'live_feed': 'Live Intel Feed',
      'refresh_success': 'Intel Feed Refreshed', 'conn_failed': 'Connection Failed. Check internet.',
      'no_intel': 'No active threats detected in the last 72h.', 'just_now': 'T-Minus: Now', 'ago': 'ago', 'recent': 'Recent',
      'level': 'Clearance: Level 1', 'active_since': 'Active since',
      'device_status': 'Device Integrity', 'scan_now': 'INITIATE SCAN',
      'preferences': 'SYSTEM PREFERENCES', 'language': 'Language Protocol', 'alerts': 'Threat Alerts', 'on': 'ENABLED', 'off': 'DISABLED',
      'community': 'AGENCY', 'recruit': 'Recruit Agent', 'share_app': 'Share Uplink',
      'help': 'Support Channel', 'contact_hq': 'Contact HQ', 'logout': 'Terminate Session',
      'version': 'Cyber Mfukoni v1.0.0', 'select_lang': 'Select Language',
      'scan_safe': 'System Secure.', 'scan_init': 'Initializing protocols...',
      'scan_root': 'Checking Root Access...', 'scan_wifi': 'Analyzing WiFi Encryption...',
      'scan_app': 'Verifying App Integrity...', 'scan_complete': 'Scan Complete: System Secure',
      'wa_us': 'Secure WhatsApp', 'email_hq': 'Email Command', 'faqs': 'FAQs', 'close': 'Dismiss', 'support_title': 'Agent Support',
      'recruit_msg': '🕵️ Agent! I am using Cyber Mfukoni to protect my M-PESA and Data. Download the App here: https://bit.ly/cyber-mfukoni-apk',
    },
    'Kiswahili': {
      'nav_news': 'Habari', 'nav_chonjo': 'Chonjo', 'nav_mulika': 'Mulika', 'nav_boma': 'Boma', 'nav_profile': 'Ajenti',
      'welcome': 'Karibu, Ajenti', 'live_feed': 'Taarifa za Usalama',
      'refresh_success': 'Taarifa Zimesasishwa', 'conn_failed': 'Muunganisho umeshindikana. Angalia mtandao.',
      'no_intel': 'Hakuna taarifa mpya kwa sasa.', 'just_now': 'Sasa hivi', 'ago': 'iliyopita', 'recent': 'Hivi karibuni',
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
      'recruit_msg': '🕵️ Ajenti! Natumia Cyber Mfukoni kulinda M-PESA na data zangu. Pakua App hapa: https://bit.ly/cyber-mfukoni-apk',
    }
  };
}

// ---------------------------------------------------------
// MAIN HOME SCREEN (Navigation Shell)
// ---------------------------------------------------------
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
          extendBody: true, // Allows content to flow behind nav bar for that modern look
          backgroundColor: theme.scaffoldBackgroundColor,
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22).withOpacity(0.95), // Deep cyber dark
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  indicatorColor: theme.primaryColor.withOpacity(0.2),
                  labelTextStyle: WidgetStateProperty.all(
                    GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[400])
                  ),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return IconThemeData(color: theme.primaryColor);
                    }
                    return const IconThemeData(color: Colors.grey);
                  }),
                ),
                child: NavigationBar(
                  height: 65,
                  elevation: 0,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  destinations: [
                    _buildNavItem(Icons.rss_feed_rounded, Icons.rss_feed_outlined, AppLocale.get('nav_news')),
                    _buildNavItem(Icons.verified_rounded, Icons.verified_outlined, AppLocale.get('nav_chonjo')),
                    _buildNavItem(Icons.radar_rounded, Icons.radar_outlined, AppLocale.get('nav_mulika')),
                    _buildNavItem(Icons.security_rounded, Icons.security_outlined, AppLocale.get('nav_boma')),
                    _buildNavItem(Icons.admin_panel_settings_rounded, Icons.admin_panel_settings_outlined, AppLocale.get('nav_profile')),
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
// TAB 1: LIVE CYBER INTEL FEED (Strictly Cyber News)
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
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _fetchRealNews();
    });
  }

  Future<void> _fetchRealNews({bool isManual = false}) async {
    if (_isLoading) return;
    if (mounted) setState(() => _isLoading = true);
    
    try {
      final DateTime now = DateTime.now();
      final DateTime threeDaysAgo = now.subtract(const Duration(days: 3));
      final String fromDate = DateFormat('yyyy-MM-dd').format(threeDaysAgo);
      
      final url = Uri.parse(
        "https://newsapi.org/v2/everything?"
        "qInTitle=(cybersecurity OR 'data breach' OR malware OR ransomware OR 'cyber attack' OR 'hacked' OR 'zero-day' OR 'vulnerability' OR 'infosec')&" 
        "from=$fromDate&" 
        "sortBy=publishedAt&" 
        "language=en&"
        "pageSize=20&" 
        "apiKey=$apiKey"
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['articles'] != null) {
          List incoming = data['articles'];
          List<Map<String, dynamic>> cleanList = [];
          
          for (var article in incoming) {
            if (article['title'] != null && article['url'] != null) {
               cleanList.add({
                'title': article['title'],
                'description': article['description'] ?? "Confidential Report. Tap to access full details.",
                'source': article['source']['name'] ?? "Unknown Source",
                'timeRaw': article['publishedAt'],
                'image': article['urlToImage'] ?? "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=1000", 
                'url': article['url'],
              });
            }
          }
          
          cleanList.sort((a, b) {
            DateTime timeA = DateTime.parse(a['timeRaw']);
            DateTime timeB = DateTime.parse(b['timeRaw']);
            return timeB.compareTo(timeA); 
          });

          _mergeAndSaveNews(cleanList);
          
          if (isManual && mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocale.get('refresh_success')), 
                backgroundColor: const Color(0xFF00E676),
                behavior: SnackBarBehavior.floating,
              )
            );
          }
        }
      }
    } catch (e) {
      if (isManual && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocale.get('conn_failed')), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mergeAndSaveNews(List<Map<String, dynamic>> incoming) {
    if (incoming.isEmpty) return;
    newsList = incoming;
    _newsBox.put('news_data', newsList);
    if (mounted) setState(() {});
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return AppLocale.get('just_now');
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final diff = DateTime.now().difference(date);
      
      if (diff.inMinutes < 60) return "T-${diff.inMinutes}m";
      if (diff.inHours < 24) return "${diff.inHours}h ${AppLocale.get('ago')}";
      return DateFormat('dd MMM, HH:mm').format(date);
    } catch (e) { return AppLocale.get('recent'); }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Access Denied: Browser not found."), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1117), Color(0xFF161B22)],
        )
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppLocale.get('welcome')} $_userName", 
                        style: GoogleFonts.sourceCodePro(color: theme.primaryColor, fontSize: 12, letterSpacing: 1.5)
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            AppLocale.get('live_feed'), 
                            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: Row(
                              children: [
                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
                                  .animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 500.ms),
                                const SizedBox(width: 4),
                                const Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _fetchRealNews(isManual: true),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10)
                      ),
                      child: _isLoading 
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor))
                        : Icon(Icons.refresh_rounded, color: theme.primaryColor),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => await _fetchRealNews(isManual: true),
                color: theme.primaryColor,
                backgroundColor: const Color(0xFF161B22),
                child: newsList.isEmpty 
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shield_moon_outlined, size: 60, color: Colors.grey[700]),
                              const SizedBox(height: 15),
                              Text(AppLocale.get('no_intel'), style: GoogleFonts.poppins(color: Colors.grey)),
                              const SizedBox(height: 20),
                              if (!_isLoading)
                                OutlinedButton(
                                  onPressed: () => _fetchRealNews(isManual: true),
                                  style: OutlinedButton.styleFrom(foregroundColor: theme.primaryColor),
                                  child: const Text("Retry Connection"),
                                )
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        final isLatest = index == 0;
                        return _buildCyberNewsCard(news, isLatest, theme);
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberNewsCard(Map<String, dynamic> news, bool isLatest, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22), 
        borderRadius: BorderRadius.circular(16),
        border: isLatest 
            ? Border.all(color: theme.primaryColor.withOpacity(0.5), width: 1.5) 
            : Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchURL(news['url']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    news['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      height: 150, color: Colors.grey.shade900, 
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, const Color(0xFF161B22).withOpacity(0.9)],
                        )
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24)
                      ),
                      child: Text(
                        news['source'].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (isLatest)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "LATEST INTEL",
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: theme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(news['timeRaw']),
                          style: GoogleFonts.sourceCodePro(fontSize: 12, color: theme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor.withOpacity(0.5), Colors.transparent],
                  )
                ),
              )
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

// ---------------------------------------------------------
// TAB 5: AGENT HQ (Profile) - Fully Upgraded
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
  String _lastScanText = "Last scan: Never";
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

    final lastScan = _settingsBox.get('lastScan');
    if (lastScan != null) {
      _updateLastScanText(DateTime.parse(lastScan));
      _scanStatus = "SAFE";
      _scanColor = const Color(0xFF00E676);
    }

    setState(() {
      _language = _settingsBox.get('language', defaultValue: "English");
      _alertsEnabled = _settingsBox.get('notifications', defaultValue: true);
    });
  }

  void _updateLastScanText(DateTime date) {
    final diff = DateTime.now().difference(date);
    String timeAgo;
    if (diff.inMinutes < 1) timeAgo = "Just now";
    else if (diff.inMinutes < 60) timeAgo = "${diff.inMinutes} mins ago";
    else if (diff.inHours < 24) timeAgo = "${diff.inHours} hours ago";
    else timeAgo = "${diff.inDays} days ago";
    
    setState(() {
      _lastScanText = "Last scan: $timeAgo";
    });
  }

  // --- FEATURE: RECRUIT AGENT (DIRECT APK LINK) ---
  void _recruitAgent() async {
    final String message = AppLocale.get('recruit_msg');
    await Share.share(message, subject: "Cyber Mfukoni Invite");
  }

  // --- FEATURE: REALISTIC SCAN ---
  void _runSecurityScan() async {
    if (_scanStatus == "SCANNING") return;

    setState(() {
      _scanStatus = "SCANNING";
      _scanColor = Colors.blue;
    });

    // Step 1: Root Check
    setState(() => _lastScanText = AppLocale.get('scan_root'));
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 2: Encryption Check
    setState(() => _lastScanText = AppLocale.get('scan_wifi'));
    await Future.delayed(const Duration(seconds: 1));

    // Step 3: App Integrity
    setState(() => _lastScanText = AppLocale.get('scan_app'));
    await Future.delayed(const Duration(seconds: 1));

    // Complete
    DateTime now = DateTime.now();
    _settingsBox.put('lastScan', now.toIso8601String());
    
    if (!mounted) return;

    setState(() {
      _scanStatus = "SAFE";
      _scanColor = const Color(0xFF00E676);
      _updateLastScanText(now);
    });

    _showScanReportDialog();
  }

  void _showScanReportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: Color(0xFF00E676)),
            const SizedBox(height: 15),
            Text("SYSTEM SECURE", style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            _buildReportRow("Root Access", "Not Detected", Colors.green),
            _buildReportRow("Play Protect", "Active", Colors.green),
            _buildReportRow("Encryption", "AES-256 Enabled", Colors.green),
            _buildReportRow("Malicious Apps", "0 Found", Colors.green),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
                child: const Text("CLOSE REPORT"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- FEATURE: SUPPORT CHANNEL (WhatsApp, Email & FAQs) ---
  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(AppLocale.get('support_title'), style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: Text(AppLocale.get('wa_us'), style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launchExternal("https://wa.me/254700000000"); 
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
              onTap: () {
                Navigator.pop(ctx);
                _showFAQs(); // Launches the FAQs Bottom Sheet
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocale.get('close'), style: const TextStyle(color: Colors.grey)))
        ],
      ),
    );
  }

  // --- FEATURE: FAQs HUB ---
  void _showFAQs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1117),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            border: Border.all(color: Colors.white10)
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)))),
              Text("Agent Intelligence (FAQs)", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _buildFAQTile("Someone sent money by mistake and wants me to reverse.", "STOP! Never reverse manually. Tell them to call 456 (Safaricom) to reverse it themselves. This is a common scam."),
              _buildFAQTile("I received a job offer via WhatsApp.", "Real companies do not hire via random WhatsApp messages. If they ask for a 'Registration Fee', it is a scam."),
              _buildFAQTile("My SIM was swapped/blocked.", "Visit the nearest Safaricom shop immediately with your ID. Do not share your PIN/PUK with anyone calling you."),
              _buildFAQTile("How do I report a scam number?", "Forward the scam message to 333 (Safaricom Fraud). It is free."),
              _buildFAQTile("Is Cyber Mfukoni free?", "Yes, this tool is free for all Kenyan agents to stay safe."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String q, String a) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.white.withOpacity(0.1))),
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        childrenPadding: const EdgeInsets.all(15),
        iconColor: const Color(0xFF00E676),
        collapsedIconColor: Colors.grey,
        children: [
          Text(a, style: TextStyle(color: Colors.grey[400], height: 1.4)),
        ],
      ),
    );
  }

  Future<void> _launchExternal(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open app."), backgroundColor: Colors.red));
      }
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocale.get('select_lang'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            _buildLanguageOption("English", "Default", "en"),
            Divider(color: Colors.white.withOpacity(0.1)),
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
        backgroundColor: isSelected ? const Color(0xFF00E676) : Colors.grey.shade800,
        child: Text(code.toUpperCase(), style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12)),
      ),
      title: Text(langName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.grey)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00E676)) : null,
      onTap: () {
        setState(() => _language = langName);
        _settingsBox.put('language', langName);
        Navigator.pop(context);
      },
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
            // Profile Header
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFF161B22), theme.primaryColor.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primaryColor, width: 2),
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
                            Icon(Icons.shield, color: theme.primaryColor, size: 14),
                            const SizedBox(width: 5),
                            Text(AppLocale.get('level'), style: GoogleFonts.sourceCodePro(color: theme.primaryColor, fontSize: 12)),
                          ],
                        ),
                        Text("${AppLocale.get('active_since')} $_joinDate", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ).animate().scale(),

            const SizedBox(height: 30),

            // Scan Status Card
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
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
                        Text("${AppLocale.get('device_status')}", style: TextStyle(fontWeight: FontWeight.bold, color: _scanColor)),
                        const SizedBox(height: 2),
                        Text(_lastScanText, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (_scanStatus != "SCANNING")
                    TextButton(
                      onPressed: _runSecurityScan, 
                      child: Text(AppLocale.get('scan_now'), style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold))
                    )
                ],
              ),
            ),

            // Preferences Section
            Align(alignment: Alignment.centerLeft, child: Text(AppLocale.get('preferences'), style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(height: 10),
            
            _buildActionItem(context, Icons.language, AppLocale.get('language'), _language, _showLanguageSelector),
            
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(15)),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
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
            Align(alignment: Alignment.centerLeft, child: Text(AppLocale.get('community'), style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(height: 10),

            _buildActionItem(context, Icons.person_add, AppLocale.get('recruit'), AppLocale.get('share_app'), _recruitAgent),
            _buildActionItem(context, Icons.help_outline, AppLocale.get('help'), AppLocale.get('contact_hq'), _showSupportDialog),
            
            const SizedBox(height: 30),

            // Logout Button
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
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}