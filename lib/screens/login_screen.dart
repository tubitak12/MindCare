import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'mood_selection_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        if (!mounted) return;

        final String today = DateTime.now().toIso8601String().split('T')[0];
        
        // Firebase'den last_mood_date kontrol et
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        final String? lastMoodDate = userDoc.data()?['last_mood_date'] as String?;
        final String? lastEmoji = userDoc.data()?['last_emoji'] as String?;

        if (lastMoodDate == today) {
          // Bugün zaten mod seçilmiş, direkt ana sayfaya git (mesajsız)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: user.displayName ?? 'Kullanıcı',
                userEmoji: lastEmoji ?? '😊',
                showWelcome: false,
              ),
            ),
            (route) => false,
          );
        } else {
          // Bugün mod seçilmemiş, mod ekranına git
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MoodSelectionScreen(
                userName: user.displayName ?? 'Kullanıcı',
              ),
            ),
            (route) => false,
          );
        }
      } else {
        _showSnackBar(context, 'E-posta veya şifre hatalı');
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, 'Giriş başarısız.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.spa_rounded, color: Color(0xFF10B981), size: 100),
                const Text('MindCare', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                const SizedBox(height: 50),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta gerekli';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Geçersiz e-posta';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gerekli';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                    child: const Text('Giriş Yap'),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        ),
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55)),
                        child: const Text('Hesabınız yoksa kayıt olun'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        ),
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55)),
                        child: const Text('Şifremi Unuttum'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}