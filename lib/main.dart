import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

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
              child: Text('Go to NFC Write'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/read');
              },
              child: Text('Go to NFC Read'),
            ),
          ],
        ),
      ),
    );
  }
}

// NFC Write Screen (same as previous code)
class NFCWriteScreen extends StatefulWidget {
  @override
  _NFCWriteScreenState createState() => _NFCWriteScreenState();
}

class _NFCWriteScreenState extends State<NFCWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  String serialNumber = '';
  String atqa = '';
  String sak = '';
  String ats = '';

  String _nfcMessage = 'Tap an NFC card to write data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Write Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Serial Number (format: 3C:77:36:11)'),
                onSaved: (value) {
                  serialNumber = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Serial Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'ATQA (hex format: 0x0008)'),
                onSaved: (value) {
                  atqa = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter ATQA';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'SAK (hex format: 0x20)'),
                onSaved: (value) {
                  sak = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter SAK';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'ATS (hex format: 0x81000300203002220100140D)'),
                onSaved: (value) {
                  ats = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter ATS';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startNFCWrite,
                child: Text('Write to NFC'),
              ),
              SizedBox(height: 20),
              Text(_nfcMessage),
            ],
          ),
        ),
      ),
    );
  }

  List<int> _parseSerialNumber(String serialNumber) {
    return serialNumber
        .split(':')
        .map((part) => int.parse(part, radix: 16)) // Convert hex string to integer
        .toList();
  }

  List<int> _parseHex(String hexString) {
    hexString = hexString.replaceAll('0x', ''); // Remove the "0x" prefix
    List<int> bytes = [];
    for (var i = 0; i < hexString.length; i += 2) {
      bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  void _startNFCWrite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        List<int> serialNumberBytes = _parseSerialNumber(serialNumber);
        List<int> atqaBytes = _parseHex(atqa);
        List<int> sakBytes = _parseHex(sak);
        List<int> atsBytes = _parseHex(ats);

        List<int> nfcData = [
          ...serialNumberBytes,
          ...atqaBytes,
          ...sakBytes,
          ...atsBytes,
        ];

        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          try {
            var nfcA = NfcA.from(tag);
            var isoDep = IsoDep.from(tag);

            if (nfcA != null) {
              await nfcA.transceive(data:Uint8List.fromList(nfcData));
              setState(() {
                _nfcMessage = 'Data written successfully using NfcA!';
              });
            } else if (isoDep != null) {
              await isoDep.transceive(data: Uint8List.fromList(nfcData));
              setState(() {
                _nfcMessage = 'Data written successfully using IsoDep!';
              });
            } else {
              setState(() {
                _nfcMessage = 'Unsupported NFC tag type';
              });
            }

            NfcManager.instance.stopSession();
          } catch (e) {
            setState(() {
              _nfcMessage = 'Error writing to NFC: $e';
            });
            NfcManager.instance.stopSession(errorMessage: e.toString());
          }
        });
      } catch (e) {
        setState(() {
          _nfcMessage = 'Invalid input format: $e';
        });
      }
    }
  }
}

// NFC Read Screen
class NFCReadScreen extends StatefulWidget {
  @override
  _NFCReadScreenState createState() => _NFCReadScreenState();
}

class _NFCReadScreenState extends State<NFCReadScreen> {
  String serialNumber = '';
  String atqa = '';
  String sak = '';
  String ats = '';
  String _nfcMessage = 'Tap an NFC card to read data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Read Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _startNFCRead,
              child: Text('Read NFC Card'),
            ),
            SizedBox(height: 20),
            Text('Serial Number: $serialNumber'),
            Text('ATQA: $atqa'),
            Text('SAK: $sak'),
            Text('ATS: $ats'),
            SizedBox(height: 20),
            Text(_nfcMessage),
          ],
        ),
      ),
    );
  }

  void _startNFCRead() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var nfcA = NfcA.from(tag);
        var isoDep = IsoDep.from(tag);

        if (nfcA != null) {
          var serialNumberBytes = nfcA.identifier;
          var atqaBytes = nfcA.atqa;
          var sakBytes = [nfcA.sak];
          
          setState(() {
            serialNumber = serialNumberBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
            atqa = atqaBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
            sak = sakBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
            _nfcMessage = 'Data read successfully using NfcA!';
          });
        } else if (isoDep != null) {
          // If using IsoDep, handle accordingly
          setState(() {
            _nfcMessage = 'IsoDep read: ATS and other data handling can be implemented here';
          });
        } else {
          setState(() {
            _nfcMessage = 'Unsupported NFC tag type';
          });
        }

        NfcManager.instance.stopSession();
      } catch (e) {
        setState(() {
          _nfcMessage = 'Error reading NFC: $e';
        });
        NfcManager.instance.stopSession(errorMessage: e.toString());
      }
    });
  }
}
