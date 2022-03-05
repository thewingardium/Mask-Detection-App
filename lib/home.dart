import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  final imagePicker = ImagePicker();
  List _predictions = [];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  detectImage(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _predictions = prediction!;
    });
  }

  _loadImageFromGallery() async {
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectImage(_image);
  }

  _loadImageFromCamera() async {
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Mask Detection',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: Container(
        height: h,
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 180,
              width: 180,
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/mask.png'),
            ),
            Container(
              child: Text(
                'Mask Detection',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _loadImageFromCamera,
                child: Text(
                  "Camera",
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  primary: Colors.blueAccent,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _loadImageFromGallery,
                child: Text(
                  "Gallery",
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  primary: Colors.blueAccent,
                ),
              ),
            ),
            _loading == false
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          child: Image.file(_image),
                        ),
                        Text(_predictions[0]['label'].toString().substring(2)),
                        Text('Confidence: '+_predictions[0]['confidence'].toString()),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
