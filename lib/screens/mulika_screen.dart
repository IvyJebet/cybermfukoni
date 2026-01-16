import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/scam_service.dart'; // Import the new Cloud Service

class MulikaScreen extends StatefulWidget {
  const MulikaScreen({super.key});

  @override
  State<MulikaScreen> createState() => _MulikaScreenState();
}

class _MulikaScreenState extends State<MulikaScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScamService _scamService = ScamService();
  
  // Analysis State
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  double _riskScore = 0.0;
  List<Map<String, dynamic>> _detectedFlags = [];

  // ---------------------------------------------------------
  // 1. CLOUD FEATURES (WAZE SEARCH)
  // ---------------------------------------------------------
  void _showLookupDialog() {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: BorderSide(color: Colors.white.withOpacity(0.1))
        ),
        title: Row(
          children: [
            const Icon(Icons.public, color: Color(0xFF00E676)),
            const SizedBox(width: 10),
            Text("Community Intel", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search the shared database to see if other Kenyans have flagged this number.", 
              style: TextStyle(color: Colors.grey[400], fontSize: 13)
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFF00E676),
              decoration: InputDecoration(
                hintText: "e.g., 07XX XXX XXX",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), 
                  borderSide: const BorderSide(color: Color(0xFF00E676))
                )
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676), 
              foregroundColor: Colors.black,
              elevation: 0
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if(searchController.text.isNotEmpty) {
                _performCloudCheck(searchController.text);
              }
            },
            child: const Text("SEARCH DATABASE"),
          )
        ],
      ),
    );
  }

  void _performCloudCheck(String number) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Checking Cyber Mfukoni Database..."), 
        backgroundColor: Color(0xFF161B22),
        duration: Duration(seconds: 1)
      )
    );
    
    final result = await _scamService.checkNumber(number);
    if (!mounted) return;
    
    _showResultBottomSheet(result['safe'], result['reports'], result['status']);
  }

  void _showResultBottomSheet(bool isSafe, int reports, String status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: isSafe ? const Color(0xFF00E676) : Colors.red),
          boxShadow: [
            BoxShadow(
              color: (isSafe ? const Color(0xFF00E676) : Colors.red).withOpacity(0.1), 
              blurRadius: 20
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSafe ? Icons.check_circle : Icons.warning, 
              size: 60, 
              color: isSafe ? const Color(0xFF00E676) : Colors.red
            ),
            const SizedBox(height: 15),
            Text(
              isSafe ? "NO REPORTS FOUND" : "⚠️ CAUTION DETECTED", 
              style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Text(
              isSafe 
                ? "This number hasn't been flagged yet. Stay vigilant." 
                : "This number has been reported $reports times by other agents.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 25),
            if (!isSafe)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: Text(
                    "THREAT LEVEL: $status", 
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1)
                  )
                ),
              )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 2. REPORT FEATURE (VISIBLE UI)
  // ---------------------------------------------------------
  void _showReportDialog() {
     final TextEditingController numController = TextEditingController();
     final TextEditingController descController = TextEditingController();
     
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: BorderSide(color: Colors.white.withOpacity(0.1))
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Report Threat", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Help protect other agents by flagging scam numbers.",
                style: TextStyle(color: Colors.grey[400], fontSize: 13)
              ),
              const SizedBox(height: 20),
              TextField(
                controller: numController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.red,
                decoration: const InputDecoration(
                  labelText: "Scammer's Number", 
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true, 
                  fillColor: Colors.black,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)
                  )
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.red,
                decoration: const InputDecoration(
                  labelText: "Description (e.g. Wangiri)", 
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true, 
                  fillColor: Colors.black,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)
                  )
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (numController.text.isNotEmpty) {
                _scamService.reportNumber(numController.text, "General", descController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Report Submitted. Thank you Agent! 🕵️"), 
                    backgroundColor: Color(0xFF00E676),
                    behavior: SnackBarBehavior.floating,
                  )
                );
              }
            },
            child: const Text("REPORT"),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 3. SCAM HEURISTICS (LOCAL AI)
  // ---------------------------------------------------------
  void _analyzeMessage() async {
    String text = _messageController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Paste a suspicious message first!"), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasAnalyzed = false;
      _detectedFlags.clear();
      _riskScore = 0;
    });

    await Future.delayed(const Duration(seconds: 2));

    List<Map<String, dynamic>> flags = [];
    double score = 0;

    // A. Fake Reversal
    if (RegExp(r'(tuma|send|reverse).{0,20}(kwa|to).{0,20}(namba|number|hii)', caseSensitive: false).hasMatch(text)) {
      score += 50;
      flags.add({
        "title": "Fake Reversal Attempt",
        "desc": "Scammers often send a fake M-PESA SMS first, then call shouting 'Tuma hiyo pesa mbio!'.",
        "icon": Icons.money_off,
        "color": Colors.red
      });
    }

    // B. Urgency
    if (RegExp(r'(immediately|urgent|blocked|suspended|deactivated|fungwa|24 hours)', caseSensitive: false).hasMatch(text)) {
      score += 30;
      flags.add({
        "title": "Panic Inducer",
        "desc": "Words like 'BLOCKED' or 'URGENT' are used to make you stop thinking.",
        "icon": Icons.timer_off,
        "color": Colors.orange
      });
    }

    // C. Wangiri
    if (RegExp(r'(call|dial|contact|piga|huduma).{0,20}(\+?254|07\d{8}|01\d{8})', caseSensitive: false).hasMatch(text)) {
      score += 40;
      flags.add({
        "title": "Suspicious Callback",
        "desc": "Safaricom and Banks will NEVER ask you to call a personal mobile number.",
        "icon": Icons.call_end,
        "color": Colors.redAccent
      });
    }

    // D. Free Money
    if (RegExp(r'(congratulations|winner|won|prize|ksh|cash|reward|promotion|mamili|shinda)', caseSensitive: false).hasMatch(text)) {
      score += 30;
      flags.add({
        "title": "The 'Free Money' Trap",
        "desc": "If you didn't enter a competition, you didn't win.",
        "icon": Icons.emoji_events,
        "color": Colors.purpleAccent
      });
    }

    // E. Links
    if (RegExp(r'(http|www|bit\.ly|tinyurl)', caseSensitive: false).hasMatch(text)) {
      score += 35;
      flags.add({
        "title": "Malicious Link Detected",
        "desc": "NEVER click links in SMS unless you are 100% sure.",
        "icon": Icons.link_off,
        "color": Colors.blueAccent
      });
    }

    // F. PIN/ID
    if (RegExp(r'(pin|password|id number|dob)', caseSensitive: false).hasMatch(text)) {
      score += 50;
      flags.add({
        "title": "Sensitive Data Request",
        "desc": "🚩 MAJOR RED FLAG: No legitimate agent will EVER ask for your PIN.",
        "icon": Icons.lock_open,
        "color": Colors.red
      });
    }

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
            IconButton(icon: const Icon(Icons.refresh, color: Colors.grey), onPressed: _reset)
        ],
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
                if (!_hasAnalyzed) ...[
                  // ---------------------------------------
                  // HEADER TEXT: ACTIVE DEFENSE
                  // ---------------------------------------
                  Text(
                    "ACTIVE DEFENSE", 
                    style: GoogleFonts.orbitron(color: const Color(0xFF00E676), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Verify suspicious numbers or report threats to alert other agents.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 25),

                  // ---------------------------------------
                  // DASHBOARD: INTEL & REPORT
                  // ---------------------------------------
                  Row(
                    children: [
                      // CARD 1: SEARCH (WAZE)
                      Expanded(
                        child: GestureDetector(
                          onTap: _showLookupDialog,
                          child: Container(
                            height: 140,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [const Color(0xFF00E676).withOpacity(0.1), const Color(0xFF161B22)]
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.public, color: Color(0xFF00E676), size: 28),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("CHECK", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text("Verify Number", style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // CARD 2: REPORT
                      Expanded(
                        child: GestureDetector(
                          onTap: _showReportDialog,
                          child: Container(
                            height: 140,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.red.withOpacity(0.1), const Color(0xFF161B22)]
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.campaign, color: Colors.red, size: 28),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("REPORT", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text("Flag Threat", style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 25),

                  // ---------------------------------------
                  // EXISTING: TEXT ANALYZER
                  // ---------------------------------------
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.message, color: Colors.grey, size: 20),
                            const SizedBox(width: 10),
                            Text("SMS Analyzer", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // --- NEW EXPLANATION TEXT ADDED HERE ---
                        const SizedBox(height: 8),
                        Text(
                          "Paste a suspicious message below to scan for known scam keywords, fake M-PESA codes, and phishing links.",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        // ----------------------------------------
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextField(
                            controller: _messageController,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            cursorColor: const Color(0xFF00E676),
                            decoration: InputDecoration(
                              hintText: "Paste suspicious text here...",
                              hintStyle: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isAnalyzing ? null : _analyzeMessage,
                            icon: _isAnalyzing 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                              : const Icon(Icons.radar),
                            label: Text(_isAnalyzing ? "SCANNING..." : "ANALYZE TEXT"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              foregroundColor: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],

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
                const Text("No Threats Detected", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text("Our scanners didn't find obvious keywords.", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEducationalCard(Map<String, dynamic> flag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: flag['color'], width: 4)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(flag['icon'], color: flag['color']),
        title: Text(flag['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[200])),
        iconColor: Colors.grey,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(flag['desc'], style: TextStyle(color: Colors.grey[400], height: 1.5, fontSize: 13)),
        ],
      ),
    ).animate().slideX(begin: 0.2, end: 0, duration: 400.ms);
  }
}