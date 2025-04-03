import 'package:flutter/material.dart';
import 'crop_scanning.dart';
import 'store_data.dart';
import 'soil_condition.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light theme background
      backgroundColor: Colors.grey[100],
      
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "AgroScan",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),

      // Body
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Ensures the Column occupies at least the entire screen height
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              // IntrinsicHeight allows the Column to size itself correctly when centering
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    // This centers the content vertically if there is extra space
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome header styled as a card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              offset: const Offset(0, 8),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Welcome to AgroScan",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.green[800],
                              radius: 24,
                              child: const Icon(Icons.eco, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Option Tiles
                      _buildOption(context, Icons.camera_alt, "Scan Your Plant", CropScanningPage()),
                      const SizedBox(height: 16),
                      _buildOption(context, Icons.storage, "Store Your Data", StoreDataPage()),
                      const SizedBox(height: 16),
                      _buildOption(context, Icons.science, "Best Soil Condition", SoilConditionPage()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Option tiles as Cards
  Widget _buildOption(BuildContext context, IconData icon, String title, Widget? page) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This feature is not available yet")),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.green[700]),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
