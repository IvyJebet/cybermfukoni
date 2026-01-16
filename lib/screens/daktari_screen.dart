import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------
// DATA MODEL: INCIDENT PLAYBOOKS
// ---------------------------------------------------------
class IncidentStep {
  final String title;
  final String instruction;
  final String? actionLabel;
  final String? actionUrl;
  final IconData icon;

  IncidentStep({
    required this.title,
    required this.instruction,
    this.actionLabel,
    this.actionUrl,
    this.icon = Icons.info_outline,
  });
}

class IncidentScenario {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<IncidentStep> steps;

  IncidentScenario({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.steps,
  });
}

// ---------------------------------------------------------
// MAIN SCREEN: DAKTARI PANIC MODE
// ---------------------------------------------------------
class DaktariScreen extends StatefulWidget {
  const DaktariScreen({super.key});

  @override
  State<DaktariScreen> createState() => _DaktariScreenState();
}

class _DaktariScreenState extends State<DaktariScreen> {
  // Define our Kenyan Playbooks
  final List<IncidentScenario> _scenarios = [
    IncidentScenario(
      id: 'mpesa',
      name: 'Sent Money to Wrong Number',
      icon: Icons.money_off_csred_rounded,
      color: Colors.orange,
      steps: [
        IncidentStep(
          title: "STOP! Don't Delete SMS",
          instruction: "The M-PESA message contains the transaction ID required for reversal. Keep it safe.",
          icon: Icons.sms_failed,
        ),
        IncidentStep(
          title: "Reverse via SMS",
          instruction: "Forward the entire M-PESA message to 456 immediately.",
          actionLabel: "OPEN SMS APP",
          actionUrl: "sms:456",
          icon: Icons.send_to_mobile,
        ),
        IncidentStep(
          title: "Call Customer Care",
          instruction: "If the amount is large, call Safaricom immediately to hold the funds.",
          actionLabel: "CALL 456",
          actionUrl: "tel:456",
          icon: Icons.call,
        ),
      ],
    ),
    IncidentScenario(
      id: 'sim_swap',
      name: 'SIM Card Stopped Working',
      icon: Icons.sim_card_alert,
      color: Colors.red,
      steps: [
        IncidentStep(
          title: "Possible SIM Swap",
          instruction: "If your network bars disappeared suddenly, a hacker might have stolen your number.",
          icon: Icons.signal_cellular_off,
        ),
        IncidentStep(
          title: "Lock Your Accounts",
          instruction: "Call your bank immediately to freeze online banking. Your SIM is their key.",
          icon: Icons.account_balance,
        ),
        IncidentStep(
          title: "Contact Telco",
          instruction: "Use a friend's phone to call your service provider and suspend your line.",
          actionLabel: "CALL SAFARICOM (100)",
          actionUrl: "tel:100",
          icon: Icons.phone_locked,
        ),
      ],
    ),
    IncidentScenario(
      id: 'hack',
      name: 'Social Media Hacked',
      icon: Icons.lock_person,
      color: Colors.purpleAccent,
      steps: [
        IncidentStep(
          title: "Check Email Access",
          instruction: "Can you still access your email? If yes, reset your password immediately.",
          icon: Icons.email,
        ),
        IncidentStep(
          title: "Kill Active Sessions",
          instruction: "Go to Security Settings > 'Where you're logged in' and log out ALL devices.",
          icon: Icons.devices,
        ),
        IncidentStep(
          title: "Enable 2FA",
          instruction: "Turn on Two-Factor Authentication using an App (Google Authenticator), not SMS.",
          icon: Icons.security,
        ),
      ],
    ),
  ];

  IncidentScenario? _activeScenario;
  int _currentStep = 0;

  void _startScenario(IncidentScenario scenario) {
    setState(() {
      _activeScenario = scenario;
      _currentStep = 0;
    });
  }

  void _nextStep() {
    if (_activeScenario != null && _currentStep < _activeScenario!.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Finished
      setState(() => _activeScenario = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stay safe, Agent. Protocol Complete."), backgroundColor: Color(0xFF00E676))
      );
    }
  }

  void _launchAction(String? url) async {
    if (url == null) return;
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch action.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Daktari Response", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _activeScenario == null ? _buildScenarioGrid() : _buildWizard(),
    );
  }

  // SCREEN 1: THE MENU
  Widget _buildScenarioGrid() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "DON'T PANIC.",
          style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 10),
        Text(
          "Select the incident currently happening to you. We will guide you step-by-step.",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 30),
        ..._scenarios.map((s) => _buildScenarioCard(s)),
      ],
    );
  }

  Widget _buildScenarioCard(IncidentScenario scenario) {
    return GestureDetector(
      onTap: () => _startScenario(scenario),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: scenario.color.withOpacity(0.3)),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [scenario.color.withOpacity(0.1), const Color(0xFF161B22)]
          )
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: scenario.color)),
              child: Icon(scenario.icon, color: scenario.color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scenario.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text("Tap for immediate guidance", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: scenario.color, size: 16)
          ],
        ),
      ),
    ).animate().scale();
  }

  // SCREEN 2: THE WIZARD
  Widget _buildWizard() {
    final step = _activeScenario!.steps[_currentStep];
    final isLast = _currentStep == _activeScenario!.steps.length - 1;

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _activeScenario!.steps.length,
            backgroundColor: Colors.grey[800],
            color: _activeScenario!.color,
          ),
          const SizedBox(height: 40),
          
          // Icon Pulse
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _activeScenario!.color.withOpacity(0.1),
              border: Border.all(color: _activeScenario!.color, width: 2)
            ),
            child: Icon(step.icon, size: 60, color: _activeScenario!.color),
          ).animate(key: ValueKey(_currentStep)).scale(duration: 300.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 30),
          
          Text(
            "STEP ${_currentStep + 1}",
            style: GoogleFonts.sourceCodePro(color: _activeScenario!.color, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            step.instruction,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[300], height: 1.5),
          ),
          
          const Spacer(),

          // Action Button (Call/SMS)
          if (step.actionLabel != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15),
              child: ElevatedButton.icon(
                onPressed: () => _launchAction(step.actionUrl),
                icon: const Icon(Icons.touch_app),
                label: Text(step.actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

          // Navigation Buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text("BACK"),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeScenario!.color,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                  child: Text(isLast ? "FINISH" : "NEXT STEP"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}