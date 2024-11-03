import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

Future<String> predictCategory(String imageUrl) async {
  Interpreter? interpreter;
  final labels = ["Pantalons", "T-shirt", "Chaussures", "Veste"];

  try {
    // Load the model
    print("Loading model...");
    interpreter =
        await Interpreter.fromAsset('lib/assets/model_unquant.tflite');
    print("Model loaded successfully.");

    // Download the image
    print("Downloading image from URL: $imageUrl");
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception(
          "Failed to download image. Status code: ${response.statusCode}");
    }

    // Use External Storage Directory for saving the image temporarily
    final directory = await getExternalStorageDirectory();
    final filePath = "${directory?.path}/temp.jpg";
    final file = File(filePath);
    file.writeAsBytesSync(response.bodyBytes);
    print("Image saved to directory: $filePath");

    // Preprocess the image
    print("Preprocessing image: $filePath");
    final image = img.decodeImage(file.readAsBytesSync());
    if (image == null) {
      throw Exception("Failed to decode image");
    }
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Prepare input structure with a batch dimension [1, 224, 224, 3]
    final input = List.generate(
        1,
        (b) => List.generate(
            224, (x) => List.generate(224, (y) => List.filled(3, 0.0))));
    for (int x = 0; x < 224; x++) {
      for (int y = 0; y < 224; y++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][x][y][0] = pixel.r / 255.0;
        input[0][x][y][1] = pixel.g / 255.0;
        input[0][x][y][2] = pixel.b / 255.0;
      }
    }
    print("Image preprocessing complete");

    // Run inference
    print("Running model inference...");
    var output =
        List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);
    interpreter.run(input, output);
    print("Model inference completed. Raw output: $output");

    // Interpret the output
    List<double> outputList = output[0].cast<double>();
    int index = outputList.indexOf(outputList.reduce((a, b) => a > b ? a : b));
    print("Predicted label: ${labels[index]}");

    return labels[index];
  } catch (e) {
    print("Error classifying image: $e");
    return "Error during classification";
  } finally {
    interpreter?.close();
    print("Interpreter closed");
  }
}
