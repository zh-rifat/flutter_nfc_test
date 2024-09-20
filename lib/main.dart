
import 'package:flutter/material.dart';
import 'package:nfc_test/screen/ReadScreen.dart';
import 'package:nfc_test/screen/WriteScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/write': (context) => NFCWriteScreen(),
        '/read': (context) => NFCReadScreen(),
      },
    );
  }
}

// Home screen with navigation buttons
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Reader/Writer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/write');
              },
              child: Text('NFC Write'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/read');
              },
              child: Text('NFC Read'),
            ),
          ],
        ),
      ),
    );
  }
}


