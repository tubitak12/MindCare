import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // SharedPreferences'i başlat
  Future<void> _initPrefs() async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
    }
  }

  // Günlük şifresini Firebase'e kaydet
  Future<void> saveDiaryPassword(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'diary_password': password}, SetOptions(merge: true));
  }

  // Günlük şifresini Firebase'den al
  Future<String?> getDiaryPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['diary_password'] as String?;
  }

  // Şifre ile metin şifrele
  String encryptText(String plainText, String password) {
    try {
      // Şifreyi 32 byte'a tamamla (AES-256 için)
      final keyString = password.padRight(32).substring(0, 32);
      final key = Key.fromUtf8(keyString);

      // Rastgele IV oluştur
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Şifrele ve IV'yi de ekleyerek döndür
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // IV'yi de şifreli metnin başına ekle (çözme için)
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      return plainText; // Hata durumunda orijinal metni döndür
    }
  }

  // Şifre ile metin çöz
  String decryptText(String encryptedText, String password) {
    try {
      // IV ve şifreli metni ayır
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        return "Geçersiz şifreli format";
      }

      final ivBase64 = parts[0];
      final encryptedBase64 = parts[1];

      // Şifreyi 32 byte'a tamamla
      final keyString = password.padRight(32).substring(0, 32);
      final key = Key.fromUtf8(keyString);
      final iv = IV.fromBase64(ivBase64);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      final decrypted =
          encrypter.decrypt(Encrypted.fromBase64(encryptedBase64), iv: iv);
      return decrypted;
    } catch (e) {
      return "🔒 Şifreli içerik (şifre hatalı veya bozuk veri)";
    }
  }

  // Şifre doğrulama
  bool validatePassword(String enteredPassword, String savedPassword) {
    return enteredPassword == savedPassword;
  }
}
