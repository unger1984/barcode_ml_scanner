import 'package:barcode_ml_scanner/barcode_ml_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _cameraKey = GlobalKey<BarcodeMlScannerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BarcodeMlScanner example app'),
        ),
        body: BarcodeMlScanner(
          key: _cameraKey,
          onFound: (barcodes) {
            print(barcodes.first.type);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _cameraKey.currentState?.toggleCamera();
          },
          child: const Icon(Icons.camera),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
