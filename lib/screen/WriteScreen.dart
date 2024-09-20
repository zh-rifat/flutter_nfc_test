
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

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
                decoration: InputDecoration(labelText: 'Serial Number (format: aa:bb:cc:dd)'),
                initialValue: '3C:77:36:11',
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
                decoration: InputDecoration(labelText: 'ATQA (hex format: 0x0004)'),
                onSaved: (value) {
                  atqa = value!;
                },
                initialValue: '0x0008',
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
                initialValue: '0x20',
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
                initialValue: '0x81000300203002220100140D',
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
        Uint8List nfcDataBytes = Uint8List.fromList(nfcData);
        debugPrint('NFC Data: ${nfcDataBytes}');
        debugPrint('SL bytes: $serialNumberBytes');
        debugPrint('atqa bytes: $atqaBytes');
        debugPrint('sak bytes: $sakBytes');
        debugPrint('ats bytes: $atsBytes');

        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          try {
            var nfcA = NfcA.from(tag);
            var isoDep = IsoDep.from(tag);
            var ndef=Ndef.from(tag);
            if(ndef!=null){
              debugPrint(ndef.isWritable.toString());
            }else{
              debugPrint('Ndef is null');
            }

            if (nfcA != null) {
              debugPrint('max write: ${nfcA.maxTransceiveLength}');
              debugPrint('data to write: ${nfcData.length}');
              debugPrint('timout: ${nfcA.timeout} ms');

              await nfcA.transceive(data:Uint8List.fromList(nfcData.sublist(0,16)));
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
            debugPrint('Error writing to NFC: $e');
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
