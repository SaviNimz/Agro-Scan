import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SoilConditionPage extends StatefulWidget {
  @override
  _SoilConditionPageState createState() => _SoilConditionPageState();
}

class _SoilConditionPageState extends State<SoilConditionPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  // Function to fetch soil condition from Firestore (using lowercase doc IDs)
  Future<void> _fetchSoilCondition() async {
    final String plantName = _controller.text.trim();
    if (plantName.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('soil_condition')
          .doc(plantName)
          .get();

      if (doc.exists) {
        setState(() {
          _result = doc.get('Condition');
        });
      } else {
        setState(() {
          _result = "No soil data found for \"$plantName\".";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error fetching data: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget to build a custom AppBar
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 10),
      decoration: BoxDecoration(
        color: Colors.green[700]?.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              "Soil Condition",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  // Widget to build the search box
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: "Enter the name of the plant",
            border: InputBorder.none,
            icon: Icon(Icons.local_florist, color: Colors.green[700]),
          ),
        ),
      ),
    );
  }

  // Widget to build the search button
  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _fetchSoilCondition,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text("Search", style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  // Widget to build the results area
  Widget _buildResultArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Text(
                _result,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a background image with a color overlay
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
          // A semi-transparent overlay for better readability
          Container(
            color: Colors.white.withOpacity(0.85),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomAppBar(),
              SizedBox(height: 40),
              _buildSearchBox(),
              SizedBox(height: 20),
              Center(child: _buildSearchButton()),
              // Only show the result area if data is loading or a result exists.
              if (_isLoading || _result.isNotEmpty) _buildResultArea(),
            ],
          ),
        ],
      ),
    );
  }
}
