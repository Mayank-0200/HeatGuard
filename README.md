# HEATGUARD

## Extreme Heatwave Early Warning System

HEATGUARD is a prototype heat-risk monitoring and early-warning system designed to monitor weather conditions, calculate thermal stress, identify high-risk locations, and provide alerts to users.

## Features

- GPS-based weather monitoring
- Thermal stress risk calculation
- Low / Moderate / High / Extreme risk levels
- 24-hour heat-risk monitoring
- Background monitoring
- Local heat alerts
- Firebase Cloud Messaging notifications
- India heat-risk map
- Multi-location district monitoring
- Risk dashboard
- Admin monitoring dashboard

## Project Structure

```text
kavach/
├── baackend/
│   ├── main.py
│   ├── weather.py
│   ├── heat_index.py
│   ├── imd_warning.py
│   └── requirements.txt
│
├── kavach_app/
│   ├── lib/
│   ├── android/
│   ├── pubspec.yaml
│   └── pubspec.lock
│
└── .gitignore


Current Progress
Day 1 — Backend weather and thermal-risk prototype ✅
Day 2 — Flutter application setup ✅
Day 3 — GPS and weather integration ✅
Day 4 — IMD integration preparation ✅
Day 5 — Background monitoring and alerts ✅
Day 6 — India heat-risk map and dashboards ✅
Day 7 — 24-hour heat-risk prediction 🚧

#Running the Backend
cd baackend
python -m venv venv

#Windows:
venv\Scripts\activate

#Install dependencies:
pip install -r requirements.txt

#Start the server:
uvicorn main:app --reload

#Running the Flutter App:
cd kavach_app
flutter pub get
flutter run

#Important Note

HEATGUARD is currently a prototype. The thermal stress score is a software-based prototype score and should not be treated as an official medical or heatwave warning index.

Official IMD warnings will be handled separately when IMD integration is implemented.

Future Development
Improved heat-risk prediction
Historical weather database
Machine-learning prediction
Official IMD integration
District-level warnings
Multiple Indian languages
Voice alerts
IoT sensor integration


