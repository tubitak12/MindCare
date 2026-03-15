import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Günlük şifresini güvenli depoya kaydet
  Future<void> saveDiaryPassword(String password) async {
    await _secureStorage.write(key: 'diary_password', value: password);
  }

  // Günlük şifresini güvenli depodan al
  Future<String?> getDiaryPassword() async {
    return await _secureStorage.read(key: 'diary_password');
  }

  // Şifre ile metin şifrele
  String encryptText(String plainText, String password) {
    final key = Key.fromUtf8(password.padRight(32).substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    return encrypter.encrypt(plainText, iv: iv).base64;
  }

  // Şifre ile metin çöz
  String decryptText(String encryptedText, String password) {
    try {
      final key = Key.fromUtf8(password.padRight(32).substring(0, 32));
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));

      return encrypter.decrypt64(encryptedText, iv: iv);
    } catch (e) {
      return "Çözülemedi - Yanlış şifre";
    }
  }

  // Şifre doğrulama
  bool validatePassword(String enteredPassword, String savedPassword) {
    return enteredPassword == savedPassword;
  }
}
