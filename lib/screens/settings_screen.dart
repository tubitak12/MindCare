import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  final String _selectedLanguage = 'Türkçe';
  bool _isPasswordResetLoading = false;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF10B981)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
          _buildProfileCard(user),
          const SizedBox(height: 25),
          _buildSettingsGroup('Tercihler', [
            _buildSwitchTile(
              'Bildirimler',
              'Günlük motivasyon mesajları',
              Icons.notifications_outlined,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Karanlık Mod',
              'Göz yorgunluğunu azaltın',
              Icons.dark_mode_outlined,
              _darkModeEnabled,
              (value) async {
                setState(() => _darkModeEnabled = value);
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDarkMode', value);
              },
            ),
            _buildLanguageTile(),
          ]),
          const SizedBox(height: 16),
          _buildSettingsGroup('Hesap Güvenliği', [
            _buildSettingsTile(
              Icons.lock_reset_rounded,
              'Şifre Yenileme',
              'E-postanıza bağlantı gönderir',
              _showPasswordChangeDialog,
            ),
            _buildSettingsTile(
              Icons.delete_forever_outlined,
              'Hesabı Kapat',
              'Verilerinizi kalıcı olarak siler',
              _showDeleteAccountDialog,
              isDestructive: true,
            ),
          ]),
          const SizedBox(height: 40),
          _buildLogoutButton(),
        ],
      ),
    ),
  ),
    );
  }

  Widget _buildProfileCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            radius: 30,
            child: Icon(Icons.person, color: Color(0xFF10B981), size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Kullanıcı',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? 'email@example.com',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note, color: Color(0xFF10B981)),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isPasswordResetLoading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Şifre Sıfırlama'),
          content: const Text(
              'E-posta adresinize sıfırlama bağlantısı gönderilsin mi?'),
          actions: [
            TextButton(
              onPressed: _isPasswordResetLoading ? null : () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: _isPasswordResetLoading
                  ? null
                  : () async {
                      final email = _authService.currentUser?.email;

                      // Email kontrolü
                      if (email == null || email.isEmpty) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen önce giriş yapınız!'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }

                      // Loading state başla
                      setDialogState(() => _isPasswordResetLoading = true);

                      try {
                        // Şifre sıfırlama e-postası gönder
                        await _authService.sendPasswordReset(email);

                        if (mounted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Sıfırlama bağlantısı $email adresine gönderildi! 📧'),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          });
                        }
                      } catch (e) {
                        // Hata durumu
                        if (mounted) {
                          setDialogState(() => _isPasswordResetLoading = false);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Hata: ${e.toString()}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          });
                        }
                      }

                      // Loading state kapat
                      if (mounted) {
                        setDialogState(() => _isPasswordResetLoading = false);
                      }
                    },
              child: _isPasswordResetLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF10B981)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF10B981),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Çıkış Yap',
            style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          await _authService.signOut();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.redAccent : const Color(0xFF10B981),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: const Color(0xFF6B7280)),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF10B981)),
      title: const Text('Uygulama Dili'),
      subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 12)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: const Color(0xFF6B7280)),
      onTap: () {},
    );
  }

  void _showEditProfileDialog() {
    final controller =
        TextEditingController(text: _authService.currentUser?.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final user = _authService.currentUser;
                if (user != null) {
                  await _authService.updateDisplayName(
                      user, controller.text.trim());
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {});
                      Navigator.pop(context);
                    });
                  }
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Evet, Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
