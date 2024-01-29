import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;

  late TextRecognizer _textRecognizer;
  String _extractedText = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _textRecognizer = GoogleMlKit.vision.textRecognizer();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();

    setState(() {
      _isCameraInitialized = true;
    });
  }


  Future<void> _disposeCamera() async {
    await _cameraController.dispose();
    _textRecognizer.close();
  }


  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    try {
      final inputImage = InputImage.fromFilePath(_selectedImage!.path);
      final RecognizedText recognisedText = await _textRecognizer.processImage(
          inputImage);
      setState(() {
        _extractedText = recognisedText.text;
      });
    } catch (e) {
      print("Error processing image: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      if (_isCameraInitialized) {
        XFile photo = await _cameraController.takePicture();
        _updateSelectedImage(photo);
      }
    } catch (e) {
      print("Une erreur s'est produite : $e");
    }
  }

  Future<void> _openGallery() async {
    if (await _requestGalleryPermission()) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      _updateSelectedImage(image);
    } else {
      // L'utilisateur a refusé l'autorisation pour la galerie
    }
  }


  Future<bool> _requestGalleryPermission() async {
    var status = await Permission.photos.status;
    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.photos.request();
      return result.isGranted;
    }
  }

  void _updateSelectedImage(XFile? image) {
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      _processImage();
    }
  }


  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('TextApp'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 600.0,
                height: 500.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: _isCameraInitialized
                    ? (_selectedImage != null
                    ? Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                )
                    : CameraPreview(_cameraController))
                    : Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                _extractedText,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () {
                      _takePhoto();
                    },
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5.0),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      _openGallery();
                    },
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5.0),
                  IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () {
                      // code pour copier-coller
                    },
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}