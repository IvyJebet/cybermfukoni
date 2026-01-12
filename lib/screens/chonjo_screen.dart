import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gal/gal.dart'; // Modern gallery saver

// ---------------------------------------------------------
// 1. DATA MODELS
// ---------------------------------------------------------
enum ScamType { sms, whatsapp, email, call }
enum GameState { intro, playing, gameOver }

class ScamScenario {
  final String sender;
  final String content;
  final ScamType type;
  final bool isScam;
  final String explanation;

  ScamScenario({
    required this.sender,
    required this.content,
    required this.type,
    required this.isScam,
    required this.explanation,
  });
}

// ---------------------------------------------------------
// 2. MAIN SCREEN
// ---------------------------------------------------------
class ChonjoScreen extends StatefulWidget {
  const ChonjoScreen({super.key});

  @override
  State<ChonjoScreen> createState() => _ChonjoScreenState();
}

class _ChonjoScreenState extends State<ChonjoScreen> {
  GameState _gameState = GameState.intro;
  int _score = 0;
  int _lives = 3;
  int _currentIndex = 0;
  String _userName = "Authorized User";
  
  final GlobalKey _licenseKey = GlobalKey();

  final List<ScamScenario> _scenarios = [
    ScamScenario(
      sender: "MPESA",
      content: "QK582... Confirmed. Ksh 2,500.00 sent to JOHN DOE 07XX.. New Balance: Ksh 4,500. Transaction Cost: Ksh 0.00.",
      type: ScamType.sms,
      isScam: false,
      explanation: "Safe! This matches the official M-PESA format exactly. The sender ID is 'MPESA' (not a number).",
    ),
    ScamScenario(
      sender: "+254722000000",
      content: "M-PESA: You have received Ksh 45,000 from EQUITY BANK. New Bal: Ksh 45,300. DO NOT SHARE YOUR PIN.",
      type: ScamType.sms,
      isScam: true,
      explanation: "FAKE! Official M-PESA messages never come from a standard phone number like +2547... They come from 'MPESA'.",
    ),
    ScamScenario(
      sender: "Safaricom Promo",
      content: "Congratulations! You won Ksh 100,000 in Tubonge na Mamili. Call 07XX... to claim!",
      type: ScamType.whatsapp,
      isScam: true,
      explanation: "Scam! Safaricom will never ask you to call a personal number to claim a prize. They call you from 0722 000 000.",
    ),
    ScamScenario(
      sender: "HR Manager",
      content: "Job Offer: Data Entry Clerk. Salary 30k/week. No interview needed. Click: bit.ly/secure-job",
      type: ScamType.whatsapp,
      isScam: true,
      explanation: "Red Flag! High salary for no work and a generic link is a classic recruitment scam.",
    ),
     ScamScenario(
      sender: "EquitySupport",
      content: "Your account is blocked. Visit https://equity-verify-ke.com to unlock immediately.",
      type: ScamType.email,
      isScam: true,
      explanation: "Phishing! Banks never send links to 'unlock' accounts. The URL 'equity-verify-ke.com' is fake.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() {
    final settingsBox = Hive.box('settings');
    final usersBox = Hive.box('users');
    
    final email = settingsBox.get('lastLoggedInUser');
    if (email != null && usersBox.containsKey(email)) {
      final userData = usersBox.get(email);
      // Ensure 'name' exists in your user object
      // If user data is stored as Map<dynamic, dynamic>, cast it safely
      if (userData is Map) {
         setState(() {
          _userName = userData['name'] ?? "Authorized User";
        });
      }
    }
  }

  // ---------------------------------------------------------
  // LOGIC: Save to Gallery (Using Gal)
  // ---------------------------------------------------------
  Future<void> _saveLicenseToGallery() async {
    // 1. Check Permissions
    // Gal handles permissions automatically, but checking explicitly is safer
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
    }

    try {
      // 2. Capture Widget
      RenderRepaintBoundary boundary = _licenseKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Pixel ratio 3.0 ensures high resolution
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); 
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 3. Save
      await Gal.putImageBytes(pngBytes, name: "CyberMfukoni_License_${DateTime.now().millisecondsSinceEpoch}");

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("License saved to Photos!"), backgroundColor: Colors.green)
      );
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e"), backgroundColor: Colors.red)
      );
    }
  }

  // ---------------------------------------------------------
  // GAME LOGIC
  // ---------------------------------------------------------
  
  void _startGame() {
    setState(() => _gameState = GameState.playing);
  }

  void _handleSwipe(bool userSaysScam) {
    bool isActuallyScam = _scenarios[_currentIndex].isScam;
    bool isCorrect = (userSaysScam == isActuallyScam);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent, 
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 20)],
          border: Border.all(color: isCorrect ? Colors.green : Colors.red, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.verified : Icons.warning_amber_rounded, 
              color: isCorrect ? Colors.green : Colors.red, 
              size: 60
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 15),
            
            Text(
              isCorrect ? "Correct! You are Chonjo." : "Oops! That was a trap.",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF263238)),
            ),
            
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(
                _scenarios[_currentIndex].explanation,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ),
            
            const SizedBox(height: 25),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? const Color(0xFF1B5E20) : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _nextCard(isCorrect);
                },
                child: const Text("Next Scenario", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      )
    );
  }

  void _nextCard(bool wonRound) {
    setState(() {
      if (wonRound) _score += 100;
      else _lives--;
      
      if (_lives <= 0 || _currentIndex >= _scenarios.length - 1) {
        _gameState = GameState.gameOver;
      } else {
        _currentIndex++;
      }
    });
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _lives = 3;
      _gameState = GameState.intro;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_gameState) {
      case GameState.intro:
        return _buildIntroScreen();
      case GameState.playing:
        return _buildGameScreen();
      case GameState.gameOver:
        return _buildGameOverScreen();
    }
  }

  Widget _buildIntroScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Avatar
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1B5E20), width: 4),
                image: const DecorationImage(
                  image: AssetImage('assets/avatar.png'), 
                  fit: BoxFit.cover,
                ),
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack) 
            .then()
            .shake(hz: 3, curve: Curves.easeInOut), 
            
            const SizedBox(height: 30),
            
            Text(
              "Jambo! I'm Chonjo.", 
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 15),
            
            Text(
              "I am your Digital Bodyguard simulator. I will show you real-life messages.\n\nYour job is to spot the fakes.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF263238), height: 1.5),
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 40),
            
            Row(
              children: [
                Expanded(child: _instructionCard(Icons.swipe_left, Colors.red, "Swipe Left", "If it's a SCAM")),
                const SizedBox(width: 15),
                Expanded(child: _instructionCard(Icons.swipe_right, Colors.green, "Swipe Right", "If it's LEGIT")),
              ],
            ).animate().slideY(begin: 1, end: 0, delay: 1000.ms, curve: Curves.easeOut),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
                child: const Text("Let's Start Training", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _instructionCard(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    final scenario = _scenarios[_currentIndex];
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Chonjo Simulator", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1B5E20),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: const Icon(Icons.verified, color: Colors.amber),
                  label: Text("Score: $_score", style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFF1B5E20),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                Row(
                  children: List.generate(3, (index) => Icon(
                    index < _lives ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  )),
                )
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: Dismissible(
                key: Key(scenario.content),
                background: _buildSwipeBg(Colors.green, Icons.check_circle, "MARK SAFE (Legit)", Alignment.centerLeft),
                secondaryBackground: _buildSwipeBg(Colors.red, Icons.cancel, "REPORT SCAM (Fake)", Alignment.centerRight),
                confirmDismiss: (direction) async {
                  bool userSaysScam = direction == DismissDirection.endToStart; 
                  _handleSwipe(userSaysScam);
                  return false; 
                },
                child: _buildRealisticCard(scenario),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSwipeBg(Color color, IconData icon, String label, Alignment align) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildRealisticCard(ScamScenario scenario) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scenario.type == ScamType.whatsapp ? const Color(0xFF075E54) : const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    scenario.type == ScamType.sms ? Icons.sms : Icons.call, 
                    color: Colors.black54
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scenario.sender, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: scenario.type == ScamType.whatsapp ? Colors.white : Colors.black87)),
                    Text(scenario.type.name.toUpperCase(), style: TextStyle(fontSize: 10, color: scenario.type == ScamType.whatsapp ? Colors.white70 : Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  scenario.content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xFF37474F), height: 1.5),
                ),
              ),
            ),
          ),
          Container(
             padding: const EdgeInsets.all(15),
             width: double.infinity,
             decoration: BoxDecoration(
               color: Colors.grey.shade50,
               borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25))
             ),
             child: const Text("Swipe LEFT for Scam • RIGHT for Safe", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    bool won = _score >= 300; 
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                won ? Icons.workspace_premium : Icons.unpublished, 
                size: 80, 
                color: won ? Colors.amber : Colors.red
              ).animate().scale(delay: 200.ms),

              const SizedBox(height: 20),
              
              Text(
                won ? "Training Complete!" : "Mission Failed",
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
              ),
              
              const SizedBox(height: 10),
              
              Text(
                won ? "You have proven your skills. Here is your official Cyber Mfukoni License." : "You need more training to become an agent.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF455A64)),
              ),
              
              const SizedBox(height: 30),

              if (won) 
                RepaintBoundary(
                  key: _licenseKey,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 10))]
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100, height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white24, 
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              image: AssetImage('assets/avatar.png'), 
                              fit: BoxFit.cover
                            )
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("CYBER AGENT", style: GoogleFonts.oswald(color: Colors.white54, fontSize: 14, letterSpacing: 2)),
                              Text(_userName, 
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                              const Divider(color: Colors.white24),
                              Text("ID: CM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(5)),
                                child: const Text("STATUS: CHONJO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ).animate().flipH(duration: 800.ms),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _restartGame,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B5E20),
                        side: const BorderSide(color: Color(0xFF1B5E20)),
                        padding: const EdgeInsets.symmetric(vertical: 15)
                      ),
                      child: const Text("Train Again"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  if (won)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveLicenseToGallery, 
                        icon: const Icon(Icons.download),
                        label: const Text("Save Badge"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15)
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}