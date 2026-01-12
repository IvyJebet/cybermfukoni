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
  // THE BRAIN: SCAM HEURISTICS ENGINE
  // ---------------------------------------------------------
  void _analyzeMessage() async {
    String text = _messageController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paste a message to analyze first."), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasAnalyzed = false;
      _detectedFlags.clear();
      _riskScore = 0;
    });

    // Simulate "Processing" time for effect
    await Future.delayed(const Duration(seconds: 2));

    // 1. ANALYSIS LOGIC
    List<Map<String, dynamic>> flags = [];
    double score = 0;

    // A. Urgency Triggers (Fear)
    if (RegExp(r'(immediately|urgent|blocked|suspended|deactivated|24 hours)', caseSensitive: false).hasMatch(text)) {
      score += 30;
      flags.add({
        "title": "Urgency Trigger",
        "desc": "Scammers use words like 'immediately' or 'blocked' to make you panic so you don't think clearly.",
        "icon": Icons.timer_off,
        "color": Colors.red
      });
    }

    // B. Call to Action (The Trap)
    if (RegExp(r'(call|dial|contact).{0,20}(\+?254|07\d{8})', caseSensitive: false).hasMatch(text)) {
      score += 40;
      flags.add({
        "title": "Suspicious Callback",
        "desc": "Legitimate companies (like Safaricom or Banks) rarely ask you to call a mobile number (07XX...). They use official lines.",
        "icon": Icons.call_end,
        "color": Colors.orange
      });
    }

    // C. Greed/Reward Triggers
    if (RegExp(r'(congratulations|winner|won|prize|ksh|cash|reward|promotion)', caseSensitive: false).hasMatch(text)) {
      score += 30;
      flags.add({
        "title": "Greed Trigger",
        "desc": "If it sounds too good to be true, it is. 'You have won' is the oldest trick in the book.",
        "icon": Icons.emoji_events,
        "color": Colors.purple
      });
    }

    // D. Link Analysis (Phishing)
    if (RegExp(r'(http|www|bit\.ly|tinyurl)', caseSensitive: false).hasMatch(text)) {
      score += 35;
      flags.add({
        "title": "Unknown Link",
        "desc": "Avoid clicking links in SMS. Banks and M-PESA do NOT send links to 'verify' accounts.",
        "icon": Icons.link_off,
        "color": Colors.blue
      });
    }

    // E. Secret Info Request
    if (RegExp(r'(pin|password|id number|dob)', caseSensitive: false).hasMatch(text)) {
      score += 50;
      flags.add({
        "title": "Sensitive Data Request",
        "desc": "NEVER share your PIN or Password via SMS/WhatsApp. No agent will ever ask for this.",
        "icon": Icons.lock_open,
        "color": Colors.red
      });
    }

    // 2. FINALIZE
    setState(() {
      _isAnalyzing = false;
      _hasAnalyzed = true;
      _detectedFlags = flags;
      // Cap score at 100, but allow 0 if nothing found
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Mint Green Theme
      appBar: AppBar(
        title: const Text("Mulika Analyzer", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1B5E20),
        actions: [
          if (_hasAnalyzed)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _reset)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. INPUT AREA
            if (!_hasAnalyzed) ...[
              const Text(
                "Anatomy of a Scam",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 10),
              const Text(
                "Paste any suspicious SMS, WhatsApp message, or Email below. We will dissect it to find the trap.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: "Paste message here...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeMessage,
                  icon: _isAnalyzing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.analytics_outlined),
                  label: Text(_isAnalyzing ? "Scanning..." : "Analyze Message"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                ),
              )
            ],

            // 2. RESULTS AREA
            if (_hasAnalyzed) ...[
              _buildRiskGauge(),
              const SizedBox(height: 20),
              
              if (_detectedFlags.isEmpty)
                _buildSafeCard()
              else
                ..._detectedFlags.map((flag) => _buildEducationalCard(flag)),
            ]
          ],
        ),
      ),
    );
  }

  // WIDGET: The "Speedometer" Risk Gauge
  Widget _buildRiskGauge() {
    Color riskColor = _riskScore > 70 ? Colors.red : (_riskScore > 30 ? Colors.orange : Colors.green);
    String riskLabel = _riskScore > 70 ? "HIGH RISK" : (_riskScore > 30 ? "SUSPICIOUS" : "LIKELY SAFE");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Text("THREAT LEVEL", style: GoogleFonts.oswald(color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100, height: 100,
                child: CircularProgressIndicator(
                  value: _riskScore / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(riskColor),
                ),
              ),
              Text(
                "${_riskScore.toInt()}%", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: riskColor)
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(riskLabel, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: riskColor)),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  // WIDGET: When no threats are found
  Widget _buildSafeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200)
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 40),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "No obvious triggers detected. However, always verify the sender manually.",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: flag['color'], width: 5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(flag['icon'], color: flag['color']),
              const SizedBox(width: 10),
              Text(
                flag['title'], 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: flag['color'])
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            flag['desc'],
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.2, end: 0, duration: 400.ms);
  }
}