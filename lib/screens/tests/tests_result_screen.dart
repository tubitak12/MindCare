import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestsResultScreen extends StatefulWidget {
  final String testId;
  final String testName;
  final int score;
  final int maxScore;
  final Map<int, int> answers;
  final Color testColor;
  final String categoryId;

  const TestsResultScreen({
    super.key,
    required this.testId,
    required this.testName,
    required this.score,
    required this.maxScore,
    required this.answers,
    required this.testColor,
    required this.categoryId,
  });

  @override
  State<TestsResultScreen> createState() => _TestsResultScreenState();
}

class _TestsResultScreenState extends State<TestsResultScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSaving = false;

  final Color mintBg = const Color(0xFFF0FDF4);
  final Color mintCard = const Color(0xFFD1FAE5);
  final Color primaryGreen = const Color(0xFF10B981);
  final Color darkText = const Color(0xFF064E3B);

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    setState(() => _isSaving = true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final percentage = (widget.score / widget.maxScore) * 100;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('test_results')
            .add({
          'testId': widget.testId,
          'testName': widget.testName,
          'categoryId': widget.categoryId,
          'score': widget.score,
          'maxScore': widget.maxScore,
          'percentage': percentage,
          'date': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Hata: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  double get _percentage => (widget.score / widget.maxScore) * 100;

  String get _emoji {
    if (_percentage <= 25) return '🌸';
    if (_percentage <= 50) return '🌿';
    if (_percentage <= 75) return '💚';
    return '🫂';
  }

  String get _mainTitle {
    if (_percentage <= 25) return 'Harika bir başlangıç yapıyorsun!';
    if (_percentage <= 50) return 'Yolunda ilerliyorsun, farkındalık harika!';
    if (_percentage <= 75) return 'Kendinle ilgilenmek için harika bir adım!';
    return 'Bugün bir adım attın, bu çok değerli.';
  }

  String get _subMessage {
    if (_percentage <= 25) {
      return 'Zihnin şu an oldukça dengeli görünüyor. Bu güzel enerjini korumak için harika fırsatın var.';
    } else if (_percentage <= 50) {
      return 'Bazı konular zihnini biraz yormuş olabilir. Ama farkında olmak, iyileşmenin en önemli adımıdır.';
    } else if (_percentage <= 75) {
      return 'Bu aralar biraz yorgun hissediyor olabilirsin. Bu çok doğal ve herkesin yaşadığı bir şey.';
    } else {
      return 'Zorlu bir dönemden geçiyor olabilirsin. Lütfen unutma: Bu duygular geçici ve yalnız değilsin.';
    }
  }

  String get _categorySpecificMessage {
    switch (widget.categoryId) {
      case 'depression':
        return 'Depresyon, insanın enerjisini ve motivasyonunu etkileyebilir. Küçük adımlar büyük değişimler yaratır.';
      case 'anxiety':
        return 'Kaygı ve endişe, gelecekle ilgili düşüncelerden beslenir. Şimdiye odaklanmak için nefes egzersizleri harikadır.';
      case 'stress':
        return 'Stres, vücudunun sana "biraz yavaşla" dediği bir işarettir. Mola vermek pes etmek değildir.';
      case 'sleep':
        return 'Uyku, zihnin ve bedeninin kendini yenileme zamanıdır. Küçük uyku rutinleri büyük fark yaratır.';
      case 'self_esteem':
        return 'Kendine değer vermek, bir gecede olmaz. Ama bugün kendine söylediğin güzel bir söz bile iyileştirir.';
      case 'relationships':
        return 'İlişkiler zaman zaman yorucu olabilir. Kendinle olan ilişkin iyileştikçe, diğerleri de iyileşir.';
      default:
        return 'Kendinle ilgilenmek için ayırdığın her an, aslında kendine verdiğin en güzel hediyedir.';
    }
  }

  List<Map<String, dynamic>> get _actionCards {
    switch (widget.categoryId) {
      case 'depression':
        return [
          {
            'icon': Icons.directions_walk,
            'title': 'Küçük bir yürüyüş',
            'desc': '5 dakika bile yeterli',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.edit_note,
            'title': 'Duygularını yaz',
            'desc': 'İçini dökmek rahatlatır',
            'color': 0xFF8BC34A
          },
          {
            'icon': Icons.music_note,
            'title': 'Sevdiğin şarkı',
            'desc': 'Ruh halini değiştirir',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.people,
            'title': 'Birine seslen',
            'desc': 'Sadece "merhaba" bile iyidir',
            'color': 0xFF8BC34A
          },
        ];
      case 'anxiety':
        return [
          {
            'icon': Icons.air,
            'title': '4-7-8 nefes',
            'desc': '4 sn al, 7 sn tut, 8 sn ver',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.nature_people,
            'title': 'Doğada yürü',
            'desc': 'Yeşil ve toprak sakinleştirir',
            'color': 0xFF8BC34A
          },
          {
            'icon': Icons.local_cafe,
            'title': 'Bitki çayı',
            'desc': 'Kafeinsiz, huzurlu',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.spa,
            'title': 'Meditasyon',
            'desc': 'Sadece 3 dakika',
            'color': 0xFF8BC34A
          },
        ];
      case 'stress':
        return [
          {
            'icon': Icons.bedtime,
            'title': 'Erken uyu',
            'desc': 'Bugün biraz erken yat',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.free_breakfast,
            'title': 'Mola ver',
            'desc': 'Telefonu kapat, nefes al',
            'color': 0xFF8BC34A
          },
          {
            'icon': Icons.spa,
            'title': 'Meditasyon',
            'desc': 'Kafa dağıtmak için',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.headphones,
            'title': 'Rahatlama müziği',
            'desc': 'Doğa sesleri dinle',
            'color': 0xFF8BC34A
          },
        ];
      case 'sleep':
        return [
          {
            'icon': Icons.nightlight,
            'title': 'Ekran molası',
            'desc': 'Yatmadan 1 saat önce',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.hot_tub,
            'title': 'Ilık duş',
            'desc': 'Vücudu rahatlatır',
            'color': 0xFF8BC34A
          },
          {
            'icon': Icons.book,
            'title': 'Kitap oku',
            'desc': 'Kağıt kitap tercih et',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.spa,
            'title': 'Nefes egzersizi',
            'desc': 'Uyumadan hemen önce',
            'color': 0xFF8BC34A
          },
        ];
      default:
        return [
          {
            'icon': Icons.favorite,
            'title': 'Kendine iyi bak',
            'desc': 'Bugün kendine bir iyilik yap',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.self_improvement,
            'title': 'Kendine zaman ayır',
            'desc': 'Sadece sen ve sen',
            'color': 0xFF8BC34A
          },
          {
            'icon': Icons.air,
            'title': 'Derin nefes al',
            'desc': '5 kere derin nefes',
            'color': 0xFF10B981
          },
          {
            'icon': Icons.music_note,
            'title': 'Müzik dinle',
            'desc': 'Ruh haline uygun şarkı',
            'color': 0xFF8BC34A
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mintBg,
      appBar: AppBar(
        title: Text(
          widget.testName,
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EMOJI VE BAŞLIK
                  Row(
                    children: [
                      Text(_emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _mainTitle,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // YÜZDELİK ÇUBUK
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Şu anki durumun',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_percentage.toInt()}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _percentage / 100,
                            minHeight: 10,
                            backgroundColor: mintCard,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daha iyi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              'Şu an',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Harika',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SAMİMİ MESAJ
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mintCard),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _subMessage,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: darkText.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: primaryGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _categorySpecificMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: darkText.withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // "BUNLARI YAPMAYA NE DERSİN?"
                  Row(
                    children: [
                      Icon(Icons.emoji_emotions, color: primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Bunları yapmaya ne dersin?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // AKTİVİTE KARTLARI (TIKLANMAZ - SADECE GÖRSEL)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: _actionCards.length,
                    itemBuilder: (context, index) {
                      final card = _actionCards[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(card['color'] as int).withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                card['icon'] as IconData,
                                size: 32,
                                color: Color(card['color'] as int),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                card['title'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: darkText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card['desc'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // UMUT VEREN SÖZ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryGreen.withOpacity(0.1),
                          mintCard.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.format_quote,
                            size: 24, color: Color(0xFFFFA726)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Kendin için attığın her küçük adım, aslında dev bir sıçrayıştır. Bugün buradasın ve bu çok değerli.',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: darkText.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // BUTONLAR
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.refresh, color: primaryGreen),
                          label: Text(
                            'Tekrar Çöz',
                            style: TextStyle(color: primaryGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context, true),
                          icon: Icon(Icons.arrow_back, color: primaryGreen),
                          label: Text(
                            'Testlere Dön',
                            style: TextStyle(color: primaryGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      icon: const Icon(Icons.home),
                      label: const Text('Ana Sayfaya Dön'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
