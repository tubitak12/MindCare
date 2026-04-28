import 'dart:io';
import 'dart:convert';

void main() async {
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int count = 0;
  for (var file in files) {
    // Read the file bytes
    List<int> bytes = await file.readAsBytes();
    String text = utf8.decode(bytes, allowMalformed: true);
    
    // Fallback dictionary for common powershell utf-8 mangled chars
    var replacements = {
      'Ä±': 'ı',
      'ÅŸ': 'ş',
      'ÄŸ': 'ğ',
      'Ã¼': 'ü',
      'Ã¶': 'ö',
      'Ã§': 'ç',
      'Ä°': 'İ',
      'Åž': 'Ş',
      'Äž': 'Ğ',
      'Ãœ': 'Ü',
      'Ã–': 'Ö',
      'Ã‡': 'Ç',
      'âœ¨': '✨',
      'ğŸŒ¿': '🌿',
      'ğŸš€': '🚀',
      'ğŸ˜Œ': '😌',
      'ğŸ˜Š': '😊',
      'ğŸ˜´': '😴',
      'ğŸ§˜': '🧘',
      'ğŸ’ª': '💪',
      'ğŸ“ ': '📄',
      'Ã§': 'ç',
      'Ã¶': 'ö',
      'ÄŸ': 'ğ',
      'Ã¼': 'ü',
      'AÃ§Ä±klama': 'Açıklama',
      'henÃ¼z': 'henüz',
      'yakÄ±nda': 'yakında',
      'Ä°lgilen': 'İlgilen',
      'baÅŸarÄ±lÄ±': 'başarılı',
      'gÃ¶ster': 'göster',
      'KayÄ±t': 'Kayıt',
      'kayÄ±t': 'kayıt',
      'Ad Soyad': 'Ad Soyad',
      'DoÄŸum': 'Doğum',
      'Åžifre': 'Şifre',
      'eÅŸleÅŸmiyor': 'eşleşmiyor',
      'GeÃ§ersiz': 'Geçersiz',
      'Zaten': 'Zaten',
      'giriÅŸ': 'giriş',
      'GiriÅŸ': 'Giriş',
      'Ã§ok': 'çok',
      'zayÄ±f': 'zayıf',
      'oluÅŸturulamadÄ±': 'oluşturulamadı',
      'katÄ±l': 'katıl',
      'Ã–zellik': 'Özellik',
      'Ã¶zel': 'özel',
      'kiÅŸiselleÅŸtirilmiÅŸ': 'kişiselleştirilmiş',
      'hazÄ±rladÄ±k': 'hazırladık',
      'hazÄ±rsÄ±nÄ±z': 'hazırsınız',
      'iÃ§eriÄŸi': 'içeriği',
      'butonlarÄ±': 'butonları',
      'Ä°leri': 'İleri',
      'BaÅŸlayalÄ±m': 'Başlayalım',
      'MÃ¼zik': 'Müzik',
      'YÃ¶netimi': 'Yönetimi',
      'alanlarÄ±': 'alanları',
      'YardÄ±mcÄ±': 'Yardımcı',
      'NasÄ±l': 'Nasıl',
    };

    String newText = text;
    replacements.forEach((bad, good) {
      newText = newText.replaceAll(bad, good);
    });

    if (text != newText) {
      await file.writeAsString(newText);
      count++;
      print('Fixed ${file.path}');
    }
  }
  print('Total files fixed: $count');
}
