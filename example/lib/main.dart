import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dscan_example/edges_painer.dart';
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
  List<DocPoint> documentEdges = [];
  bool loading = false;
  Uint8List? imageBytes;
  ui.Image? decodedImage;

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

      if (bytes != null) {
        final decoded = await decodeImageFromList(bytes);

        setState(() {
          imageBytes = bytes;
          decodedImage = decoded;
          documentEdges = [];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _detectEdges(Uint8List bytes) async {
    setState(() {
      loading = true;
    });

    final points = await detectDocumentEdges(imageBytes: bytes.toList());

    print(points);

    setState(() {
      documentEdges = points;
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
                    true => const Center(child: CircularProgressIndicator()),
                    false when imageBytes != null && decodedImage != null =>
                      FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: decodedImage?.width.toDouble(),
                          height: decodedImage?.height.toDouble(),
                          child: Stack(
                            children: [
                              Image.memory(imageBytes!),
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: EdgesPainter(documentEdges),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    onPressed: () => _detectEdges(imageBytes!),
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
