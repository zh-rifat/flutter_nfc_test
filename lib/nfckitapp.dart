// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';


// class Nfckitapp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomeScreenq(),
//         '/write': (context) => NFCWriteScreenq(),
//         '/read': (context) => NFCReadScreenq(),
//       },
//     );
//   }
// }

// // Home Screen
// class HomeScreenq extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('NFC App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/write');
//               },
//               child: Text('Go to Write NFC'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/read');
//               },
//               child: Text('Go to Read NFC'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // NFC Write Screen
// class NFCWriteScreenq extends StatefulWidget {
//   @override
//   _NFCWriteScreenState createState() => _NFCWriteScreenState();
// }

// class _NFCWriteScreenState extends State<NFCWriteScreenq> {
//   final _formKey = GlobalKey<FormState>();
//   String serialNumber = '';
//   String atqa = '';
//   String sak = '';
//   String ats = '';

//   String _nfcMessage = 'Tap an NFC card to write data';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('NFC Write Data'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Serial Number (format: 3C:77:36:11)'),
//                 onSaved: (value) {
//                   serialNumber = value!;
//                 },
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter Serial Number';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'ATQA (hex format: 0x0008)'),
//                 onSaved: (value) {
//                   atqa = value!;
//                 },
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter ATQA';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'SAK (hex format: 0x20)'),
//                 onSaved: (value) {
//                   sak = value!;
//                 },
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter SAK';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'ATS (hex format: 0x81000300203002220100140D)'),
//                 onSaved: (value) {
//                   ats = value!;
//                 },
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter ATS';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _startNFCWrite,
//                 child: Text('Write to NFC'),
//               ),
//               SizedBox(height: 20),
//               Text(_nfcMessage),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<int> _parseSerialNumber(String serialNumber) {
//     return serialNumber
//         .split(':')
//         .map((part) => int.parse(part, radix: 16))
//         .toList();
//   }

//   List<int> _parseHex(String hexString) {
//     hexString = hexString.replaceAll('0x', '');
//     List<int> bytes = [];
//     for (var i = 0; i < hexString.length; i += 2) {
//       bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
//     }
//     return bytes;
//   }

//   void _startNFCWrite() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       try {
//         List<int> serialNumberBytes = _parseSerialNumber(serialNumber);
//         List<int> atqaBytes = _parseHex(atqa);
//         List<int> sakBytes = _parseHex(sak);
//         List<int> atsBytes = _parseHex(ats);

//         List<int> nfcData = [
//           ...serialNumberBytes,
//           ...atqaBytes,
//           ...sakBytes,
//           ...atsBytes,
//         ];

//         debugPrint('NFC Data: $nfcData');

//         // Start NFC session
//         NFCTag tag = await FlutterNfcKit.poll();

//         // Send the raw data to the NFC tag
//         var result = await FlutterNfcKit.transceive(Uint8List.fromList(nfcData));

//         setState(() {
//           _nfcMessage = 'Data written successfully!';
//         });

//         // Stop the NFC session
//         await FlutterNfcKit.finish();
//       } catch (e) {
//         setState(() {
//           _nfcMessage = 'Error writing to NFC: $e';
//         });
//       }
//     }
//   }
// }

// // NFC Read Screen
// class NFCReadScreenq extends StatefulWidget {
//   @override
//   _NFCReadScreenState createState() => _NFCReadScreenState();
// }

// class _NFCReadScreenState extends State<NFCReadScreenq> {
//   String _nfcData = 'Tap an NFC card to read data';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('NFC Read Data'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _startNFCRead,
//               child: Text('Read NFC Data'),
//             ),
//             SizedBox(height: 20),
//             Text(_nfcData),
//           ],
//         ),
//       ),
//     );
//   }

//   void _startNFCRead() async {
//     // Start NFC session
//     NFCTag tag = await FlutterNfcKit.poll();

//     try {
//       // Send a command to read data (modify according to your tag type)
//       var result = await FlutterNfcKit.transceive(Uint8List.fromList([0x00])); // Replace with actual command

//       setState(() {
//         _nfcData = 'Data read: ${result.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':')}';
//       });

//       // Stop the NFC session
//       await FlutterNfcKit.finish();
//     } catch (e) {
//       setState(() {
//         _nfcData = 'Error reading from NFC: $e';
//       });
//       await FlutterNfcKit.finish();
//     }
//   }
// }
