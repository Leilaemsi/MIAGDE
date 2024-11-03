import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/clothing_model.dart';
import '../services/predict_service.dart';
import '../services/clothing_service.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({Key? key}) : super(key: key);

  @override
  _AddClothingScreenState createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClothingService _clothingService = ClothingService();

  String? _base64Image;
  File? _imageFile;
  final _titleController = TextEditingController();
  String? _predictedCategory;
  final _sizeController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  // Cloudinary credentials
  final String cloudName = 'dljmjokgv';
  final String apiKey = '753441732922877';
  final String apiSecret = 'h4M2pEidTeJ4vZuCy_oQi5S42ag';
  final String uploadPreset = 'leila1';

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });

        final bytes = await _imageFile!.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
        // Upload image to Cloudinary and retrieve URL
        final imageUrl = await _uploadImageToCloudinary(_imageFile!);

        if (imageUrl != null) {
          // Send URL to predictCategory function and update the predicted category
          final predictedCategory = await predictCategory(imageUrl);
          setState(() {
            _predictedCategory = predictedCategory;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar("Erreur lors du chargement de l'image : $e");
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      } else {
        final errorResponse = await response.stream.bytesToString();
        print('Failed to upload image. Status code: ${response.statusCode}');
        print('Error response: $errorResponse');
        _showErrorSnackBar(
            'Échec du téléchargement de l\'image: $errorResponse');
        return null;
      }
    } catch (e) {
      print('Exception during image upload: $e');
      _showErrorSnackBar('Échec du téléchargement de l\'image: $e');
      return null;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String errorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: _imageFile != null
          ? Image.file(_imageFile!, width: 100, height: 100)
          : Icon(Icons.image, size: 100, color: Colors.grey[400]),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveClothing() async {
    if (_formKey.currentState!.validate()) {
      if (_base64Image == null) {
        _showErrorSnackBar("Veuillez sélectionner une image");
        return;
      }

      setState(() => _isLoading = true);

      try {
        final newClothing = ClothingModel(
          image: _base64Image!,
          title: _titleController.text,
          category: _predictedCategory ?? 'Inconnue',
          size: _sizeController.text,
          brand: _brandController.text,
          price: double.parse(_priceController.text),
        );

        await _clothingService.addClothing(newClothing);
        _showSuccessSnackBar('Vêtement ajouté avec succès');
        Navigator.pop(context);
      } catch (e) {
        _showErrorSnackBar("Erreur lors de l'ajout : $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4A90E2);
    const Color backgroundColor = Color(0xFFF8F9FA);
    const Color cardColor = Colors.white;
    const Color textColor = Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ajouter un vêtement',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                      color: Color.fromARGB(255, 106, 108, 110)),
                  const SizedBox(height: 16),
                  Text(
                    'Enregistrement en cours...',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _buildImagePicker()),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Titre',
                      errorText: 'Veuillez entrer un titre',
                    ),
                    _buildTextField(
                      controller: TextEditingController(
                          text:
                              _predictedCategory ?? 'Aucune catégorie prédite'),
                      label: 'Catégorie ',
                      errorText: '',
                      enabled: false,
                    ),
                    _buildTextField(
                      controller: _sizeController,
                      label: 'Taille',
                      errorText: 'Veuillez entrer une taille',
                    ),
                    _buildTextField(
                      controller: _brandController,
                      label: 'Marque',
                      errorText: 'Veuillez entrer une marque',
                    ),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Prix',
                      errorText: 'Veuillez entrer un prix',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffixText: '€',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveClothing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Valider',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
