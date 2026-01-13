import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MulikaScreen extends StatefulWidget {
  const MulikaScreen({super.key});

  @override
  State<MulikaScreen> createState() => _MulikaScreenState();
}

class _MulikaScreenState extends State<MulikaScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  // Analysis State
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  double _riskScore = 0.0; // 0 to 100
  List<Map<String, dynamic>> _detectedFlags = [];

  // ---------------------------------------------------------
  // THE BRAIN: SCAM HEURISTICS ENGINE (Kenyan Optimized)
  // ---------------------------------------------------------
  void _analyzeMessage() async {
    String text = _messageController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Paste a suspicious message first!"), 
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        )
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasAnalyzed = false;
      _detectedFlags.clear();
      _riskScore = 0;
    });

    // Simulate "Cyber Scanning" time
    await Future.delayed(const Duration(seconds: 2));

    // 1. ANALYSIS LOGIC
    List<Map<String, dynamic>> flags = [];
    double score = 0;

    // A. The "Kamatia Chini" (Fake Reversal)
    if (RegExp(r'(tuma|send|reverse).{0,20}(kwa|to).{0,20}(namba|number|hii)', caseSensitive: false).hasMatch(text)) {
      score += 50;
      flags.add({
        "title": "Fake Reversal Attempt",
        "desc": "Scammers often send a fake M-PESA SMS first, then call shouting 'Tuma hiyo pesa mbio!'. Always check your actual M-PESA balance first.",
        "icon": Icons.money_off,
        "color": Colors.red
      });
    }

    // B. Urgency Triggers (Fear Factor)
    if (RegExp(r'(immediately|urgent|blocked|suspended|deactivated|fungwa|24 hours)', caseSensitive: false).hasMatch(text)) {
      score += 30;
      flags.add({
        "title": "Panic Inducer",
        "desc": "Words like 'BLOCKED' or 'URGENT' are used to make you stop thinking. Real companies give you time to resolve issues.",
        "icon": Icons.timer_off,
        "color": Colors.orange
      });
    }

    // C. The "Call Me" Trap (Wangiri/Social Engineering)
    if (RegExp(r'(call|dial|contact|piga|huduma).{0,20}(\+?254|07\d{8}|01\d{8})', caseSensitive: false).hasMatch(text)) {
      score += 40;
      flags.add({
        "title": "Suspicious Callback",
        "desc": "Safaricom and Banks will NEVER ask you to call a personal mobile number (07xx...). They use official numbers (e.g., 100 or 0722000000).",
        "icon": Icons.call_end,
        "color": Colors.redAccent
      });
    }

    // D. Greed/Reward Triggers (Kamiti Special)
    if (RegExp(r'(congratulations|winner|won|prize|ksh|cash|reward|promotion|mamili|shinda)', caseSensitive: false).hasMatch(text)) {
      score += 30;
      flags.add({
        "title": "The 'Free Money' Trap",
        "desc": "If you didn't enter a competition, you didn't win. Legitimate lotteries don't ask for 'Registration Fees' to release winnings.",
        "icon": Icons.emoji_events,
        "color": Colors.purpleAccent
      });
    }

    // E. Link Analysis (Phishing)
    if (RegExp(r'(http|www|bit\.ly|tinyurl)', caseSensitive: false).hasMatch(text)) {
      score += 35;
      flags.add({
        "title": "Malicious Link Detected",
        "desc": "NEVER click links in SMS unless you are 100% sure. This could install malware or steal your banking password.",
        "icon": Icons.link_off,
        "color": Colors.blueAccent
      });
    }

    // F. Secret Info Request
    if (RegExp(r'(pin|password|id number|dob)', caseSensitive: false).hasMatch(text)) {
      score += 50;
      flags.add({
        "title": "Sensitive Data Request",
        "desc": "🚩 MAJOR RED FLAG: No legitimate agent will EVER ask for your PIN. End the conversation immediately.",
        "icon": Icons.lock_open,
        "color": Colors.red
      });
    }

    // 2. FINALIZE
    setState(() {
      _isAnalyzing = false;
      _hasAnalyzed = true;
      _detectedFlags = flags;
      _riskScore = flags.isEmpty ? 0 : score.clamp(10.0, 100.0);
    });
  }

  void _reset() {
    setState(() {
      _messageController.clear();
      _hasAnalyzed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shared Cyber Theme Background
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Mulika Analyzer", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_hasAnalyzed)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00E676)), 
              onPressed: _reset
            )
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF161B22)], // Cyber Dark Theme
          )
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. INPUT AREA
                if (!_hasAnalyzed) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.security, size: 50, color: Color(0xFF00E676)),
                        const SizedBox(height: 15),
                        Text(
                          "Paste Suspicious Text Here",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Our AI will scan for M-PESA fraud, fake promos, and phishing links.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        const SizedBox(height: 25),
                        
                        // High Contrast Input Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3), // Darker inner container
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)), // Subtle neon border
                          ),
                          child: TextField(
                            controller: _messageController,
                            maxLines: 6,
                            style: const TextStyle(color: Colors.white, fontSize: 15), // White text for visibility
                            cursorColor: const Color(0xFF00E676),
                            decoration: InputDecoration(
                              hintText: "e.g., 'Confused? Call this number to reverse transaction...'",
                              hintStyle: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeMessage,
                      icon: _isAnalyzing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                        : const Icon(Icons.radar),
                      label: Text(
                        _isAnalyzing ? "SCANNING PROTOCOLS..." : "ANALYZE THREAT",
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676), // Neon Green
                        foregroundColor: Colors.black, // Cyber Black Text
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        shadowColor: const Color(0xFF00E676).withOpacity(0.4),
                      ),
                    ),
                  )
                ],

                // 2. RESULTS AREA (Forensic Report Style)
                if (_hasAnalyzed) ...[
                  _buildRiskGauge(),
                  const SizedBox(height: 25),
                  
                  Text("INTEL REPORT:", style: GoogleFonts.sourceCodePro(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  if (_detectedFlags.isEmpty)
                    _buildSafeCard()
                  else
                    ..._detectedFlags.map((flag) => _buildEducationalCard(flag)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET: The "Speedometer" Risk Gauge
  Widget _buildRiskGauge() {
    Color riskColor = _riskScore > 70 ? Colors.red : (_riskScore > 30 ? Colors.orange : const Color(0xFF00E676));
    String riskLabel = _riskScore > 70 ? "CRITICAL THREAT" : (_riskScore > 30 ? "SUSPICIOUS" : "SAFE");

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: riskColor.withOpacity(0.1), blurRadius: 20)]
      ),
      child: Column(
        children: [
          Text("THREAT PROBABILITY", style: GoogleFonts.sourceCodePro(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: CircularProgressIndicator(
                  value: _riskScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade900,
                  valueColor: AlwaysStoppedAnimation(riskColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    "${_riskScore.toInt()}%", 
                    style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
            child: Text(riskLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: riskColor, letterSpacing: 1)),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  // WIDGET: When no threats are found
  Widget _buildSafeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3))
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: Color(0xFF00E676), size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "No Threats Detected",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "Our scanners didn't find obvious keywords. However, always remain vigilant.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // WIDGET: Educational Cards for each threat
  Widget _buildEducationalCard(Map<String, dynamic> flag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: flag['color'], width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)]
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(flag['icon'], color: flag['color']),
        title: Text(
          flag['title'], 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[200])
        ),
        iconColor: Colors.grey,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(
            flag['desc'],
            style: TextStyle(color: Colors.grey[400], height: 1.5, fontSize: 13),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.2, end: 0, duration: 400.ms);
  }
}