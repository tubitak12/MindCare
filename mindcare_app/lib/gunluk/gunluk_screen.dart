// filepath: c:\Users\Tamer\Desktop\MindCare\mindcare_app\lib\gunluk\gunluk_screen.dart
import 'package:flutter/material.dart';

class GunlukScreen extends StatelessWidget {
  const GunlukScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Günlüğüm'),
        backgroundColor: const Color(0xFF7B61FF),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // yeni kayıt için yönlendirme eklenecek
        },
        backgroundColor: const Color(0xFF7B61FF),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.book_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 20),
              Text('Henüz kayıt yok',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('İlk günlük kaydınızı oluşturmak için + butonuna tıklayın',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}