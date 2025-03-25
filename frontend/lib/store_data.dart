import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreDataPage extends StatefulWidget {
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
        SnackBar(content: Text("User not logged in. Please login first.")),
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
        SnackBar(content: Text("Data saved successfully!")),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/leaf_background.jpg'),
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
              _buildTextField("Enter Plant Type:", _plantTypeController),
              _buildTextField("Enter Moisture Level:", _moistureLevelController),
              _buildTextField("Enter PH Level:", _phLevelController),
              _buildTextField("Enter Nutrition Level:", _nutritionLevelController),
              _buildTextField("Enter Pesticide Volume:", _pesticideVolumeController),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
