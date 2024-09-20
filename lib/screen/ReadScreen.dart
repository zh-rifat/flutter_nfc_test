
// NFC Read Screen
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
