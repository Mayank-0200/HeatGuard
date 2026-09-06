import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> locations = [];

  bool loading = true;
  bool backendOnline = false;
  String lastUpdated = "Not available";

  @override
  void initState() {
    super.initState();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    setState(() {
      loading = true;
    });

    try {
      final data = await ApiService.getDistricts();

      if (!mounted) return;

      setState(() {
        locations = data;
        backendOnline = true;
        lastUpdated = TimeOfDay.now().format(context);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        backendOnline = false;
        loading = false;
      });
    }
  }

  int riskCount(String risk) {
    return locations.where((location) {
      return location["risk"]?.toString().toUpperCase() == risk;
    }).length;
  }

  dynamic highestRiskLocation() {
    if (locations.isEmpty) return null;

    final sorted = List<dynamic>.from(locations);

    sorted.sort((a, b) {
      final scoreA = (a["score"] as num).toDouble();
      final scoreB = (b["score"] as num).toDouble();

      return scoreB.compareTo(scoreA);
    });

    return sorted.first;
  }

  double highestTemperature() {
    if (locations.isEmpty) return 0;

    return locations
        .map((location) =>
            (location["temperature"] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  Color riskColor(String risk) {
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

  Widget statusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget riskRow(
    String name,
    String risk,
    int count,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "$count locations",
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highest = highestRiskLocation();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "HEATGUARD Admin",
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            onPressed: loadAdminData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadAdminData,

              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  const Text(
                    "System Monitoring",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "HEATGUARD operational overview",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BACKEND STATUS
                  statusCard(
                    title: "Backend Status",
                    value: backendOnline
                        ? "ONLINE"
                        : "OFFLINE",
                    icon: backendOnline
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    color: backendOnline
                        ? Colors.green
                        : Colors.red,
                  ),

                  const SizedBox(height: 12),

                  // LOCATIONS
                  statusCard(
                    title: "Locations Monitored",
                    value: "${locations.length}",
                    icon: Icons.location_on,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  // HIGHEST TEMP
                  statusCard(
                    title: "Highest Temperature",
                    value:
                        "${highestTemperature().toStringAsFixed(1)}°C",
                    icon: Icons.thermostat,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 12),

                  // ACTIVE ALERTS
                  statusCard(
                    title: "Active High/Extreme Alerts",
                    value:
                        "${riskCount("HIGH") + riskCount("EXTREME")}",
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 20),

                  // HIGHEST RISK
                  if (highest != null)
                    Container(
                      padding:
                          const EdgeInsets.all(18),

                      decoration:
                          BoxDecoration(
                        color: riskColor(
                          highest["risk"]
                              .toString(),
                        ).withOpacity(0.10),

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        border: Border.all(
                          color: riskColor(
                            highest["risk"]
                                .toString(),
                          ).withOpacity(0.3),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          const Text(
                            "Highest Risk Location",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            highest["name"]
                                .toString(),
                            style:
                                const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            highest["state"]
                                    ?.toString() ??
                                "",
                            style: TextStyle(
                              color: Colors
                                  .grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Score: ${highest["score"]}/100",
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          Text(
                            "Temperature: ${highest["temperature"]}°C",
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration:
                                BoxDecoration(
                              color: riskColor(
                                highest["risk"]
                                    .toString(),
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              highest["risk"]
                                  .toString(),
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // RISK DISTRIBUTION
                  Container(
                    padding:
                        const EdgeInsets.all(18),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black12,
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Risk Distribution",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        riskRow(
                          "Extreme",
                          "EXTREME",
                          riskCount("EXTREME"),
                          Colors.purple,
                        ),

                        riskRow(
                          "High",
                          "HIGH",
                          riskCount("HIGH"),
                          Colors.red,
                        ),

                        riskRow(
                          "Moderate",
                          "MODERATE",
                          riskCount("MODERATE"),
                          Colors.orange,
                        ),

                        riskRow(
                          "Low",
                          "LOW",
                          riskCount("LOW"),
                          Colors.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LAST UPDATE
                  Center(
                    child: Text(
                      "Last updated: $lastUpdated",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      "HEATGUARD Prototype • Not an official IMD system",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}