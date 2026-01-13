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

  // Kenyan-Centric Scenarios
  final List<ScamScenario> _scenarios = [
    ScamScenario(
      sender: "MPESA",
      content: "QK582... Confirmed. Ksh 2,500.00 sent to JOHN DOE 07XX.. New Balance: Ksh 4,500. Transaction Cost: Ksh 0.00.",
      type: ScamType.sms,
      isScam: false,
      explanation: "✅ SAFE: Official M-PESA messages come from 'MPESA' (Header), not a phone number. The format is correct.",
    ),
    ScamScenario(
      sender: "+254722000000",
      content: "M-PESA: You have received Ksh 45,000 from EQUITY BANK. New Bal: Ksh 45,300. DO NOT SHARE YOUR PIN WITH AGENT.",
      type: ScamType.sms,
      isScam: true,
      explanation: "🚨 SCAM: M-PESA messages NEVER come from a normal phone number like +2547... They must display 'MPESA'.",
    ),
    ScamScenario(
      sender: "Safaricom Promo",
      content: "Congratulations! You have won Ksh 100,000 in the Tubonge na Mamili promotion. Call 07XX... immediately to claim your prize!",
      type: ScamType.whatsapp,
      isScam: true,
      explanation: "🚨 SCAM: Safaricom will NEVER ask you to call a personal mobile number to claim a prize. They only call from 0722 000 000.",
    ),
    ScamScenario(
      sender: "HR Manager",
      content: "Job Offer: Data Entry Clerk needed urgently. Salary 30k/week. No interview needed. Click here to apply: bit.ly/secure-job-ke",
      type: ScamType.whatsapp,
      isScam: true,
      explanation: "🚨 SCAM: 'No interview' and 'High Salary' are major red flags. Legitimate companies don't hire via random WhatsApp links.",
    ),
    ScamScenario(
      sender: "EquitySupport",
      content: "Your account has been temporarily blocked due to suspicious activity. Visit https://equity-verify-ke.com to unlock.",
      type: ScamType.email,
      isScam: true,
      explanation: "🚨 PHISHING: Banks never send links to 'unlock' accounts. The URL 'equity-verify-ke.com' is FAKE. Check the domain carefully.",
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
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
    }

    try {
      RenderRepaintBoundary boundary = _licenseKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); 
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes, name: "CyberMfukoni_License_${DateTime.now().millisecondsSinceEpoch}");

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Badge Saved! Check your Photos."), backgroundColor: Color(0xFF00E676))
      );
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving badge."), backgroundColor: Colors.red)
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
          color: const Color(0xFF161B22), // Dark Cyber Card
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: isCorrect ? const Color(0xFF00E676).withOpacity(0.2) : Colors.red.withOpacity(0.2), blurRadius: 30)],
          border: Border.all(color: isCorrect ? const Color(0xFF00E676) : Colors.red, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.verified : Icons.warning_amber_rounded, 
              color: isCorrect ? const Color(0xFF00E676) : Colors.red, 
              size: 60
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 15),
            
            Text(
              isCorrect ? "Chonjo Kabisa! 😎" : "Wueh! Umechezwa. 😵", // Kenyan Slang
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isCorrect ? const Color(0xFF00E676).withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isCorrect ? const Color(0xFF00E676).withOpacity(0.3) : Colors.red.withOpacity(0.3))
              ),
              child: Text(
                _scenarios[_currentIndex].explanation,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300]),
              ),
            ),
            
            const SizedBox(height: 25),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? const Color(0xFF00E676) : Colors.red,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _nextCard(isCorrect);
                },
                child: const Text("NEXT INTEL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      )
    );
  }

  void _nextCard(bool wonRound) {
    setState(() {
      if (wonRound) {
        _score += 100;
      } else {
        _lives--;
      }
      
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
    // ---------------------------------------------------------
    // SHARED BACKGROUND (Dark Cyber Theme)
    // ---------------------------------------------------------
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1117), Color(0xFF161B22)],
        )
      ),
      child: SafeArea(
        child: Builder(builder: (context) {
          switch (_gameState) {
            case GameState.intro:
              return _buildIntroScreen();
            case GameState.playing:
              return _buildGameScreen();
            case GameState.gameOver:
              return _buildGameOverScreen();
          }
        }),
      ),
    );
  }

  // ---------------------------------------------------------
  // SCREEN 1: INTRO (Mission Briefing)
  // ---------------------------------------------------------
  Widget _buildIntroScreen() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cyber Avatar Pulse
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 160, width: 160,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E676).withOpacity(0.1)),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
              Container(
                height: 140, width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E676), width: 3),
                  image: const DecorationImage(image: AssetImage('assets/avatar.png'), fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          Text("AGENT STATUS: STANDBY", style: GoogleFonts.sourceCodePro(color: const Color(0xFF00E676), letterSpacing: 2)),
          
          const SizedBox(height: 10),

          Text(
            "Kaanga Chonjo!", 
            style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 20),
          
          Text(
            "Welcome to the Simulation. Your mission is to identify digital threats targeting the Kenyan cyberspace.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400], height: 1.6),
          ),
          
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(child: _instructionCard(Icons.swipe_left, Colors.red, "SCAM", "Swipe Left")),
              const SizedBox(width: 15),
              Expanded(child: _instructionCard(Icons.swipe_right, const Color(0xFF00E676), "LEGIT", "Swipe Right")),
            ],
          ).animate().slideY(begin: 0.5, end: 0, delay: 500.ms, curve: Curves.easeOut),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                elevation: 10,
                shadowColor: const Color(0xFF00E676).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              child: const Text("START SIMULATION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionCard(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SCREEN 2: GAMEPLAY (The Simulation)
  // ---------------------------------------------------------
  Widget _buildGameScreen() {
    final scenario = _scenarios[_currentIndex];
    
    return Column(
      children: [
        // HUD (Heads Up Display)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                child: Row(
                  children: [
                    const Icon(Icons.shield, color: Color(0xFF00E676), size: 16),
                    const SizedBox(width: 8),
                    Text("XP: $_score", style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              Row(
                children: List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    index < _lives ? Icons.favorite : Icons.favorite_border,
                    color: index < _lives ? Colors.redAccent : Colors.grey[800],
                    size: 20,
                  ),
                )),
              )
            ],
          ),
        ),

        // Main Card Area
        Expanded(
          child: Center(
            child: Dismissible(
              key: Key(scenario.content),
              background: _buildSwipeBg(Colors.green.withOpacity(0.8), Icons.check_circle, "LEGIT", Alignment.centerLeft),
              secondaryBackground: _buildSwipeBg(Colors.red.withOpacity(0.8), Icons.warning, "SCAM", Alignment.centerRight),
              confirmDismiss: (direction) async {
                bool userSaysScam = direction == DismissDirection.endToStart; 
                _handleSwipe(userSaysScam);
                return false; 
              },
              child: _buildRealisticCard(scenario),
            ),
          ),
        ),
        
        // Hint Text
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text("Swipe Cards to Classify Threat", style: GoogleFonts.sourceCodePro(color: Colors.grey[600], fontSize: 10)),
        )
      ],
    );
  }

  Widget _buildSwipeBg(Color color, IconData icon, String label, Alignment align) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          Text(label, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
        ],
      ),
    );
  }

  Widget _buildRealisticCard(ScamScenario scenario) {
    bool isWhatsApp = scenario.type == ScamType.whatsapp;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 480, // Taller for realism
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Deep Dark Mode BG
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        children: [
          // 1. Phone Header Simulation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isWhatsApp ? const Color(0xFF1F2C34) : const Color(0xFF2C2C2C), // WhatsApp Dark or SMS Dark
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[700],
                  child: Icon(isWhatsApp ? Icons.call : Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.sender, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isWhatsApp ? "business account" : "Mobile • 2 min ago", 
                        style: const TextStyle(fontSize: 11, color: Colors.grey)
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.grey[400])
              ],
            ),
          ),
          
          // 2. Message Body
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Wallpaper effect for WhatsApp
                image: isWhatsApp ? const DecorationImage(image: AssetImage('assets/matrix_bg.jpg'), fit: BoxFit.cover, opacity: 0.1) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isWhatsApp ? const Color(0xFF202C33) : const Color(0xFF303030),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.content,
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "10:42 AM", 
                            style: TextStyle(fontSize: 10, color: Colors.grey[400])
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Fake Input Area (Visual Only)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
               color: isWhatsApp ? const Color(0xFF1F2C34) : const Color(0xFF2C2C2C),
               borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25))
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.grey[400]),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10),
                    child: Text("Type a message", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 15),
                Icon(Icons.mic, color: isWhatsApp ? const Color(0xFF00E676) : Colors.grey[400]),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SCREEN 3: GAME OVER (License Issuance)
  // ---------------------------------------------------------
  Widget _buildGameOverScreen() {
    bool won = _score >= 300; 
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              won ? Icons.verified_user : Icons.gpp_bad, 
              size: 80, 
              color: won ? const Color(0xFF00E676) : Colors.red
            ).animate().scale(delay: 200.ms),

            const SizedBox(height: 20),
            
            Text(
              won ? "MISSION ACCOMPLISHED" : "MISSION FAILED",
              style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              won ? "You have mastered the art of detection. Here is your Cyber Mfukoni Badge." : "Your cyber awareness needs work. Try again agent.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
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
                    gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))]
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100, height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black, 
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
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
                            Text("CYBER DEFENDER", style: GoogleFonts.oswald(color: Colors.black54, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
                            Text(_userName.toUpperCase(), 
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)
                            ),
                            const Divider(color: Colors.black26, thickness: 2),
                            Text("ID: CM-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}", style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                              child: const Text("STATUS: CHONJO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
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
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                    child: const Text("TRAIN AGAIN"),
                  ),
                ),
                const SizedBox(width: 15),
                if (won)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveLicenseToGallery, 
                      icon: const Icon(Icons.download),
                      label: const Text("SAVE BADGE"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15)
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}