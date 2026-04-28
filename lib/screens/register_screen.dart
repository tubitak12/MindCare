import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'info_screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _authService = AuthService();

  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              onSurface: Color(0xFF064E3B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Şifreler eşleşmiyor!');
      return;
    }

    if (_birthDateController.text.isEmpty) {
      _showSnackBar('Doğum tarihi seçiniz!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final User? user = await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user == null) throw Exception('Kullanıcı oluşturulamadı');

      await _authService.updateDisplayName(user, _nameController.text.trim());

      if (!mounted) return;

      _showSnackBar('Kayıt başarılı! 🌿', isError: false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => InfoFlowScreen(
            userName: _nameController.text.trim(),
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Bu e-posta zaten kayıtlı';
          break;
        case 'weak-password':
          message = 'Şifre çok zayıf (en az 6 karakter)';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta';
          break;
        default:
          message = 'Kayıt başarısız: ${e.message}';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Bir hata oluştu');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
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
      appBar: AppBar(
        title: const Text(
          'Kayıt Ol',
          style: TextStyle(color: Color(0xFF064E3B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF10B981)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'MindCare ailesine katıl! ✨',
                  style: TextStyle(fontSize: 18, color: const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 30),

                // Ad Soyad
                TextFormField(
                  controller: _nameController,
                  validator: (v) => v == null || v.length < 3
                      ? 'Ad Soyad gerekli (min 3)'
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon:
                        Icon(Icons.person_outline, color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 16),

                // Doğum Tarihi
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _birthDateController,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Doğum tarihi gerekli'
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi',
                        prefixIcon: Icon(Icons.calendar_today_outlined,
                            color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // E-posta
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'E-posta gerekli';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Geçersiz e-posta';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure1,
                  validator: (v) => v == null || v.length < 6
                      ? 'Şifre en az 6 karakter'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF10B981)),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure1
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _isObscure1 = !_isObscure1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Şifre Tekrar
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isObscure2,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Şifre tekrarı gerekli' : null,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF10B981)),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure2
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _isObscure2 = !_isObscure2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF10B981))
                else
                  ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text('Kayıt Ol'),
                  ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Zaten hesabın var mı? Giriş Yap',
                    style: TextStyle(color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
