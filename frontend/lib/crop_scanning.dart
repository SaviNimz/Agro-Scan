import 'package:flutter/material.dart';
import 'treatment.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CropScanningPage extends StatefulWidget {
  @override
  _CropScanningPageState createState() => _CropScanningPageState();
}

class _CropScanningPageState extends State<CropScanningPage> {
  File? _selectedImage;

  // Pick image and update state
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Image Selected"),
          content: const Text("Please select an image."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  // Upload image and return prediction result
  Future<String?> _uploadImage(File imageFile) async {
    final uri = Uri.parse("http://10.0.2.2:8000/predict/");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['prediction'] as String;
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: Text("Error: ${response.statusCode}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
        return null;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Exception"),
          content: Text("An error occurred: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return null;
    }
  }

  // Called when "Show Treatment to Disease" is tapped.
  // Uploads the selected image and navigates to TreatmentPage with the prediction result.
  void _showTreatment() async {
    if (_selectedImage == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Image Selected"),
          content: const Text("Please select an image first."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return;
    }
    final prediction = await _uploadImage(_selectedImage!);
    if (prediction != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TreatmentPage(prediction: prediction)),
      );
    }
  }

  Widget _buildButton(BuildContext context, IconData icon, String label, ImageSource source) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        onPressed: () => _pickImage(source),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image with a subtle dark overlay
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/leaf_background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.darken,
              ),
            ),
          ),
        ),
        // Transparent scaffold overlay with a styled AppBar
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(0.9),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Crop Scanning",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Display selected or default image inside a fixed size card-like container
                Center(
                  child: Container(
                    width: 350,
                    height: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/logo.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildButton(context, Icons.camera_alt, "Open Camera", ImageSource.camera),
                _buildButton(context, Icons.photo, "Open Gallery", ImageSource.gallery),
                const SizedBox(height: 30),
                // Large black button at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _showTreatment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      "Show Treatment to Disease",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
