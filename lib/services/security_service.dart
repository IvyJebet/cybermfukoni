import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';

class SecurityService {
  // Singleton pattern to ensure only one security monitor runs
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Observable list of active threats
  final ValueNotifier<List<String>> currentThreats = ValueNotifier([]);

  // Check if device is safe
  bool get isSafe => currentThreats.value.isEmpty;

  // Initialize the Security Monitor
  Future<void> init() async {
    // 1. Configure Talsec (The Security Engine)
    final config = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.example.cybermfukoni',
        signingCertHashes: [
          // YOUR DEBUG SHA-256 HASH
          '29:11:3D:ED:CC:F1:81:C0:BB:DC:78:0F:D0:C4:75:C5:6E:D1:B1:DE:26:97:D0:5A:52:5A:E0:67:77:2A:24:2C', 
        ],
        // FIXED: Correct parameter name for Flutter package
        supportedStores: ['com.sec.android.app.samsungapps'],
      ),
      iosConfig: IOSConfig(
        bundleIds: ['com.example.cybermfukoni'],
        teamId: 'M768L65733', // Replace with real Team ID if you publish to App Store
      ),
      watcherMail: 'security@cybermfukoni.com', // Where to send reports (optional)
      isProd: kReleaseMode, // stricter checks in release mode
    );

    // 2. Define Callbacks (What happens when a threat is found)
    final callback = ThreatCallback(
      onAppIntegrity: () => _addThreat("App Tampering Detected"),
      onObfuscationIssues: () => _addThreat("Obfuscation Issues"),
      onDebug: () {
        // Only flag debugger in Release mode to avoid annoying you while coding
        if (kReleaseMode) _addThreat("Debugger Attached");
      },
      onDeviceBinding: () => _addThreat("Device Binding Failed"),
      onHooks: () => _addThreat("Hooking Framework (Frida/Xposed)"),
      onPrivilegedAccess: () => _addThreat("Root/Jailbreak Detected"),
      onSecureHardwareNotAvailable: () => _addThreat("Secure Hardware Missing"),
      onSimulator: () {
        if (kReleaseMode) _addThreat("Running on Simulator");
      },
      onUnofficialStore: () => _addThreat("Installed from Fake Store"),
    );

    // 3. Start Detection
    await Talsec.instance.start(config);
    Talsec.instance.attachListener(callback);
  }

  void _addThreat(String threat) {
    // Avoid duplicates
    if (!currentThreats.value.contains(threat)) {
      final List<String> updated = List.from(currentThreats.value)..add(threat);
      currentThreats.value = updated;
      debugPrint("🚨 SECURITY ALERT: $threat");
    }
  }
  
  // Helper to get a human-readable advice for a threat
  String getAdviceForThreat(String threat) {
    if (threat.contains("Root")) return "Your OS privileges are escalated. Banking apps are at high risk.";
    if (threat.contains("Hooking")) return "Hacking tools (Frida/Xposed) detected. Uninstall them immediately.";
    if (threat.contains("Debugger")) return "Someone is analyzing this app's memory.";
    if (threat.contains("Tampering")) return "This app has been modified. Download the official version.";
    return "Device integrity compromised.";
  }
}