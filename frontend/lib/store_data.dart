import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreDataPage extends StatefulWidget {
  const StoreDataPage({Key? key}) : super(key: key);
  
  @override
  _StoreDataPageState createState() => _StoreDataPageState();
}

class _StoreDataPageState extends State<StoreDataPage> {
  // Create controllers for each text field
  final TextEditingController _plantTypeController = TextEditingController();
  final TextEditingController _moistureLevelController = TextEditingController();
  final TextEditingController _phLevelController = TextEditingController();
  final TextEditingController _nutritionLevelController = TextEditingController();
  final TextEditingController _pesticideVolumeController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when not needed
    _plantTypeController.dispose();
    _moistureLevelController.dispose();
    _phLevelController.dispose();
    _nutritionLevelController.dispose();
    _pesticideVolumeController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    // Get the current logged in user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in. Please login first.")),
      );
      return;
    }

    // Prepare the data to be saved
    final data = {
      'plantType': _plantTypeController.text,
      'moistureLevel': _moistureLevelController.text,
      'phLevel': _phLevelController.text,
      'nutritionLevel': _nutritionLevelController.text,
      'pesticideVolume': _pesticideVolumeController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Save data in a subcollection under the user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plantData')
          .add(data);
      // If saving is successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully!")),
      );
    } catch (e) {
      // Handle any errors during save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $e")),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image remains
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/leaf_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Overlay a transparent scaffold with modern styling
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(0.9),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Store Data",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
              child: Column(
                children: [
                  _buildTextField("Enter Plant Type:", _plantTypeController),
                  _buildTextField("Enter Moisture Level:", _moistureLevelController),
                  _buildTextField("Enter PH Level:", _phLevelController),
                  _buildTextField("Enter Nutrition Level:", _nutritionLevelController),
                  _buildTextField("Enter Pesticide Volume:", _pesticideVolumeController),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
