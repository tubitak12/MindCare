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
        final level = _getResultLevel();

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
          'level': level,
          'answers': widget.answers,
          'date': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Sonuç kaydedilirken hata: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _getResultLevel() {
    final percentage = (widget.score / widget.maxScore) * 100;

    switch (widget.categoryId) {
      case 'anxiety':
        if (widget.score <= 4) return 'Minimal Anksiyete';
        if (widget.score <= 9) return 'Hafif Anksiyete';
        if (widget.score <= 14) return 'Orta Anksiyete';
        return 'Şiddetli Anksiyete';

      case 'depression':
        if (widget.score <= 4) return 'Minimal Depresyon';
        if (widget.score <= 9) return 'Hafif Depresyon';
        if (widget.score <= 14) return 'Orta Depresyon';
        if (widget.score <= 19) return 'Orta-Şiddetli Depresyon';
        return 'Şiddetli Depresyon';

      case 'stress':
        if (widget.score <= 13) return 'Düşük Stres';
        if (widget.score <= 26) return 'Orta Stres';
        return 'Yüksek Stres';

      case 'wellbeing':
        if (percentage >= 70) return 'Yüksek İyi Olma Hali';
        if (percentage >= 50) return 'Orta İyi Olma Hali';
        return 'Düşük İyi Olma Hali';

      default:
        if (percentage >= 70) return 'Yüksek';
        if (percentage >= 50) return 'Orta';
        return 'Düşük';
    }
  }

  ResultData _getResultData() {
    switch (widget.categoryId) {
      case 'anxiety':
        return _getAnxietyResult();
      case 'depression':
        return _getDepressionResult();
      case 'stress':
        return _getStressResult();
      case 'wellbeing':
        return _getWellbeingResult();
      default:
        return _getDefaultResult();
    }
  }

  ResultData _getAnxietyResult() {
    if (widget.score <= 4) {
      return ResultData(
        level: 'Düşük Anksiyete',
        emoji: '🌟',
        mainMessage:
            'Harika bir ruh halindesiniz! Anksiyete belirtileriniz minimal düzeyde.',
        description:
            'Endişelerinizle başa çıkma konusunda iyi bir durumdasınız.',
        suggestions: const [
          '✨ Günlük tutmaya devam edin',
          '🧘 Haftada 2-3 kez meditasyon yapın',
          '🚶 Düzenli yürüyüşler yapın',
        ],
        activities: const ['Meditasyon', 'Yürüyüş', 'Günlük'],
        quote: 'Kendinle barışık olmak, dünyayla barışık olmanın ilk adımıdır.',
        color: const Color(0xFF10B981),
      );
    } else if (widget.score <= 9) {
      return ResultData(
        level: 'Hafif Anksiyete',
        emoji: '🌿',
        mainMessage: 'Hafif düzeyde anksiyete belirtileriniz var.',
        description: 'Zaman zaman endişelenmek insan doğasının bir parçasıdır.',
        suggestions: const [
          '🌬️ 4-7-8 nefes egzersizini deneyin',
          '💤 Uyku düzeninize dikkat edin',
          '🍵 Kafein tüketimini azaltın',
        ],
        activities: const ['4-7-8 Nefes', 'Kutu Nefesi', 'Doğa Sesleri'],
        quote: 'Endişe, bugünün gücünü yarının gölgesinde harcamaktır.',
        color: const Color(0xFF8BC34A),
      );
    } else if (widget.score <= 14) {
      return ResultData(
        level: 'Orta Anksiyete',
        emoji: '💚',
        mainMessage: 'Orta düzeyde anksiyete belirtileriniz var.',
        description: 'Bu dönemde kendinize nazik olun.',
        suggestions: const [
          '🧘‍♀️ Günlük 10 dakika meditasyon yapın',
          '📞 Güvendiğiniz biriyle konuşun',
          '🏃 Düzenli egzersiz yapın',
        ],
        activities: const ['Meditasyon', 'Nefes Egzersizleri', 'Günlük'],
        quote: 'En karanlık gece bile sona erecek ve güneş doğacak.',
        color: const Color(0xFFFFA726),
      );
    } else {
      return ResultData(
        level: 'Yüksek Anksiyete',
        emoji: '🤗',
        mainMessage: 'Yüksek düzeyde anksiyete belirtileriniz var.',
        description:
            'Yalnız değilsiniz. Profesyonel destek almak önemli bir adımdır.',
        suggestions: const [
          '📞 Psikolojik Destek Hattı: 183',
          '👨‍⚕️ Bir uzmandan randevu alın',
          '🧘‍♀️ Günlük rahatlama egzersizleri yapın',
        ],
        activities: const [
          'Derin Nefes',
          'Profesyonel Destek',
          'Rutin Oluşturma'
        ],
        quote: 'Yardım istemek, güçlü olmanın en cesur yoludur.',
        color: const Color(0xFFEF5350),
      );
    }
  }

  ResultData _getDepressionResult() {
    if (widget.score <= 4) {
      return ResultData(
        level: 'Minimal Depresyon',
        emoji: '🌈',
        mainMessage: 'Depresyon belirtileriniz minimal düzeyde.',
        description: 'Pozitif enerjinizi korumak için yapabilecekleriniz var.',
        suggestions: const [
          '✨ Her gün minnettar olduğunuz 3 şeyi yazın',
          '🌟 Sevdiğiniz insanlarla vakit geçirin',
          '🎨 Yeni bir hobi edinin',
        ],
        activities: const ['Günlük', 'Meditasyon', 'Sesli Kitap'],
        quote: 'Mutluluk bir yolculuktur, varış noktası değil.',
        color: const Color(0xFF10B981),
      );
    } else if (widget.score <= 9) {
      return ResultData(
        level: 'Hafif Depresyon',
        emoji: '🌻',
        mainMessage: 'Hafif düzeyde depresyon belirtileriniz var.',
        description: 'Duygularınızı kabul edin ve kendinize şefkat gösterin.',
        suggestions: const [
          '☀️ Her sabah güneş ışığında 15 dk yürüyüş',
          '📖 İlham verici kitaplar okuyun',
          '🎵 Neşeli müzikler dinleyin',
        ],
        activities: const ['Yürüyüş', 'Motivasyon Sesleri', 'Günlük'],
        quote: 'Küçük adımlar, büyük değişimlerin başlangıcıdır.',
        color: const Color(0xFF8BC34A),
      );
    } else if (widget.score <= 14) {
      return ResultData(
        level: 'Orta Depresyon',
        emoji: '💚',
        mainMessage: 'Orta düzeyde depresyon belirtileriniz var.',
        description: 'Bu süreçte yalnız olmadığınızı unutmayın.',
        suggestions: const [
          '📞 Güvendiğiniz biriyle konuşun',
          '🧘‍♀️ Düzenli meditasyon yapın',
          '🍽️ Düzenli ve sağlıklı beslenin',
        ],
        activities: const ['Meditasyon', 'Nefes Egzersizleri', 'Günlük'],
        quote:
            'Karanlık ne kadar derin olursa olsun, ışık her zaman geri döner.',
        color: const Color(0xFFFFA726),
      );
    } else if (widget.score <= 19) {
      return ResultData(
        level: 'Orta-Şiddetli Depresyon',
        emoji: '🤗',
        mainMessage: 'Orta-şiddetli düzeyde depresyon belirtileriniz var.',
        description: 'İyileşmek mümkün. Lütfen kendinize zaman tanıyın.',
        suggestions: const [
          '👨‍⚕️ Bir uzmandan randevu alın',
          '📞 Psikolojik Destek Hattı: 183',
          '👥 Destek gruplarına katılın',
        ],
        activities: const ['Profesyonel Destek', 'Meditasyon', 'Nefes'],
        quote: 'Yardım istemek, iyileşmenin en cesur adımıdır.',
        color: const Color(0xFFEF5350),
      );
    } else {
      return ResultData(
        level: 'Şiddetli Depresyon',
        emoji: '🫂',
        mainMessage: 'Şiddetli düzeyde depresyon belirtileriniz var.',
        description:
            'Yalnız değilsiniz. Profesyonel yardım almak hayat kurtarabilir.',
        suggestions: const [
          '🚨 ACİL DURUM: 112',
          '📞 Psikolojik Destek Hattı: 183',
          '🏥 En yakın hastanenin psikiyatri servisine başvurun',
        ],
        activities: const [
          'Acil Destek',
          'Profesyonel Yardım',
          'Kriz Yönetimi'
        ],
        quote: 'Hayat değerlidir, yardım eli her zaman uzanır.',
        color: const Color(0xFFD32F2F),
      );
    }
  }

  ResultData _getStressResult() {
    if (widget.score <= 13) {
      return ResultData(
        level: 'Düşük Stres',
        emoji: '😌',
        mainMessage: 'Stres seviyeniz düşük! Bu harika bir durum.',
        description: 'Stres yönetiminde başarılısınız.',
        suggestions: const [
          '✨ Mevcut rutininizi koruyun',
          '🧘 Haftada 1-2 kez meditasyon yapın',
          '📚 Yeni şeyler öğrenmeye devam edin',
        ],
        activities: const ['Meditasyon', 'Yürüyüş', 'Kitap Okuma'],
        quote: 'Denge, hayatın en güzel halidir.',
        color: const Color(0xFF10B981),
      );
    } else if (widget.score <= 26) {
      return ResultData(
        level: 'Orta Stres',
        emoji: '🌊',
        mainMessage: 'Orta düzeyde stres altındasınız.',
        description: 'Stres hayatın doğal bir parçasıdır.',
        suggestions: const [
          '🌬️ Nefes egzersizlerini günlük rutininize ekleyin',
          '🏃 Haftada 3-4 kez egzersiz yapın',
          '💤 Uyku düzeninize dikkat edin',
        ],
        activities: const ['Kutu Nefesi', 'Doğa Sesleri', 'Yürüyüş'],
        quote: 'Stres, hayatın tadını çıkarmayı unuttuğumuzda ortaya çıkar.',
        color: const Color(0xFFFFA726),
      );
    } else {
      return ResultData(
        level: 'Yüksek Stres',
        emoji: '💪',
        mainMessage: 'Yüksek düzeyde stres altındasınız.',
        description: 'Sürekli yüksek stres sağlığınızı etkileyebilir.',
        suggestions: const [
          '🧘‍♀️ Günlük 15 dakika meditasyon',
          '🚶 Doğada vakit geçirin',
          '👨‍⚕️ Stres yönetimi eğitimi alın',
        ],
        activities: const ['Meditasyon', 'Nefes Egzersizleri', 'Doğa Yürüyüşü'],
        quote: 'Mola vermek, pes etmek değildir.',
        color: const Color(0xFFEF5350),
      );
    }
  }

  ResultData _getWellbeingResult() {
    final percentage = (widget.score / widget.maxScore) * 100;

    if (percentage >= 70) {
      return ResultData(
        level: 'Yüksek İyi Olma Hali',
        emoji: '🌟',
        mainMessage: 'İyi olma haliniz yüksek seviyede!',
        description: 'Hayatınızda dengeyi yakalamışsınız.',
        suggestions: const [
          '✨ Deneyimlerinizi başkalarıyla paylaşın',
          '🤝 İhtiyacı olanlara destek olun',
          '🎯 Yeni hedefler belirleyin',
        ],
        activities: const ['Meditasyon', 'Günlük', 'Motivasyon'],
        quote: 'İyilik, paylaştıkça çoğalır.',
        color: const Color(0xFF10B981),
      );
    } else if (percentage >= 50) {
      return ResultData(
        level: 'Orta İyi Olma Hali',
        emoji: '🌿',
        mainMessage: 'Orta düzeyde iyi olma halindesiniz.',
        description:
            'Kendinizi daha iyi hissetmek için yapabilecekleriniz var.',
        suggestions: const [
          '🧘 Günlük meditasyon pratiği ekleyin',
          '📖 Kişisel gelişim kitapları okuyun',
          '🎨 Yeni bir hobi edinin',
        ],
        activities: const ['Meditasyon', 'Yürüyüş', 'Kitap Okuma'],
        quote: 'Küçük adımlar, büyük değişimler yaratır.',
        color: const Color(0xFF8BC34A),
      );
    } else {
      return ResultData(
        level: 'Düşük İyi Olma Hali',
        emoji: '🤗',
        mainMessage: 'İyi olma haliniz düşük seviyede.',
        description: 'Herkes zor dönemler geçirebilir.',
        suggestions: const [
          '🧘‍♀️ Günlük rahatlama egzersizleri',
          '📞 Sevdiğiniz biriyle konuşun',
          '🚶 Doğada vakit geçirin',
        ],
        activities: const ['Meditasyon', 'Nefes', 'Günlük'],
        quote: 'En karanlık an, şafağın habercisidir.',
        color: const Color(0xFFFFA726),
      );
    }
  }

  ResultData _getDefaultResult() {
    final percentage = (widget.score / widget.maxScore) * 100;
    return ResultData(
      level:
          percentage >= 70 ? 'Yüksek' : (percentage >= 50 ? 'Orta' : 'Düşük'),
      emoji: '📊',
      mainMessage: 'Testinizi tamamladınız.',
      description: 'Sonuçlarınız değerlendirildi.',
      suggestions: const [
        '🧘 Düzenli meditasyon yapın',
        '📝 Günlük tutun',
        '🚶 Doğada yürüyüş yapın',
      ],
      activities: const ['Meditasyon', 'Günlük', 'Yürüyüş'],
      quote: 'Kendini tanımak, iyileşmenin ilk adımıdır.',
      color: const Color(0xFF10B981),
    );
  }

  void _showActivityDialog(String activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.self_improvement, color: widget.testColor),
            const SizedBox(width: 10),
            Text(activity),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity == 'Meditasyon')
              const Text('• 5-10 dakika sessiz bir yer bulun\n'
                  '• Rahat bir pozisyonda oturun\n'
                  '• Nefesinize odaklanın\n'
                  '• Düşünceleri yargılamadan izleyin'),
            if (activity == '4-7-8 Nefes')
              const Text('• 4 saniye nefes alın\n'
                  '• 7 saniye nefesi tutun\n'
                  '• 8 saniye nefesi verin\n'
                  '• 4-5 kez tekrarlayın'),
            if (activity == 'Kutu Nefesi')
              const Text('• 4 saniye nefes alın\n'
                  '• 4 saniye nefesi tutun\n'
                  '• 4 saniye nefesi verin\n'
                  '• 4 saniye bekleyin'),
            if (activity == 'Günlük')
              const Text('• Her gün aynı saatte yazın\n'
                  '• Duygularınızı özgürce ifade edin\n'
                  '• Minnettar olduğunuz şeyleri yazın'),
            if (activity == 'Yürüyüş')
              const Text('• Günde 20-30 dakika yürüyün\n'
                  '• Doğal alanları tercih edin\n'
                  '• Telefonunuzu evde bırakın'),
            if (activity == 'Doğa Sesleri')
              const Text('• Rahat bir pozisyonda uzanın\n'
                  '• Kulaklık takın\n'
                  '• Gözlerinizi kapatın\n'
                  '• Seslere odaklanın'),
            if (activity == 'Profesyonel Destek')
              const Text('• Psikolojik Destek Hattı: 183\n'
                  '• Aile hekiminizden randevu alın\n'
                  '• Bir psikolog veya psikiyatrist bulun'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Kapat', style: TextStyle(color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _getResultData();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: Text(
          '${widget.testName} Sonucu',
          style: const TextStyle(color: Color(0xFF064E3B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.testColor),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          result.color.withOpacity(0.2),
                          result.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Text(result.emoji,
                            style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text(
                          result.level,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: result.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.score}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                            Text(
                              ' / ${widget.maxScore}',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: widget.score / widget.maxScore,
                            backgroundColor: Colors.grey.shade200,
                            color: result.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFD1FAE5), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          result.mainMessage,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF064E3B),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFD1FAE5), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: result.color),
                            const SizedBox(width: 8),
                            const Text(
                              'Sana Önerilerimiz',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...result.suggestions.map((suggestion) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: result.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF064E3B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFD1FAE5), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.self_improvement, color: result.color),
                            const SizedBox(width: 8),
                            const Text(
                              'Önerilen Aktiviteler',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: result.activities.map((activity) {
                            return GestureDetector(
                              onTap: () => _showActivityDialog(activity),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: result.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: result.color.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_fill,
                                      size: 16,
                                      color: result.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      activity,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: result.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          result.color.withOpacity(0.1),
                          result.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.format_quote,
                            color: Color(0xFF6B7280)),
                        const SizedBox(height: 8),
                        Text(
                          result.quote,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF064E3B),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          icon: const Icon(Icons.home),
                          label: const Text('Ana Sayfa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.testColor,
                            side: BorderSide(color: widget.testColor),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Testlere Dön'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.testColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class ResultData {
  final String level;
  final String emoji;
  final String mainMessage;
  final String description;
  final List<String> suggestions;
  final List<String> activities;
  final String quote;
  final Color color;

  const ResultData({
    required this.level,
    required this.emoji,
    required this.mainMessage,
    required this.description,
    required this.suggestions,
    required this.activities,
    required this.quote,
    required this.color,
  });
}
