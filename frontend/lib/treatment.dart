import 'package:flutter/material.dart';

class TreatmentPage extends StatelessWidget {
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
              _buildCard("Treatment Diagnosis", "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
              SizedBox(height: 20),
              _buildCard(
                  "Treatment Method",
                  "Lorem ipsum dolor sit amet consectetur. In sit nisl consequat lectus. "
                  "Semper sit diam mauris at pretium. Montes scelerisque rhoncus porttitor "
                  "rhoncus ac vivamus sagittis etiam. Sodales mauris nunc sed feugiat nulla massa vel. "
                  "Blandit arcu nunc ultrices in ultrices iaculis vitae ornare. Cum semper felis netus sed vel."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
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
