import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // SharedPreferences'i başlat
  Future<void> _initPrefs() async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
    }
  }

  // Günlük şifresini güvenli depoya kaydet
  Future<void> saveDiaryPassword(String password) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs!.setString('diary_password', password);
    } else {
      await _secureStorage.write(key: 'diary_password', value: password);
    }
  }

  // Günlük şifresini güvenli depodan al
  Future<String?> getDiaryPassword() async {
    if (kIsWeb) {
      await _initPrefs();
      return _prefs!.getString('diary_password');
    } else {
      return await _secureStorage.read(key: 'diary_password');
    }
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
