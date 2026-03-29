import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MotivationWheelScreen extends StatefulWidget {
  const MotivationWheelScreen({super.key});

  @override
  State<MotivationWheelScreen> createState() => _MotivationWheelScreenState();
}

class _MotivationWheelScreenState extends State<MotivationWheelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _fallbackMotivations = [
    'Zafer, zafer benimdir diyebilenindir. Başarı ise "başaracağım" diye başlayarak sonunda "başardım" diyenindir.',
    'Kazanma isteği ve başarıya ulaşma arzusu birleşirse kişisel mükemmelliğin kapısını açar.',
    'Hiçbir şeyden vazgeçme, çünkü sadece kaybedenler vazgeçer.',
    'Başarıya çıkan asansör bozuk. Bekleyerek zaman kaybetmeyin, adım adım merdivenleri çıkmaya başlayın.',
    'Fırsatlar durup dururken karşınıza çıkmaz, onları siz yaratırsınız.',
    'Şansa çok inanırım ve ne kadar çok çalıştıysam ona o kadar çok sahip oldum.',
    'Bir şeye başlayıp başarısız olmaktan daha kötü tek şey hiçbir şeye başlamamaktır.',
    'Sadece sınırlarını aşmanın riskini alanlar ne kadar ileri gidebildiklerini görürler.',
    'Hayat her ne kadar zor görünse de, yapabileceğimiz ve başarabileceğimiz bir şey mutlaka vardır.',
    'Bir şeyi başarmak ne kadar zorsa, zaferin tadı o kadar güzeldir.',
    'Hiç kimse başarı merdivenine elleri cebinde tırmanmamıştır.',
    'Ne zaman başarılı bir iş görseniz, birisi bir zamanlar mutlaka cesur bir karar almıştır.',
    'Sessizce sıkı çalışın, bırakın başarı sesiniz olsun.',
    'Eğer her şey kontrol altında gibi görünüyorsa, yeterince hızlı gitmiyorsunuzdur.',
    'Başarısız insanlar içerisinde bulundukları duruma göre karar verirler. Başarılı insanlar ise olmak istedikleri yere göre karar verirler.',
    'Sadece başarılı bir insan olmaya değil, değerli bir insan olmaya çalışın.',
    'Başarı son değildir, başarısızlık ise ölümcül değildir: Önemli olan ilerlemeye cesaret etmektir.',
    'Başarı, küçük çabaların her gün tekrarlanmasıyla gelir.',
    'İmkansız, sadece cesaretini yeterince toplayamayanlar için bir kelimedir.',
    'Bugün ter dökmeyen, yarın zaferi kutlayamaz.',
    'Hayallerini gerçeğe dönüştürmenin ilk adımı uyanmaktır.',
    'Başarı, en yükseğe sıçrayabilen değil; yere her düştüğünde kalkabilendir.',
    'Yapabileceğine inanırsan, yol zaten açılır.',
    'Başarı, hazır olanlara değil; harekete geçenlere gelir.',
    'Sınırlar, genellikle sadece bizim zihnimizdedir.',
    'Her büyük başarı, bir hayalle başlar. O hayale sarıl.',
    'Zor zamanlar asla kalıcı değildir ama zorluklara direnen insanlar kalıcıdır.',
    'Hayatımı sadece ben değiştirebilirim. Kimse benim için bunu yapmaz.',
    'Hiç kimse geriye gidip yeni bir başlangıç yapamaz ama bugün yeni bir son yapıp yeniden başlayabilir.',
    'Diğerlerinden daha akıllı olmak zorunda değiliz. Diğerlerinden daha disiplinli olmak zorundayız.',
    'Uyandığınızda; yaşamanın, zevk almanın, düşünmenin ve sevmenin ne kadar büyük bir ayrıcalık olduğunu hatırlayın.',
    'Siz kendinize inanın, başkaları da size inanacaktır.',
    'Karanlıktan korkan bir çocuğu kolayca affedebiliriz. Hayatın gerçek trajedisi büyükler ışıktan korktuğunda başlar.',
    'Dünyayı değiştirebilen insanla buna inanacak kadar deli olanlardır.',
    'Sadece görülmeyeni gören imkansızı başarabilir.',
    'Her gün kendini yeniliyorsun. Bazen başarılı olursun, bazen olamazsın, ama önemli olan ortalamadır.',
    'Kısa vadede acımasızca dürüst olun, uzun vade için ise iyimser ve kendinizden emin olun.',
    'Birisi size bir şeyi yapamayacağını söylediğinde, belki de size sadece kendi yapamadıklarını söylüyordur.',
    'Kendinizi sınırlamayın. Çoğu insan yapabileceklerini düşündükleri şeyler konusunda kendilerini sınırlarlar.',
    'Zeki insanlar herkesten ve her şeyden öğrenirler. Ortalama insanlar deneyimlerinden öğrenirler. Aptal insanlar ise zaten bütün cevaplara sahiptir.',
    'Bardağın yarısının dolu mu, boş mu olduğunu tartışan insanlar asıl odaklanmaları gereken noktayı kaçırıyorlar. Bardak doldurulabilir.',
    'Yüzünüzü güneşe çevirin, böylece gölgeler her zaman arkanızda kalacaktır.',
    'Dün zekiydim, bu yüzden dünyayı değiştirmek istedim. Şimdi ise bilgeyim, bu sebeple kendimi değiştiriyorum.',
    'Eğer bir şeyi değiştiremiyorsanız bırakın. Değiştiremediğiniz şeylerin mahkûmu olmayın.',
    'Dışarıda olanları her zaman kontrol edemezsiniz. Ama içinde olanları edebilirsin.',
    'En büyük düşmanınızın iki kulağınızın arasında yaşamadığına emin olun.',
    'Dünden ders alın, bugün için yaşayın, yarın için umutlu olun.',
    'Hayatta en büyük keşif, bir insanın kendi potansiyelini fark etmesidir.',
    'Kendine liderlik edemeyen biri, başkalarını da yönlendiremez.',
    'Her büyük değişim, küçük bir kararla başlar.',
    'Başarılı insanlar güçlü yönlerine odaklanır, zayıflıkları üzerinde takılı kalmaz.',
    'Başkalarının seni nasıl gördüğü değil, senin kendini nasıl gördüğün hayatını şekillendirir.',
    'Kendini tanımak, tüm bilgeliğin başlangıcıdır. Oturduğumuz sürece korkular yaratırız. Harekete geçtiğimizde ise korkularımızın üstesinden geliriz.',
    'Senin almaya cesaret edemediğin riskleri alanlar, senin yaşamak istediğin hayatı yaşarlar.',
    'Bir gün kalkacaksınız ve hep hayal ettiğiniz şeyleri yapmaya vakit kalmamış olacak. Şimdi harekete geçmenin tam zamanı.',
    'Yapmadığım şeyler yüzünden pişmanlık duymaktansa, yaptığım şeyler yüzünden pişmanlık duymayı tercih ederim.',
    'Sadece düşünerek bir tarlayı biçemezsiniz. Başlamak istiyorsanız, başlamanız lazım.',
    'Kurallara uyarak yürümeyi öğrenemezsin. Yaparak ve düşünerek öğrenirsin.',
    'Düşünmeden bir gün bile geçiremediğiniz bir şeyden asla vazgeçmeyin.',
    'Unutma, her şampiyon bir zamanlar pes etmeyi reddeden bir yarışmacıydı.',
    'Aynı bölümü tekrar tekrar okumaya devam edersen hayatının bir sonraki bölümüne başlayamazsın.',
    'Başlamanın yolu, konuşmayı bırakıp yapmaya başlamaktır.',
    'Bin kilometrelik bir yolculuk tek bir adımla başlar.',
    'Öne geçmenin sırrı, başlamaktır.',
    'Ağaç dikmek için en iyi zaman 20 yıl öncesiydi. İkinci en iyi zaman ise şimdi.',
    'Bütün merdivenleri görmek zorunda değilsiniz. Yapmanız gereken tek şey ilk adımı atmak.',
    'Başlamak için mükemmel olmak zorunda değilsiniz, ama mükemmel olmak için önce başlamalısınız.',
    'Bugün içinde bulunduğunuz mücadele, yarın ihtiyacınız olan gücü geliştiriyor.',
    'Çatışman ne kadar zorsa, zaferin de o kadar şereflidir!',
    'Yüzüstü yere serilseniz bile, hala ileriye doğru hareket ediyorsunuzdur!',
    'Tanrıdan kolay bir hayat dilemeyin: zor olana dayanabilecek güç dileyin.',
    'Bir gün geçmişe baktığınızda en güzel yıllarınızın mücadele ile geçen yıllar olduğunu göreceksiniz.',
    'Girmeye korktuğun mağara, umduğun hazineyi saklıyor olabilir.',
    'Mağlubiyete uğradığında ümitsizliğe kapılma, her başarısızlıkta bir zafer arzusu yatar.',
    'Yüzleşmediğimiz korkularımız sınırlarımızı oluşturur.',
    'Zorluklarla karşılaşmak istemeyenler, felaketlere layıktır.',
    'Dünya herkesi kırar ve bazıları kırılan yerlerinden güçlenir.',
    'Acı sizi değiştirebilir ancak bu değişim kötü olmak zorunda değildir. Acıyı alın ve bilgeliğe dönüştürün.',
    'Eğer insanlar ne kadar ileri gidebileceğinizi sorguluyorsa, onları duyamayacağınız kadar ileriye gidin.',
    'İnsanları güçlendiren şey, zor günlerdir.',
    'Zorluklarınızı sınırlamayın. Sınırlarınızı zorlayın.',
    'Yenilmek geçici bir durumdur. Pes etmek ise onu kalıcı yapar.',
    'Bazen karanlık bir yerdeyken gömüldüğünüzü düşünürsünüz. Ama aslında ekilmişsinizdir.',
    'Vaktinde bana "hayır" diyen herkese minnettarım. Onlar sayesinde kendi işimi kendim yapabiliyorum.',
    'Pes etmeyi düşündüğünüzde, hala haksız çıkarmanız gereken insanlar olduğunu hatırlayın.',
  ];

  String? _motivation;
  bool _loading = false;
  double _wheelTurns = 0;

  @override
  void initState() {
    super.initState();
    _seedMotivationsIfEmpty();
  }

  Future<String> _fetchRandomMotivation() async {
    try {
      final snapshot = await _firestore.collection('motivations').get();
      final docs = snapshot.docs;
      if (docs.isEmpty) {
        return _fallbackMotivations[Random().nextInt(_fallbackMotivations.length)];
      }
      final index = Random().nextInt(docs.length);
      final data = docs[index].data();
      final text = data['text'] as String?;
      return text?.trim().isNotEmpty == true
          ? text!
          : _fallbackMotivations[Random().nextInt(_fallbackMotivations.length)];
    } catch (_) {
      return _fallbackMotivations[Random().nextInt(_fallbackMotivations.length)];
    }
  }

  Future<void> _seedMotivationsIfEmpty() async {
    try {
      final collection = _firestore.collection('motivations');
      final snapshot = await collection.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return;
      }
      final batch = _firestore.batch();
      for (final quote in _fallbackMotivations) {
        batch.set(collection.doc(), {'text': quote});
      }
      await batch.commit();
    } catch (_) {
      // Firestore seed is optional; silently ignore failures.
    }
  }

  Future<void> _spinWheel() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _wheelTurns += 3.5 + Random().nextDouble() * 2;
    });

    final motivation = await _fetchRandomMotivation();
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() {
      _motivation = motivation;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        title: const Text('Günlük Motivasyon'),
        backgroundColor: const Color(0xFF72B01D),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4332).withValues(alpha: 20),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'Hazır Mısın?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mesajını görmek için çarkı çevir.',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1B4332).withValues(alpha: 166),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 900),
                        turns: _wheelTurns,
                        curve: Curves.easeOutQuart,
                        child: CustomPaint(
                          size: const Size(280, 280),
                          painter: _MotivationWheelPainter(
                            const [
                              Color(0xFF72B01D),
                              Color(0xFF5F8E26),
                              Color(0xFF4E8A3A),
                              Color(0xFF6EA84E),
                              Color(0xFF8BC77A),
                              Color(0xFFB6D69E),
                              Color(0xFFDCF0D3),
                              Color(0xFF95C68C),
                              Color(0xFFA4D398),
                              Color(0xFF73A942),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -14,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF72B01D),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B4332).withValues(alpha: 32),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF72B01D),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B4332).withValues(alpha: 18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.spa,
                            color: Color(0xFF72B01D),
                            size: 30,
                          ),
                        ),
                      ),
                      if (_motivation != null && !_loading)
                        Center(
                          child: Container(
                            width: 240,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF72B01D),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B4332).withValues(alpha: 20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _motivation!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B4332),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _spinWheel,
                    icon: const Icon(Icons.casino_outlined),
                    label: Text(_loading ? 'Yükleniyor...' : 'Çarkı Çevir'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationWheelPainter extends CustomPainter {
  final List<Color> colors;

  _MotivationWheelPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;
    final sweep = 2 * pi / colors.length;

    for (var i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep,
        true,
        paint,
      );
    }

    final dividerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < colors.length; i++) {
      final angle = i * sweep;
      final end = center + Offset(cos(angle), sin(angle)) * radius;
      canvas.drawLine(center, end, dividerPaint);
    }

    final outerBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = const Color(0xFF72B01D);
    canvas.drawCircle(center, radius, outerBorder);

    final dotPaint = Paint()..color = Colors.white;
    const dotRadius = 4.0;
    final dotCount = colors.length;
    final dotDistance = radius * 0.92;

    for (var i = 0; i < dotCount; i++) {
      final dotAngle = (i + 0.5) * sweep;
      final dotCenter = center + Offset(cos(dotAngle), sin(dotAngle)) * dotDistance;
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
