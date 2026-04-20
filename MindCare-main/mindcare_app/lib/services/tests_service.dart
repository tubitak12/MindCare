import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tüm testleri getir (Firestore'dan)
  Future<List<Map<String, dynamic>>> getAllTests() async {
    try {
      var snapshot = await _firestore.collection('tests').get();
      return snapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'subtitle': data['subtitle'] ?? '',
          'icon': data['icon'] ?? 'psychology',
          'color': data['color'] ?? '0xFF4A148C',
          'type': data['type'] ?? '',
          'questionCount': data['questionCount'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Belirli bir testin sorularını getir
  Future<List<Map<String, dynamic>>> getTestQuestions(String testId) async {
    try {
      var snapshot = await _firestore
          .collection('tests')
          .doc(testId)
          .collection('questions')
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'id': doc.id,
          'question': data['question'] ?? '',
          'options': List<String>.from(data['options'] ?? []),
          'order': data['order'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Test sonucunu kaydet
  Future<void> saveTestResult({
    required String testId,
    required String testName,
    required int score,
    required String level,
    required Map<String, dynamic> answers,
  }) async {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('test_results')
        .add({
      'testId': testId,
      'testName': testName,
      'score': score,
      'level': level,
      'answers': answers,
      'date': FieldValue.serverTimestamp(),
    });
  }

  // Kullanıcının test geçmişini getir
  Stream<QuerySnapshot> getUserTestResults() {
    String userId = _auth.currentUser?.uid ?? '';

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('test_results')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Test skorunu değerlendirme seviyesine çevir
  static String getAnxietyLevel(int score) {
    if (score <= 4) return 'Minimal Anksiyete';
    if (score <= 9) return 'Hafif Anksiyete';
    if (score <= 14) return 'Orta Anksiyete';
    return 'Şiddetli Anksiyete';
  }

  static String getDepressionLevel(int score) {
    if (score <= 4) return 'Minimal Depresyon';
    if (score <= 9) return 'Hafif Depresyon';
    if (score <= 14) return 'Orta Depresyon';
    if (score <= 19) return 'Orta-Şiddetli Depresyon';
    return 'Şiddetli Depresyon';
  }

  static String getStressLevel(int score) {
    if (score <= 13) return 'Düşük Stres';
    if (score <= 26) return 'Orta Stres';
    return 'Yüksek Stres';
  }

  static String getWellbeingLevel(int score) {
    if (score >= 70) return 'Yüksek İyi Olma Hali';
    if (score >= 50) return 'Orta İyi Olma Hali';
    return 'Düşük İyi Olma Hali';
  }
}
