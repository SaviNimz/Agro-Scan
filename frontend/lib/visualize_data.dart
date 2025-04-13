import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// Data model for plant data from Firestore.
class PlantData {
  final String plantType;
  final double moistureLevel;
  final double phLevel;
  final double nutritionLevel;
  final double pesticideVolume;
  final DateTime timestamp;

  PlantData({
    required this.plantType,
    required this.moistureLevel,
    required this.phLevel,
    required this.nutritionLevel,
    required this.pesticideVolume,
    required this.timestamp,
  });

  factory PlantData.fromMap(Map<String, dynamic> data) {
    return PlantData(
      plantType: data['plantType'] ?? '',
      moistureLevel: double.tryParse(data['moistureLevel']?.toString() ?? '0') ?? 0.0,
      phLevel: double.tryParse(data['phLevel']?.toString() ?? '0') ?? 0.0,
      nutritionLevel: double.tryParse(data['nutritionLevel']?.toString() ?? '0') ?? 0.0,
      pesticideVolume: double.tryParse(data['pesticideVolume']?.toString() ?? '0') ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Model for nutrition bar chart data.
class NutritionChartData {
  final String plantType;
  final double averageNutrition;
  NutritionChartData(this.plantType, this.averageNutrition);
}

/// Model for plant type distribution (for the pie chart).
class PlantDistributionData {
  final String plantType;
  final int count;
  PlantDistributionData(this.plantType, this.count);
}

class VisualizeDataPage extends StatefulWidget {
  const VisualizeDataPage({Key? key}) : super(key: key);

  @override
  _VisualizeDataPageState createState() => _VisualizeDataPageState();
}

class _VisualizeDataPageState extends State<VisualizeDataPage> {
  late Future<List<PlantData>> _plantDataFuture;

  @override
  void initState() {
    super.initState();
    _plantDataFuture = _fetchPlantData();
  }

  /// Retrieve plant data from Firestore for the current user.
  Future<List<PlantData>> _fetchPlantData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('plantData')
        .get();
    return snapshot.docs
        .map((doc) => PlantData.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Build nutrition chart data by aggregating the nutrition level per plant type.
  List<NutritionChartData> _buildNutritionChartData(List<PlantData> data) {
    final Map<String, List<double>> nutritionByPlant = {};
    for (final plant in data) {
      if (plant.plantType.isNotEmpty) {
        nutritionByPlant.putIfAbsent(plant.plantType, () => []).add(plant.nutritionLevel);
      }
    }
    final List<NutritionChartData> chartData = [];
    nutritionByPlant.forEach((plantType, nutritionValues) {
      final average = nutritionValues.reduce((a, b) => a + b) / nutritionValues.length;
      chartData.add(NutritionChartData(plantType, average));
    });
    return chartData;
  }

  /// Build plant distribution data for the pie chart.
  List<PlantDistributionData> _buildPlantDistributionData(List<PlantData> data) {
    final Map<String, int> distributionMap = {};
    for (final plant in data) {
      if (plant.plantType.isNotEmpty) {
        distributionMap.update(plant.plantType, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return distributionMap.entries
        .map((entry) => PlantDistributionData(entry.key, entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visualize Data"),
      ),
      body: FutureBuilder<List<PlantData>>(
        future: _plantDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available."));
          }
          final List<PlantData> plantData = snapshot.data!;
          // Ensure data is sorted by timestamp for time-series visualizations.
          plantData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          final nutritionChartData = _buildNutritionChartData(plantData);
          final distributionData = _buildPlantDistributionData(plantData);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Moisture Level Trend",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      dateFormat: DateFormat.Md(),
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                    ),
                    primaryYAxis: NumericAxis(),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<PlantData, DateTime>>[
                      LineSeries<PlantData, DateTime>(
                        dataSource: plantData,
                        xValueMapper: (PlantData plant, _) => plant.timestamp,
                        yValueMapper: (PlantData plant, _) => plant.moistureLevel,
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Average Nutrition per Plant Type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<NutritionChartData, String>>[
                      ColumnSeries<NutritionChartData, String>(
                        dataSource: nutritionChartData,
                        xValueMapper: (NutritionChartData data, _) => data.plantType,
                        yValueMapper: (NutritionChartData data, _) => data.averageNutrition,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Moisture vs. pH Correlation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SfCartesianChart(
                    primaryXAxis: NumericAxis(
                      title: AxisTitle(text: 'Moisture Level'),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: 'pH Level'),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<PlantData, double>>[
                      ScatterSeries<PlantData, double>(
                        dataSource: plantData,
                        xValueMapper: (PlantData plant, _) => plant.moistureLevel,
                        yValueMapper: (PlantData plant, _) => plant.phLevel,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          height: 10,
                          width: 10,
                        ),
                        dataLabelSettings: const DataLabelSettings(isVisible: false),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Plant Type Distribution",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SfCircularChart(
                    tooltipBehavior: TooltipBehavior(enable: true),
                    legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                    series: <CircularSeries>[
                      PieSeries<PlantDistributionData, String>(
                        dataSource: distributionData,
                        xValueMapper: (PlantDistributionData data, _) => data.plantType,
                        yValueMapper: (PlantDistributionData data, _) => data.count,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
