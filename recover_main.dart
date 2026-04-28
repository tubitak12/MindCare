import 'dart:io';
import 'dart:convert';

void main() async {
  final logFile = File(r'C:\Users\Tamer\.gemini\antigravity\brain\8132f46e-4f94-4dc1-b6d9-054b33190e6b\.system_generated\logs\overview.txt');
  final lines = await logFile.readAsLines();

  for (var line in lines) {
    try {
      final data = json.decode(line);
      final output = data['output'] ?? '';
      if (output.contains('Mint Tema Renkleri') && output.contains('1: import')) {
        print('Found main.dart in logs');
        // Extract content
        int startIdx = output.indexOf('1: import');
        int endIdx = output.lastIndexOf('263: }') + 6;
        if (startIdx != -1 && endIdx != -1) {
          String content = output.substring(startIdx, endIdx);
          // Remove '1: ', '2: ', etc.
          final RegExp lineNumRegex = RegExp(r'^\d+: ', multiLine: true);
          content = content.replaceAll(lineNumRegex, '');
          await File('lib/main.dart').writeAsString(content);
          print('Recovered main.dart');
          return;
        }
      }
    } catch (e) {
      // Ignore
    }
  }
  print('Could not find main.dart');
}
