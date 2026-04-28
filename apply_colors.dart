import 'dart:io';
import 'dart:convert';

void main() async {
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  var replacements = {
    'Color(0xFF72B01D)': 'Color(0xFF10B981)',
    'Color(0xFF1B4332)': 'Color(0xFF064E3B)',
    'Color(0xFFF0F7EE)': 'Color(0xFFF0FDF4)',
    'color: Colors.green': 'color: const Color(0xFF10B981)',
    'color: Colors.grey': 'color: const Color(0xFF6B7280)',
    'Color(0xFF72B01D).withOpacity': 'Color(0xFF10B981).withOpacity',
    'Color(0xFF1B4332).withOpacity': 'Color(0xFF064E3B).withOpacity',
    'Color(0xFFF0F7EE).withOpacity': 'Color(0xFFF0FDF4).withOpacity',
    'Color(0xFF72B01D).withValues': 'Color(0xFF10B981).withValues',
    'Color(0xFF1B4332).withValues': 'Color(0xFF064E3B).withValues',
    'Color(0xFFF0F7EE).withValues': 'Color(0xFFF0FDF4).withValues',
  };

  int count = 0;
  for (var file in files) {
    // Read the file with UTF-8
    String text = await file.readAsString(encoding: utf8);
    String newText = text;

    replacements.forEach((oldStr, newStr) {
      newText = newText.replaceAll(oldStr, newStr);
    });

    if (text != newText) {
      // Write the file with UTF-8
      await file.writeAsString(newText, encoding: utf8);
      count++;
      print('Updated ${file.path}');
    }
  }
  print('Total files updated: $count');
}
