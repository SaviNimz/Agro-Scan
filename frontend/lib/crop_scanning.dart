import 'package:flutter/material.dart';
import 'treatment.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CropScanningPage extends StatelessWidget {
  // Function to pick an image and upload it
  Future<void> _pickAndUploadImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // backend URL
      var uri = Uri.parse("http://10.0.2.2:8000/predict/");
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      try {
        var response = await request.send();
        // print response 
        print(response.statusCode);
        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final data = jsonDecode(respStr);
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Prediction Result"),
              content: Text(data['prediction']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                )
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Error"),
              content: Text("Error: ${response.statusCode}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                )
              ],
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Exception"),
            content: Text("An error occurred: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("No Image Selected"),
          content: Text("Please select an image."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/leaf_background.jpg'), // Ensure this image exists in assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 40),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/tomatoes.jpg', // Ensure this image exists in assets
                  height: 200,
                ),
              ),
              SizedBox(height: 20),
              _buildButton(context, Icons.camera_alt, "Open Camera", ImageSource.camera),
              _buildButton(context, Icons.photo, "Open Gallery", ImageSource.gallery),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TreatmentPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text("Show Treatment to Disease", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String label, ImageSource source) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        onPressed: () {
          _pickAndUploadImage(context, source);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 10),
            Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
