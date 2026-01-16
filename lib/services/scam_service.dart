import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class ScamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'scam_intel_ke'; // The Master Database

  // 1. SANITIZE (Standardize Kenyan Numbers)
  String _sanitizeNumber(String raw) {
    String clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('07') || clean.startsWith('01')) {
      return '+254${clean.substring(1)}';
    } else if (clean.startsWith('254')) {
      return '+$clean';
    }
    return clean;
  }

  // 2. REPORT A SCAMMER (Crowdsourcing)
  Future<bool> reportNumber(String number, String category, String description) async {
    final String cleanNumber = _sanitizeNumber(number);
    final String reporterId = _getOrCreateUserId();
    
    try {
      // Create a specific report
      await _db.collection('reports').add({
        'target_number': cleanNumber,
        'category': category, // e.g., 'Wangiri', 'Fake M-PESA', 'Kamatia Chini'
        'description': description,
        'reporter_id': reporterId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the Master Aggregation (The "Blacklist")
      // We use SetOptions(merge: true) to create if not exists
      final docRef = _db.collection(_collection).doc(cleanNumber);
      
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          transaction.set(docRef, {
            'report_count': 1,
            'last_reported': FieldValue.serverTimestamp(),
            'categories': [category],
            'trust_score': 10, // Initial risk score
          });
        } else {
          int newCount = (snapshot.data()?['report_count'] ?? 0) + 1;
          transaction.update(docRef, {
            'report_count': newCount,
            'last_reported': FieldValue.serverTimestamp(),
            // Simple Algorithm: More reports = Higher Risk Score
            'trust_score': newCount * 10, 
          });
        }
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // 3. CHECK A NUMBER (The "Waze" Lookup)
  Future<Map<String, dynamic>> checkNumber(String number) async {
    final String cleanNumber = _sanitizeNumber(number);
    
    try {
      final doc = await _db.collection(_collection).doc(cleanNumber).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final int score = data['trust_score'] ?? 0;
        
        // INTERPRET THE SCORE
        String status = "SUSPICIOUS";
        if (score > 50) status = "DANGER"; // 5+ Reports
        if (score > 200) status = "BLACKLISTED"; // 20+ Reports
        
        return {
          'status': status,
          'reports': data['report_count'],
          'safe': false,
        };
      } else {
        return {'status': 'CLEAN', 'reports': 0, 'safe': true};
      }
    } catch (e) {
      return {'status': 'OFFLINE', 'reports': 0, 'safe': true};
    }
  }

  // Helper: Get a unique ID for the reporter to prevent spamming
  String _getOrCreateUserId() {
    var box = Hive.box('settings');
    if (!box.containsKey('reporter_uuid')) {
      box.put('reporter_uuid', const Uuid().v4());
    }
    return box.get('reporter_uuid');
  }
}