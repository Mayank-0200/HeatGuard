import requests


def get_weather(latitude, longitude):
    url = "https://api.open-meteo.com/v1/forecast"

    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": (
            "temperature_2m,"
            "relative_humidity_2m,"
            "wind_speed_10m"
        ),
        "hourly": (
            "temperature_2m,"
            "relative_humidity_2m,"
            "wind_speed_10m"
        ),
        "forecast_days": 2,
        "timezone": "auto",
    }

    response = requests.get(
        url,
        params=params,
        timeout=15,
    )

    if response.status_code != 200:
        raise Exception(
            f"Weather API request failed: "
            f"{response.status_code}"
        )

    return response.json()


def get_multiple_weather(locations):
    """
    Get weather for multiple locations
    using a single Open-Meteo request.
    """

    if not locations:
        return []

    latitudes = ",".join(
        str(location["latitude"])
        for location in locations
    )

    longitudes = ",".join(
        str(location["longitude"])
        for location in locations
    )

    url = "https://api.open-meteo.com/v1/forecast"

    params = {
        "latitude": latitudes,
        "longitude": longitudes,
        "current": (
            "temperature_2m,"
            "relative_humidity_2m,"
            "wind_speed_10m"
        ),
        "timezone": "auto",
    }

    response = requests.get(
        url,
        params=params,
        timeout=20,
    )

    if response.status_code != 200:
        raise Exception(
            f"Multiple weather API request failed: "
            f"{response.status_code}"
        )

    data = response.json()

    # Open-Meteo returns a list when multiple
    # coordinates are supplied.
    if isinstance(data, dict):
        data = [data]

    return data