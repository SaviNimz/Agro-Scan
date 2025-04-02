import 'package:flutter/material.dart';

class TreatmentPage extends StatelessWidget {
  final String prediction;

  TreatmentPage({required this.prediction});

  // Returns more detailed treatment recommendations based on the predicted disease.
  String getTreatmentMethod(String prediction) {
    switch (prediction) {
      case "Blight":
        return "Blight Treatment Details:\n\n"
            "1. Cultural Practices: Remove and destroy infected foliage immediately to reduce pathogen spread. Ensure adequate spacing between plants to improve air circulation and reduce humidity. Avoid overhead irrigation to minimize leaf wetness.\n\n"
            "2. Chemical Control: Apply copper-based fungicides or other locally recommended products at the first sign of disease. Follow label instructions for dosage and frequency. In severe cases, consider systemic fungicides.\n\n"
            "3. Crop Management: Rotate with non-host crops to break the disease cycle. Practice deep plowing or removal of infected crop residues to limit pathogen survival in the soil.\n\n"
            "4. Resistant Varieties: Use blight-resistant cultivars when available to reduce the risk of infection.";
      case "Common Rust":
        return "Common Rust Treatment Details:\n\n"
            "1. Cultural Practices: Remove plant debris and infected leaves from the field to lower inoculum levels. Maintain optimal plant spacing to ensure good air circulation, which helps reduce humidity.\n\n"
            "2. Chemical Control: Use fungicides such as triazoles or strobilurins early in the disease cycle. Be sure to adhere to recommended application rates and timings based on local agricultural guidelines.\n\n"
            "3. Crop Management: Practice crop rotation and avoid replanting the same or related species consecutively. Consider using resistant varieties if available.\n\n"
            "4. Monitoring: Regularly inspect your crops during high-risk periods (e.g., humid and warm weather) to catch early signs of rust.";
      case "gray Leaf Spot":
        return "Gray Leaf Spot Treatment Details:\n\n"
            "1. Cultural Practices: Remove and destroy affected leaves to reduce pathogen spread. Implement crop rotation with non-host species and adjust planting densities to promote better air circulation.\n\n"
            "2. Chemical Control: Apply fungicides like strobilurins at the first appearance of symptoms. Follow local recommendations for application frequency and dosages.\n\n"
            "3. Nutrient Management: Avoid excessive nitrogen fertilization, which can lead to dense, vulnerable growth. Instead, use balanced nutrition to support overall plant health.\n\n"
            "4. Integrated Management: Combine timely fungicide applications with robust cultural practices for best results.";
      case "Healthy":
        return "Your crop appears healthy. To maintain this status, consider the following practices:\n\n"
            "1. Regular Monitoring: Inspect your crop frequently to catch any early signs of disease or pest issues.\n\n"
            "2. Balanced Nutrition: Use a balanced fertilization plan suited to your crop’s needs to ensure robust growth and stress resilience.\n\n"
            "3. Good Agronomic Practices: Maintain proper irrigation, plant spacing, and sanitation practices to prevent disease outbreaks.\n\n"
            "4. Preventive Measures: Stay informed on local disease trends and consider preventive fungicide applications during periods of high risk.";
      default:
        return "No specific treatment recommendations available for the detected condition. Please consult a local agricultural expert for further guidance.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final treatmentMethod = getTreatmentMethod(prediction);
    return Scaffold(
      appBar: AppBar(
        title: Text("Treatment Recommendations"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/leaf_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 40, bottom: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 20),
                _buildCard("Disease Diagnosis", prediction),
                SizedBox(height: 20),
                _buildCard("Detailed Treatment Recommendation", treatmentMethod),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white70,
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
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
