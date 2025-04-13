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
    // Using a ListView for responsive design.
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
          // Sort data by timestamp for time-series visualizations.
          plantData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          final nutritionChartData = _buildNutritionChartData(plantData);
          final distributionData = _buildPlantDistributionData(plantData);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildChartCard(
                title: "Moisture Level Trend",
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
              _buildChartCard(
                title: "Average Nutrition per Plant Type",
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
              _buildChartCard(
                title: "Moisture vs. pH Correlation",
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
                    )
                  ],
                ),
              ),
              _buildChartCard(
                title: "Plant Type Distribution",
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
              _buildChartCard(
                title: "Pesticide Volume Trend",
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
                      yValueMapper: (PlantData plant, _) => plant.pesticideVolume,
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Helper widget to build a chart card with title and consistent styling.
  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 300, // Adjust this height as needed for your charts.
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
