import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'heat_map_screen.dart';
import 'dashboard_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final String email;

  const HomeScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? latitude;
  double? longitude;

  double? temperature;
  double? humidity;
  double? heatIndex;
  double? score;

  String risk = "UNKNOWN";

  String imdLevel = "NONE";
  String imdMessage =
      "Official IMD warning data is not connected yet.";

  String finalWarning = "UNKNOWN";
  String warningSource = "HEATGUARD";

  bool loading = false;

  List<dynamic> forecast = [];

  @override
  void initState() {
    super.initState();

    NotificationService.initialize();
  }

  // Get user's location and heat-risk information
  Future<void> checkHeatRisk() async {
    setState(() {
      loading = true;
    });

    try {
      // Check GPS
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          "Location services are disabled.",
        );
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          "Location permission denied.",
        );
      }

      if (permission ==
          LocationPermission.deniedForever) {
        throw Exception(
          "Location permission permanently denied.",
        );
      }

      // Get GPS position
      final position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = position.latitude;
      final lon = position.longitude;

      // Call FastAPI
      final data =
          await ApiService.getWeather(lat, lon);

      final weather =
          data["weather"] ?? {};

      final thermalStress =
          data["thermal_stress"] ?? {};

      final imdWarning =
          data["imd_warning"] ?? {};

      final finalWarningData =
          data["final_warning"] ?? {};

      setState(() {
        latitude = lat;
        longitude = lon;

        temperature =
            (weather["temperature_c"] as num?)
                ?.toDouble();

        humidity =
            (weather["humidity_percent"] as num?)
                ?.toDouble();

        heatIndex =
            (thermalStress["heat_index"] as num?)
                ?.toDouble();

        score =
            (thermalStress["score"] as num?)
                ?.toDouble();

        risk =
            thermalStress["risk"]?.toString() ??
                "UNKNOWN";

        imdLevel =
            imdWarning["level"]?.toString() ??
                "NONE";

        imdMessage =
            imdWarning["message"]?.toString() ??
                "No official IMD warning available.";

        finalWarning =
            finalWarningData["level"]
                    ?.toString() ??
                risk;

        warningSource =
            finalWarningData["source"]
                    ?.toString() ??
                "HEATGUARD";

        forecast =
            data["forecast_24h"] ?? [];

        loading = false;
      });

      // Send local notification for dangerous risk
      if (risk == "HIGH" ||
          risk == "EXTREME") {
        await NotificationService.showHeatAlert(
          risk: risk,
          score:
              "${score?.toStringAsFixed(0) ?? "N/A"} / 100",
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${e.toString()}",
          ),
        ),
      );
    }
  }

  Color getRiskColor(String value) {
    switch (value.toUpperCase()) {
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

  String getSafetyAdvice() {
    switch (risk.toUpperCase()) {
      case "EXTREME":
        return "Avoid prolonged outdoor activity. Stay in a cool place and drink water regularly.";

      case "HIGH":
        return "Limit prolonged outdoor activity. Stay hydrated and take frequent breaks.";

      case "MODERATE":
        return "Stay hydrated and take breaks during prolonged outdoor activity.";

      case "LOW":
        return "Normal outdoor activity is generally suitable. Stay hydrated.";

      default:
        return "Check your heat risk to receive safety advice.";
    }
  }

  Widget weatherCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
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
                fontSize: 18,
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

  Widget buildForecastCard(
    Map<String, dynamic> item,
  ) {
    final temperature =
        item["temperature_c"]?.toString() ??
            "N/A";

    final humidity =
        item["humidity_percent"]?.toString() ??
            "N/A";

    final wind =
        item["wind_speed_kmh"]?.toString() ??
            "N/A";

    String time =
        item["time"]?.toString() ?? "";

    if (time.contains("T")) {
      time = time.split("T").last;

      if (time.length >= 5) {
        time = time.substring(0, 5);
      }
    }

    return Container(
      width: 145,
      margin: const EdgeInsets.only(
        right: 10,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "$temperature°C",
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Humidity: $humidity%",
            style: const TextStyle(
              fontSize: 11,
            ),
          ),

          Text(
            "Wind: $wind km/h",
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = getRiskColor(risk);

    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "HEATGUARD",
        ),
        backgroundColor:
            Colors.orange,
        foregroundColor:
            Colors.white,

        actions: [
          // Dashboard
          IconButton(
            icon: const Icon(
              Icons.dashboard,
            ),
            tooltip: "Dashboard",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DashboardScreen(),
                ),
              );
            },
          ),

          // India Heat Map
          IconButton(
            icon: const Icon(
              Icons.map,
            ),
            tooltip: "India Heat Map",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const HeatMapScreen(),
                ),
              );
            },
          ),

          // Admin Dashboard
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings,
            ),
            tooltip: "Admin",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AdminScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: checkHeatRisk,

        child: ListView(
          padding:
              const EdgeInsets.all(16),

          children: [
            // Greeting
            Text(
              "Hello, ${widget.name} 👋",
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            if (widget.email.isNotEmpty)
              Text(
                widget.email,
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),

            const SizedBox(height: 20),

            // Check Heat Risk button
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed:
                    loading
                        ? null
                        : checkHeatRisk,

                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.thermostat,
                      ),

                label: Text(
                  loading
                      ? "CHECKING..."
                      : "CHECK HEAT RISK",
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orange,
                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Location
            if (latitude != null &&
                longitude != null)
              Container(
                padding:
                    const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 5,
                      color:
                          Colors.black12,
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            "Current Location",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            "${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}",
                            style:
                                TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            // Current conditions
            if (temperature != null)
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Conditions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      weatherCard(
                        "Temperature",
                        "${temperature!.toStringAsFixed(1)}°C",
                        Icons.thermostat,
                      ),

                      weatherCard(
                        "Humidity",
                        "${humidity?.toStringAsFixed(0) ?? "N/A"}%",
                        Icons.water_drop,
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 15),

            // Final warning
            if (temperature != null)
              Container(
                padding:
                    const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: riskColor
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color: riskColor
                        .withOpacity(0.3),
                  ),
                ),

                child: Column(
                  children: [
                    const Text(
                      "CURRENT HEAT RISK",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      risk,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      "Thermal Stress Score: ${score?.toStringAsFixed(0) ?? "N/A"} / 100",
                      style:
                          const TextStyle(
                        fontSize: 14,
                      ),
                    ),

                    if (heatIndex != null)
                      Text(
                        "Heat Index: ${heatIndex!.toStringAsFixed(1)}°C",
                        style:
                            const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            // Final warning source
            if (temperature != null)
              Container(
                padding:
                    const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 5,
                      color:
                          Colors.black12,
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color:
                          getRiskColor(
                        finalWarning,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            "Final Warning",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            finalWarning,
                            style: TextStyle(
                              color:
                                  getRiskColor(
                                finalWarning,
                              ),
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            "Source: $warningSource",
                            style:
                                TextStyle(
                              fontSize: 11,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            // Safety advice
            if (temperature != null)
              Container(
                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 5,
                      color:
                          Colors.black12,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Text(
                      "Safety Advice",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      getSafetyAdvice(),
                      style:
                          const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            // 24-hour forecast
            if (forecast.isNotEmpty)
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "24-Hour Forecast",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    height: 145,

                    child:
                        ListView.builder(
                      scrollDirection:
                          Axis.horizontal,

                      itemCount:
                          forecast.length,

                      itemBuilder:
                          (context, index) {
                        return buildForecastCard(
                          Map<String,
                                  dynamic>.from(
                            forecast[index],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 15),

            // IMD warning
            Container(
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 5,
                    color:
                        Colors.black12,
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Official IMD Warning",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    "Level: $imdLevel",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    imdMessage,
                    style: TextStyle(
                      color: Colors
                          .grey.shade700,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    "IMD integration is currently a placeholder and is not connected to live official warnings.",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Disclaimer
            const Text(
              "HEATGUARD is a prototype early-warning system. Thermal stress scores are experimental and should not be treated as official medical or meteorological advice.",
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}