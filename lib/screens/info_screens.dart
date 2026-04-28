import 'package:flutter/material.dart';
import 'mood_selection_screen.dart';

class InfoFlowScreen extends StatefulWidget {
  final String userName;
  const InfoFlowScreen({required this.userName, super.key});

  @override
  State<InfoFlowScreen> createState() => _InfoFlowScreenState();
}

class _InfoFlowScreenState extends State<InfoFlowScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sayfa içeriği
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentPage == 0
                          ? _buildFirstPage()
                          : _buildSecondPage(),
                    ),

                    const SizedBox(height: 30),

                    // Navigasyon butonları
                    Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _currentPage = 0);
                                _animationController.reset();
                                _animationController.forward();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF10B981),
                                side:
                                    const BorderSide(color: Color(0xFF10B981)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text("Geri"),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 10),
                        Expanded(
                          flex: _currentPage == 0 ? 1 : 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              if (_currentPage == 0) {
                                setState(() => _currentPage = 1);
                                _animationController.reset();
                                _animationController.forward();
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MoodSelectionScreen(
                                      userName: widget.userName,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: Text(
                              _currentPage == 0 ? "İleri" : "Başlayalım! 🚀",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Column(
      key: const ValueKey(0),
      children: [
        const Text(
          "Size Nasıl Yardımcı Olabiliriz?",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF064E3B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          "İlgilendiğiniz alanları seçin",
          style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14),
        ),
        const SizedBox(height: 30),

        // İlgi alanları grid'i
        Wrap(
          spacing: 15,
          runSpacing: 15,
          alignment: WrapAlignment.center,
          children: [
            _buildInterestBox("😌", "Stres Yönetimi"),
            _buildInterestBox("😊", "Mutluluk"),
            _buildInterestBox("😴", "Uyku Kalitesi"),
            _buildInterestBox("🧘", "Meditasyon"),
            _buildInterestBox("💪", "Motivasyon"),
            _buildInterestBox("🌿", "Farkındalık"),
          ],
        ),

        const SizedBox(height: 20),

        // İlerleme göstergesi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Column(
      key: const ValueKey(1),
      children: [
        // Başarılı animasyonu
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 70,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        const Text(
          "Harika! Hazırsınız",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF064E3B),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            widget.userName,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Size özel kişiselleştirilmiş bir deneyim hazırladık. Ruh halinize uygun aktiviteler, testler ve daha fazlası sizi bekliyor.",
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFF6B7280), height: 1.5),
          ),
        ),

        const SizedBox(height: 20),

        // Özellik özeti
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureItem(Icons.self_improvement, "Meditasyon"),
            _buildFeatureItem(Icons.assignment, "Testler"),
            _buildFeatureItem(Icons.music_note, "Müzik"),
          ],
        ),

        const SizedBox(height: 20),

        // İlerleme göstergesi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInterestBox(String emoji, String text) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF064E3B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: 20),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
