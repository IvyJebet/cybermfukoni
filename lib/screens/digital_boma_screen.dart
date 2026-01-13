import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class DigitalBomaScreen extends StatefulWidget {
  const DigitalBomaScreen({super.key});

  @override
  State<DigitalBomaScreen> createState() => _DigitalBomaScreenState();
}

class _DigitalBomaScreenState extends State<DigitalBomaScreen> {
  final TextEditingController _passController = TextEditingController();
  
  // State variables
  String _crackTimeDisplay = "WAITING FOR INPUT...";
  String _feedback = "System Idle.";
  double _score = 0; 
  Color _statusColor = Colors.grey;
  bool _hasInput = false;

  void _analyzePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _score = 0;
        _crackTimeDisplay = "WAITING FOR INPUT...";
        _feedback = "System Idle.";
        _statusColor = Colors.grey;
        _hasInput = false;
      });
      return;
    }

    // 1. Calculate Complexity
    int poolSize = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[A-Z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[0-9]').hasMatch(password)) poolSize += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) poolSize += 32;

    double entropy = password.length * (poolSize > 0 ? (log(poolSize) / log(2)) : 0);

    // 2. Calculate Time (100 Billion guesses/sec)
    double guesses = pow(2, entropy).toDouble();
    double secondsToCrack = guesses / 100000000000;

    // 3. Determine Status
    double calculatedScore;
    Color newColor;
    String feedbackMsg;

    if (entropy < 28) {
      calculatedScore = 0;
      newColor = const Color(0xFFFF5252); // Neon Red
      feedbackMsg = "CRITICAL: INSTANT CRACK";
    } else if (entropy < 40) {
      calculatedScore = 1;
      newColor = const Color(0xFFFFAB40); // Neon Orange
      feedbackMsg = "VULNERABLE: DICTIONARY ATTACK";
    } else if (entropy < 60) {
      calculatedScore = 2;
      newColor = const Color(0xFFFFD740); // Neon Yellow
      feedbackMsg = "WEAK: BRUTE FORCE POSSIBLE";
    } else if (entropy < 80) {
      calculatedScore = 3;
      newColor = const Color(0xFF40C4FF); // Neon Blue
      feedbackMsg = "SECURE: STANDARD PROTECTION";
    } else {
      calculatedScore = 4;
      newColor = const Color(0xFF00E676); // Neon Green
      feedbackMsg = "FORTIFIED: MILITARY GRADE";
    }

    // 4. Kenyan Specific Pattern Detection
    String lowerPass = password.toLowerCase();
    if (lowerPass.contains("password") || 
        lowerPass.contains("123456") || 
        lowerPass.contains("kenya") || 
        lowerPass.contains("mpesa") ||
        lowerPass.contains("safaricom")) {
      calculatedScore = 0;
      secondsToCrack = 0;
      newColor = const Color(0xFFFF5252);
      feedbackMsg = "DETECTED: COMMON PATTERN";
    }

    setState(() {
      _score = calculatedScore;
      _crackTimeDisplay = _formatTime(secondsToCrack);
      _feedback = feedbackMsg;
      _statusColor = newColor;
      _hasInput = true;
    });
  }

  String _formatTime(double seconds) {
    if (seconds < 0.0001) return "INSTANTLY";
    if (seconds < 60) return "${seconds.toStringAsFixed(2)} SECONDS";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(1)} MINUTES";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(1)} HOURS";
    if (seconds < 31536000) return "${(seconds / 86400).toStringAsFixed(1)} DAYS";
    if (seconds < 3153600000) return "${(seconds / 31536000).toStringAsFixed(1)} YEARS";
    return "CENTURIES";
  }

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // SHARED BACKGROUND (Dark Cyber Theme)
    // ---------------------------------------------------------
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Digital Boma", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
          )
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Icon(Icons.security, size: 50, color: _hasInput ? _statusColor : const Color(0xFF00E676))
                    .animate().fadeIn().scale(),
                const SizedBox(height: 10),
                Text(
                  "Fortress Analyzer",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Test your password strength against brute-force attacks.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 30),

                // High Contrast Input Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22), // Dark Card
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _hasInput ? _statusColor.withOpacity(0.5) : Colors.white24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: TextField(
                    controller: _passController,
                    onChanged: _analyzePassword,
                    obscureText: false,
                    style: GoogleFonts.sourceCodePro(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    cursorColor: const Color(0xFF00E676),
                    decoration: InputDecoration(
                      hintText: "Enter password to test...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
                      prefixIcon: Icon(Icons.vpn_key, color: _hasInput ? _statusColor : const Color(0xFF00E676)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      suffixIcon: _passController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _passController.clear();
                              _analyzePassword("");
                            },
                          ) 
                        : null
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // THE HACKER TERMINAL
                _buildHackerTerminal(),

                const SizedBox(height: 30),

                // Educational Section (Only if score is low)
                if (_hasInput && _score < 3) 
                  _buildEducationSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // PROFESSIONAL TERMINAL UI
  // ---------------------------------------------------------
  Widget _buildHackerTerminal() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Terminal Black
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasInput ? _statusColor.withOpacity(0.8) : Colors.white12, 
          width: 2
        ),
        boxShadow: [
          if (_hasInput)
            BoxShadow(
              color: _statusColor.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 2,
            )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background Grid Effect
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/matrix_bg.jpg', fit: BoxFit.cover, 
                  errorBuilder: (c, o, s) => Container() 
                ),
              ),
            ),
            
            // Terminal Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Terminal Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.terminal, color: _hasInput ? _statusColor : Colors.grey, size: 16),
                          const SizedBox(width: 8),
                          Text("BRUTE_FORCE_SIM_v4.2", style: GoogleFonts.sourceCodePro(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
                        ],
                      ),
                      // Blinking Dot
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: _hasInput ? _statusColor : Colors.grey,
                          shape: BoxShape.circle,
                          boxShadow: _hasInput ? [BoxShadow(color: _statusColor, blurRadius: 5)] : null
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 800.ms),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),

                  // 2. The Analysis Output
                  Text("> ANALYZING ENTROPY...", style: GoogleFonts.sourceCodePro(color: Colors.white30, fontSize: 12)),
                  const SizedBox(height: 5),
                  
                  // Big Time Display
                  Text(
                    _crackTimeDisplay,
                    style: GoogleFonts.sourceCodePro(
                      color: _hasInput ? _statusColor : Colors.white24,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: _hasInput ? [Shadow(color: _statusColor, blurRadius: 15)] : []
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 3. Status Grid
                  Row(
                    children: [
                      // Status Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("STATUS", style: GoogleFonts.sourceCodePro(color: Colors.white38, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text(
                                _feedback,
                                style: GoogleFonts.sourceCodePro(
                                  color: _hasInput ? Colors.white : Colors.white54, 
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Score Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: _hasInput ? _statusColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _hasInput ? _statusColor.withOpacity(0.3) : Colors.white10)
                        ),
                        child: Column(
                          children: [
                            Text("LEVEL", style: GoogleFonts.sourceCodePro(color: Colors.white38, fontSize: 10)),
                            const SizedBox(height: 4),
                            Text(
                              "${_score.toInt()}/4",
                              style: GoogleFonts.sourceCodePro(
                                color: _hasInput ? _statusColor : Colors.white54, 
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("STRENGTHEN DEFENSES:", style: GoogleFonts.oswald(color: Colors.grey, fontSize: 14, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        _buildTipCard(Icons.short_text, "Too Short?", "Length is critical. Aim for 12+ characters."),
        const SizedBox(height: 10),
        _buildTipCard(Icons.spellcheck, "Predictable?", "Avoid words like 'Kenya', 'Mpesa', or your name."),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildTipCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF00E676), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}