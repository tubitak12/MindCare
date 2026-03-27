import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Bunu ekledik
import '../services/auth_service.dart';
import 'mood_selection_screen.dart';
import 'home_screen.dart';

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
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return;

        final String today = DateTime.now().toIso8601String().split('T')[0];
        final String? lastMoodDate = prefs.getString('last_mood_date');

        if (lastMoodDate == today) {
          // Bugün zaten mod seçilmiş, direkt ana sayfaya git (mesajsız)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: user.displayName ?? 'Kullanıcı',
                userEmoji: prefs.getString('last_emoji') ?? '😊',
                showWelcome: false,
              ),
            ),
          );
        } else {
          // Bugün mod seçilmemiş, mod ekranına git
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MoodSelectionScreen(
                userName: user.displayName ?? 'Kullanıcı',
              ),
            ),
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
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF72B01D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.spa_rounded, color: Color(0xFF72B01D), size: 100),
                const Text('MindCare', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                const SizedBox(height: 50),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}