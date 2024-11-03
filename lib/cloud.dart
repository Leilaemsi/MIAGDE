import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  final picker = ImagePicker();

  Future<String> uploadImage(File imageFile) async {
    String cloudName = 'dljmjokgv'; // Replace with your Cloud Name
    String apiKey = '753441732922877'; // Replace with your API Key
    String apiSecret =
        'h4M2pEidTeJ4vZuCy_oQi5S42ag'; // Replace with your API Secret
    String url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    print('Preparing to upload image: ${imageFile.path}'); // Debug point

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['upload_preset'] =
        'leila1'; // Replace with your upload preset

    // Add the image
    var fileStream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var multipartFile = http.MultipartFile('file', fileStream, length,
        filename: basename(imageFile.path));
    request.files.add(multipartFile);

    print('Image added to request, size: $length bytes'); // Debug point

    // Send the request
    var response = await request.send();
    print('Response status: ${response.statusCode}'); // Debug point

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var result = json.decode(String.fromCharCodes(responseData));
      print('Upload successful: ${result['secure_url']}'); // Debug point
      return result['secure_url']; // Return the image URL
    } else {
      // Detailed error response logging
      var responseData = await response.stream.toBytes();
      var errorResponse = String.fromCharCodes(responseData);
      print('Error response: $errorResponse'); // Log the detailed error message
      throw Exception(
          "Failed to upload image ${response.statusCode}: $errorResponse");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    print('Picked file: ${pickedFile?.path}'); // Debug point

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      print('Image file set: ${_image!.path}'); // Debug point

      try {
        String url = await uploadImage(_image!);
        print('Image URL: $url'); // Display the image URL
      } catch (e) {
        print('Error uploading image: $e'); // Log the error
      }
    } else {
      print('No image selected.'); // Debug point
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick an Image'),
            ),
          ],
        ),
      ),
    );
  }
}
