import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> locations = [];

  bool isLoading = true;
  String? errorMessage;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    loadDashboard();

    // Automatically refresh dashboard every 5 minutes.
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) {
        loadDashboard();
      },
    );
  }

  Future<void> loadDashboard() async {
    // Don't show the full loading screen
    // during automatic refresh.
    if (locations.isEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await ApiService.getDistricts();

      if (!mounted) return;

      setState(() {
        locations = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            "Could not load dashboard data.";
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Color getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
      case "EXTREME":
        return Colors.purple;

      case "HIGH":
        return Colors.red;

      case "MODERATE":
        return Colors.orange;

      case "LOW":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  int getRiskCount(String risk) {
    return locations.where((location) {
      return location["risk"]
              ?.toString()
              .toUpperCase() ==
          risk;
    }).length;
  }

  double getHighestTemperature() {
    if (locations.isEmpty) return 0;

    return locations
        .map(
          (location) =>
              (location["temperature"] as num)
                  .toDouble(),
        )
        .reduce(
          (a, b) => a > b ? a : b,
        );
  }

  int getHighestScore() {
    if (locations.isEmpty) return 0;

    return locations
        .map(
          (location) =>
              (location["score"] as num).toInt(),
        )
        .reduce(
          (a, b) => a > b ? a : b,
        );
  }

  List<dynamic> getHighestRiskLocations() {
    final sorted = List<dynamic>.from(locations);

    sorted.sort((a, b) {
      final scoreA =
          (a["score"] as num).toInt();

      final scoreB =
          (b["score"] as num).toInt();

      return scoreB.compareTo(scoreA);
    });

    return sorted.take(5).toList();
  }

  Widget riskCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),

            const SizedBox(height: 8),

            Text(
              "$count",
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statisticCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.orange,
              size: 30,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget locationCard(
    Map<String, dynamic> location,
  ) {
    final String name =
        location["name"]?.toString() ??
            "Unknown";

    final String state =
        location["state"]?.toString() ??
            "";

    final String risk =
        location["risk"]?.toString() ??
            "UNKNOWN";

    final String score =
        location["score"]?.toString() ??
            "N/A";

    final String temperature =
        location["temperature"]?.toString() ??
            "N/A";

    final Color color =
        getRiskColor(risk);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                if (state.isNotEmpty)
                  Text(
                    state,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                const SizedBox(height: 5),

                Text(
                  "$temperature°C  •  Score $score/100",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              risk,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highestRiskLocations =
        getHighestRiskLocations();

    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "HEATGUARD Dashboard",
        ),
        backgroundColor:
            Colors.orange,
        foregroundColor:
            Colors.white,

        actions: [
          IconButton(
            onPressed: loadDashboard,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: "Refresh",
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 55,
                        color: Colors.red,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Text(
                        errorMessage!,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      ElevatedButton.icon(
                        onPressed:
                            loadDashboard,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          "Retry",
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh:
                      loadDashboard,

                  child: ListView(
                    padding:
                        const EdgeInsets.all(
                      15,
                    ),

                    children: [
                      const Text(
                        "India Heat Situation",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        "${locations.length} locations monitored",
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Row(
                        children: [
                          riskCard(
                            "Extreme",
                            getRiskCount(
                              "EXTREME",
                            ),
                            Colors.purple,
                            Icons.warning,
                          ),

                          riskCard(
                            "High",
                            getRiskCount(
                              "HIGH",
                            ),
                            Colors.red,
                            Icons.warning_amber,
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          riskCard(
                            "Moderate",
                            getRiskCount(
                              "MODERATE",
                            ),
                            Colors.orange,
                            Icons.thermostat,
                          ),

                          riskCard(
                            "Low",
                            getRiskCount(
                              "LOW",
                            ),
                            Colors.green,
                            Icons.check_circle,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(
                        "Key Conditions",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          statisticCard(
                            "Highest Temperature",
                            "${getHighestTemperature().toStringAsFixed(1)}°C",
                            Icons.thermostat,
                          ),

                          statisticCard(
                            "Highest Risk Score",
                            "${getHighestScore()}/100",
                            Icons.speed,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      const Text(
                        "Top Risk Locations",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      if (highestRiskLocations
                          .isEmpty)
                        const Center(
                          child: Padding(
                            padding:
                                EdgeInsets.all(
                              20,
                            ),
                            child: Text(
                              "No location data available.",
                            ),
                          ),
                        )
                      else
                        ...highestRiskLocations
                            .map(
                              (location) =>
                                  locationCard(
                                Map<String,
                                        dynamic>.from(
                                  location,
                                ),
                              ),
                            ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(
                        "HEATGUARD Prototype",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Text(
                        "Risk values are generated by the HEATGUARD prototype and are not official IMD warnings.",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
    );
  }
}