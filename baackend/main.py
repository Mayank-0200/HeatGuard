from fastapi import FastAPI

from weather import (
    get_weather,
    get_multiple_weather,
)

from heat_index import calculate_thermal_stress
from imd_warning import get_imd_warning


app = FastAPI()


@app.get("/")
def home():
    return {
        "message": "HEATGUARD is working!"
    }


@app.get("/weather")
def weather(latitude: float, longitude: float):

    data = get_weather(
        latitude,
        longitude,
    )

    current = data["current"]

    temperature = current["temperature_2m"]
    humidity = current["relative_humidity_2m"]
    wind_speed = current["wind_speed_10m"]

    thermal_stress = calculate_thermal_stress(
        temperature,
        humidity,
        wind_speed,
    )

    imd_warning = get_imd_warning(
        latitude,
        longitude,
    )

    hourly = data["hourly"]

    forecast = []

    for i in range(
        min(24, len(hourly["time"]))
    ):
        forecast.append({
            "time": hourly["time"][i],
            "temperature_c": hourly["temperature_2m"][i],
            "humidity_percent": hourly["relative_humidity_2m"][i],
            "wind_speed_kmh": hourly["wind_speed_10m"][i],
        })

    heatguard_risk = thermal_stress.get(
        "risk",
        "UNKNOWN"
    )

    if imd_warning.get("active", False):

        final_risk = imd_warning.get(
            "level",
            heatguard_risk
        )

        warning_source = "IMD + HEATGUARD"

    else:

        final_risk = heatguard_risk
        warning_source = "HEATGUARD"

    return {
        "weather": {
            "temperature_c": temperature,
            "humidity_percent": humidity,
            "wind_speed_kmh": wind_speed,
        },

        "thermal_stress": thermal_stress,

        "imd_warning": imd_warning,

        "final_warning": {
            "level": final_risk,
            "source": warning_source,
        },

        "forecast_24h": forecast,
    }


@app.get("/districts")
def districts():

    # HEATGUARD monitoring locations
    locations = [

        {
            "name": "Delhi",
            "state": "Delhi",
            "latitude": 28.6139,
            "longitude": 77.2090,
        },

        {
            "name": "Jaipur",
            "state": "Rajasthan",
            "latitude": 26.9124,
            "longitude": 75.7873,
        },

        {
            "name": "Ahmedabad",
            "state": "Gujarat",
            "latitude": 23.0225,
            "longitude": 72.5714,
        },

        {
            "name": "Mumbai",
            "state": "Maharashtra",
            "latitude": 19.0760,
            "longitude": 72.8777,
        },

        {
            "name": "Bengaluru",
            "state": "Karnataka",
            "latitude": 12.9716,
            "longitude": 77.5946,
        },

        {
            "name": "Hyderabad",
            "state": "Telangana",
            "latitude": 17.3850,
            "longitude": 78.4867,
        },

        {
            "name": "Lucknow",
            "state": "Uttar Pradesh",
            "latitude": 26.8467,
            "longitude": 80.9462,
        },

        {
            "name": "Patna",
            "state": "Bihar",
            "latitude": 25.5941,
            "longitude": 85.1376,
        },

        {
            "name": "Kolkata",
            "state": "West Bengal",
            "latitude": 22.5726,
            "longitude": 88.3639,
        },

        {
            "name": "Chennai",
            "state": "Tamil Nadu",
            "latitude": 13.0827,
            "longitude": 80.2707,
        },

        {
            "name": "Chandigarh",
            "state": "Chandigarh",
            "latitude": 30.7333,
            "longitude": 76.7794,
        },

        {
            "name": "Amritsar",
            "state": "Punjab",
            "latitude": 31.6340,
            "longitude": 74.8723,
        },

        {
            "name": "Ludhiana",
            "state": "Punjab",
            "latitude": 30.9010,
            "longitude": 75.8573,
        },

        {
            "name": "Dehradun",
            "state": "Uttarakhand",
            "latitude": 30.3165,
            "longitude": 78.0322,
        },

        {
            "name": "Jammu",
            "state": "Jammu and Kashmir",
            "latitude": 32.7266,
            "longitude": 74.8570,
        },

        {
            "name": "Srinagar",
            "state": "Jammu and Kashmir",
            "latitude": 34.0837,
            "longitude": 74.7973,
        },

        {
            "name": "Kanpur",
            "state": "Uttar Pradesh",
            "latitude": 26.4499,
            "longitude": 80.3319,
        },

        {
            "name": "Agra",
            "state": "Uttar Pradesh",
            "latitude": 27.1767,
            "longitude": 78.0081,
        },

        {
            "name": "Varanasi",
            "state": "Uttar Pradesh",
            "latitude": 25.3176,
            "longitude": 82.9739,
        },

        {
            "name": "Bhopal",
            "state": "Madhya Pradesh",
            "latitude": 23.2599,
            "longitude": 77.4126,
        },

        {
            "name": "Indore",
            "state": "Madhya Pradesh",
            "latitude": 22.7196,
            "longitude": 75.8577,
        },

        {
            "name": "Nagpur",
            "state": "Maharashtra",
            "latitude": 21.1458,
            "longitude": 79.0882,
        },

        {
            "name": "Pune",
            "state": "Maharashtra",
            "latitude": 18.5204,
            "longitude": 73.8567,
        },

        {
            "name": "Surat",
            "state": "Gujarat",
            "latitude": 21.1702,
            "longitude": 72.8311,
        },

        {
            "name": "Rajkot",
            "state": "Gujarat",
            "latitude": 22.3039,
            "longitude": 70.8022,
        },

        {
            "name": "Bhubaneswar",
            "state": "Odisha",
            "latitude": 20.2961,
            "longitude": 85.8245,
        },

        {
            "name": "Guwahati",
            "state": "Assam",
            "latitude": 26.1445,
            "longitude": 91.7362,
        },

        {
            "name": "Ranchi",
            "state": "Jharkhand",
            "latitude": 23.3441,
            "longitude": 85.3096,
        },

        {
            "name": "Vijayawada",
            "state": "Andhra Pradesh",
            "latitude": 16.5062,
            "longitude": 80.6480,
        },

        {
            "name": "Kochi",
            "state": "Kerala",
            "latitude": 9.9312,
            "longitude": 76.2673,
        },
    ]

    # Get weather for all locations
    # using one optimized multi-location request
    weather_data = get_multiple_weather(
        locations
    )

    result = []

    for location, weather in zip(
        locations,
        weather_data
    ):

        current = weather.get(
            "current",
            {}
        )

        temperature = current.get(
            "temperature_2m"
        )

        humidity = current.get(
            "relative_humidity_2m"
        )

        wind_speed = current.get(
            "wind_speed_10m"
        )

        # Skip locations with incomplete data
        if (
            temperature is None
            or humidity is None
            or wind_speed is None
        ):
            continue

        thermal_stress = calculate_thermal_stress(
            temperature,
            humidity,
            wind_speed,
        )

        result.append({

            "name": location["name"],

            "state": location["state"],

            "latitude": location["latitude"],

            "longitude": location["longitude"],

            "temperature": temperature,

            "humidity": humidity,

            "wind_speed": wind_speed,

            "heat_index": thermal_stress.get(
                "heat_index"
            ),

            "score": thermal_stress.get(
                "score"
            ),

            "risk": thermal_stress.get(
                "risk"
            ),
        })

    # Risk priority
    # Higher number = higher danger
    risk_priority = {
        "EXTREME": 4,
        "HIGH": 3,
        "MODERATE": 2,
        "LOW": 1,
    }

    # Sort locations by:
    # 1. Risk level
    # 2. Thermal stress score
    result.sort(
        key=lambda location: (
            risk_priority.get(
                location.get("risk"),
                0
            ),
            location.get("score", 0),
        ),
        reverse=True,
    )

    return {
        "locations": result
    }