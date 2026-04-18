import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dscan/dscan.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final imagePicker = ImagePicker();
  bool loading = false;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    setState(() {
      loading = true;
    });

    try {
      final image = await imagePicker.pickImage(source: ImageSource.gallery);
      final bytes = await image?.readAsBytes();
      setState(() {
        imageBytes = bytes ?? imageBytes;
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _grayscaleImage(Uint8List bytes) async {
    setState(() {
      loading = true;
    });

    final grayscaleBytes = await processDocument(imageBytes: bytes.toList());

    setState(() {
      imageBytes = grayscaleBytes;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Image processing')),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: switch (loading) {
                    true => Center(child: CircularProgressIndicator()),
                    false when imageBytes != null => Image.memory(imageBytes!),
                    _ => Center(child: Text('No image selected')),
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick image'),
                  ),
                ),
                if (imageBytes != null)
                  ElevatedButton(
                    onPressed: () => _grayscaleImage(imageBytes!),
                    child: Text('Process image'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
