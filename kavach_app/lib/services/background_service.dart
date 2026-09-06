import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'api_service.dart';
import 'notification_service.dart';

const String heatRiskTask = "heatguard_background_check";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == heatRiskTask) {
        // Initialize notifications for the background task.
        await NotificationService.initialize(
          requestPermission: false,
        );

        // Check whether location services are enabled.
        final serviceEnabled =
            await Geolocator.isLocationServiceEnabled();

        if (!serviceEnabled) {
          return true;
        }

        // Check location permission.
        LocationPermission permission =
            await Geolocator.checkPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return true;
        }

        // Get the user's current location.
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        // Ask the HEATGUARD backend for the current heat risk.
        final data = await ApiService.getWeather(
          position.latitude,
          position.longitude,
        );

        // Read thermal stress information.
        final thermalStress = data["thermal_stress"];

        if (thermalStress == null) {
          return false;
        }

        final risk = thermalStress["risk"].toString();
        final score = "${thermalStress["score"]} / 100";

        // Store the last alert level.
        final prefs = await SharedPreferences.getInstance();
        final lastAlertRisk =
            prefs.getString("last_heat_alert_risk") ?? "NONE";

        // Send an alert only when the dangerous risk changes.
        if (risk == "HIGH" || risk == "EXTREME") {
          if (risk != lastAlertRisk) {
            await NotificationService.showHeatAlert(
              risk: risk,
              score: score,
            );

            await prefs.setString(
              "last_heat_alert_risk",
              risk,
            );
          }
        } else {
          // Risk is no longer dangerous.
          // Reset the alert state so a future HIGH/EXTREME
          // condition can trigger a new notification.
          await prefs.setString(
            "last_heat_alert_risk",
            "NONE",
          );
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  });
}

/// Starts normal 15-minute background monitoring.
Future<void> initializeBackgroundMonitoring() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await Workmanager().registerPeriodicTask(
    "heatguard_periodic_task",
    heatRiskTask,
    frequency: const Duration(minutes: 15),
  );
}