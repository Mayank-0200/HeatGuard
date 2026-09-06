import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';

class HeatMapScreen extends StatefulWidget {
  const HeatMapScreen({super.key});

  @override
  State<HeatMapScreen> createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends State<HeatMapScreen> {
  final MapController _mapController = MapController();

  // Heat-risk locations
  List<dynamic> locations = [];

  // User GPS location
  Position? currentPosition;

  bool isLoading = true;
  bool isGettingLocation = true;

  String? errorMessage;

  // Automatic refresh timer
  Timer? _refreshTimer;

  // Prevent automatic refresh from moving map
  bool _hasCenteredOnUser = false;

  @override
  void initState() {
    super.initState();

    loadMapData();

    // Refresh heat-risk data every 5 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) {
        loadMapData();
      },
    );
  }

  // --------------------------------------------------
  // LOAD MAP DATA
  // --------------------------------------------------

  Future<void> loadMapData() async {
    // Only show full loading screen when there is
    // no existing map data.
    if (locations.isEmpty && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    if (mounted) {
      setState(() {
        errorMessage = null;
      });
    }

    try {
      final districts = await ApiService.getDistricts();

      Position? position;

      try {
        position = await getCurrentLocation();
      } catch (e) {
        // Keep existing GPS location if location
        // temporarily fails.
        position = currentPosition;
      }

      if (!mounted) return;

      final bool shouldCenterMap =
          position != null && !_hasCenteredOnUser;

      setState(() {
        locations = districts;
        currentPosition = position;
        isLoading = false;
        isGettingLocation = false;
      });

      // Center map on user only once.
      if (shouldCenterMap) {
        _hasCenteredOnUser = true;

        Future.delayed(
          const Duration(milliseconds: 300),
          () {
            if (!mounted || currentPosition == null) {
              return;
            }

            _mapController.move(
              LatLng(
                currentPosition!.latitude,
                currentPosition!.longitude,
              ),
              6.5,
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isGettingLocation = false;
        errorMessage =
            "Could not load heat-risk data.";
      });
    }
  }

  // --------------------------------------------------
  // GPS LOCATION
  // --------------------------------------------------

  Future<Position> getCurrentLocation() async {
    final bool serviceEnabled =
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

    if (permission == LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      throw Exception(
        "Location permission denied.",
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  // --------------------------------------------------
  // RISK COLOR
  // --------------------------------------------------

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

  // --------------------------------------------------
  // RISK MARKER SIZE
  // --------------------------------------------------

  double getMarkerSize(String risk) {
    switch (risk.toUpperCase()) {
      case "EXTREME":
        return 50;

      case "HIGH":
        return 47;

      case "MODERATE":
        return 43;

      case "LOW":
        return 39;

      default:
        return 40;
    }
  }

  // --------------------------------------------------
  // DISTRICT DETAILS
  // --------------------------------------------------

  void showLocationDetails(
    Map<String, dynamic> location,
  ) {
    final String name =
        location["name"]?.toString() ?? "Unknown";

    final String state =
        location["state"]?.toString() ?? "";

    final String risk =
        location["risk"]?.toString() ?? "UNKNOWN";

    final String score =
        location["score"]?.toString() ?? "N/A";

    final String temperature =
        location["temperature"]?.toString() ?? "N/A";

    final String humidity =
        location["humidity"]?.toString() ?? "N/A";

    final String windSpeed =
        location["wind_speed"]?.toString() ?? "N/A";

    final String heatIndex =
        location["heat_index"]?.toString() ?? "N/A";

    final Color riskColor =
        getRiskColor(risk);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: riskColor,
                      size: 32,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          if (state.isNotEmpty)
                            Text(
                              state,
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        risk,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Score
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        riskColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thermostat,
                        color: riskColor,
                        size: 35,
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Prototype Thermal Stress Score",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          Text(
                            "$score / 100",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight:
                                  FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Temperature + humidity
                Row(
                  children: [
                    Expanded(
                      child: detailCard(
                        Icons.thermostat,
                        "Temperature",
                        "$temperature°C",
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: detailCard(
                        Icons.water_drop,
                        "Humidity",
                        "$humidity%",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Wind + heat index
                Row(
                  children: [
                    Expanded(
                      child: detailCard(
                        Icons.air,
                        "Wind",
                        "$windSpeed km/h",
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: detailCard(
                        Icons.device_thermostat,
                        "Heat Index",
                        "$heatIndex°C",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                const Text(
                  "Data from HEATGUARD weather analysis.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Prototype data — not an official IMD warning.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // DETAIL CARD
  // --------------------------------------------------

  Widget detailCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 25,
            color: Colors.orange,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // HEAT-RISK MARKER
  // --------------------------------------------------

  Marker buildMarker(
    Map<String, dynamic> location,
  ) {
    final double latitude =
        (location["latitude"] as num)
            .toDouble();

    final double longitude =
        (location["longitude"] as num)
            .toDouble();

    final String risk =
        location["risk"]?.toString() ??
            "UNKNOWN";

    final String name =
        location["name"]?.toString() ??
            "Unknown";

    final String score =
        location["score"]?.toString() ??
            "N/A";

    final Color color =
        getRiskColor(risk);

    final double iconSize =
        getMarkerSize(risk);

    return Marker(
      point: LatLng(
        latitude,
        longitude,
      ),
      width: 90,
      height: 78,
      child: GestureDetector(
        onTap: () {
          showLocationDetails(location);
        },
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            // Risk marker
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle for HIGH/EXTREME
                if (risk.toUpperCase() ==
                        "HIGH" ||
                    risk.toUpperCase() ==
                        "EXTREME")
                  Container(
                    width: iconSize + 12,
                    height: iconSize + 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          color.withOpacity(0.18),
                    ),
                  ),

                Icon(
                  Icons.location_on,
                  color: color,
                  size: iconSize,
                ),
              ],
            ),

            // District name + score
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(6),
                border: Border.all(
                  color: color,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    "$risk • $score",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight:
                          FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // USER LOCATION MARKER
  // --------------------------------------------------

  Marker buildMyLocationMarker() {
    return Marker(
      point: LatLng(
        currentPosition!.latitude,
        currentPosition!.longitude,
      ),
      width: 65,
      height: 65,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black38,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 22,
            ),
          ),

          Container(
            margin:
                const EdgeInsets.only(top: 2),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 3,
                  color: Colors.black26,
                ),
              ],
            ),
            child: const Text(
              "YOU",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 9,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LEGEND
  // --------------------------------------------------

  Widget buildLegend() {
    return Positioned(
      left: 12,
      bottom: 12,
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Heat Risk",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            legendItem(
              Colors.purple,
              "Extreme",
            ),

            legendItem(
              Colors.red,
              "High",
            ),

            legendItem(
              Colors.orange,
              "Moderate",
            ),

            legendItem(
              Colors.green,
              "Low",
            ),

            legendItem(
              Colors.blue,
              "Your Location",
            ),
          ],
        ),
      ),
    );
  }

  Widget legendItem(
    Color color,
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HEATGUARD India Map",
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // Go to GPS location
          IconButton(
            icon: const Icon(
              Icons.my_location,
            ),
            tooltip:
                "Go to my location",
            onPressed: () async {
              try {
                final position =
                    await getCurrentLocation();

                if (!mounted) return;

                setState(() {
                  currentPosition =
                      position;
                });

                _hasCenteredOnUser = true;

                _mapController.move(
                  LatLng(
                    position.latitude,
                    position.longitude,
                  ),
                  8.0,
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Unable to get your location.",
                    ),
                  ),
                );
              }
            },
          ),

          // Manual refresh
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: "Refresh",
            onPressed: loadMapData,
          ),
        ],
      ),

      body: Stack(
        children: [
          // ------------------------------------------------
          // MAP
          // ------------------------------------------------

          FlutterMap(
            mapController:
                _mapController,
            options: const MapOptions(
              initialCenter:
                  LatLng(22.5, 79.0),
              initialZoom: 4.8,
              minZoom: 4.0,
              maxZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName:
                    "com.example.kavach_app",
              ),

              MarkerLayer(
                markers: [
                  ...locations.map(
                    (location) =>
                        buildMarker(
                      Map<String, dynamic>.from(
                        location,
                      ),
                    ),
                  ),

                  if (currentPosition != null)
                    buildMyLocationMarker(),
                ],
              ),
            ],
          ),

          // ------------------------------------------------
          // LOADING
          // ------------------------------------------------

          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color:
                              Colors.orange,
                        ),

                        SizedBox(
                          height: 15,
                        ),

                        Text(
                          "Loading heat-risk data...",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ------------------------------------------------
          // ERROR
          // ------------------------------------------------

          if (errorMessage != null)
            Center(
              child: Card(
                margin:
                    const EdgeInsets.all(25),
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 50,
                        color: Colors.red,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        errorMessage!,
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      ElevatedButton.icon(
                        onPressed:
                            loadMapData,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          "Retry",
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange,
                          foregroundColor:
                              Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ------------------------------------------------
          // GPS STATUS
          // ------------------------------------------------

          if (!isLoading &&
              currentPosition != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: Colors.blue,
                      size: 17,
                    ),

                    SizedBox(width: 5),

                    Text(
                      "GPS Active",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ------------------------------------------------
          // LOCATION COUNT
          // ------------------------------------------------

          if (!isLoading &&
              locations.isNotEmpty)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Text(
                  "${locations.length} locations monitored",
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          // ------------------------------------------------
          // LEGEND
          // ------------------------------------------------

          if (!isLoading &&
              locations.isNotEmpty)
            buildLegend(),
        ],
      ),
    );
  }
}