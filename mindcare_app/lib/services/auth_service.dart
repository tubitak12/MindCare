import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kayıt Ol
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Kayıt Hatası: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Beklenmedik Kayıt Hatası: $e");
      return null;
    }
  }

  // Giriş Yap
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Giriş Hatası: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Beklenmedik Giriş Hatası: $e");
      return null;
    }
  }

  // Şifre Sıfırlama E-postası Gönder
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint("Şifre Sıfırlama Hatası: $e");
      rethrow;
    }
  }

  // Kullanıcı Adı Güncelleme
  Future<void> updateDisplayName(User user, String name) async {
    try {
      await user.updateDisplayName(name.trim());
      await user.reload();
    } catch (e) {
      debugPrint("İsim Güncelleme Hatası: $e");
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Çıkış Hatası: $e");
    }
  }
}
