def calculate_heat_index(temp_c, humidity):

    temp_f = (temp_c * 9 / 5) + 32

    heat_index_f = (
        -42.379
        + 2.04901523 * temp_f
        + 10.14333127 * humidity
        - 0.22475541 * temp_f * humidity
        - 0.00683783 * temp_f ** 2
        - 0.05481717 * humidity ** 2
        + 0.00122874 * temp_f ** 2 * humidity
        + 0.00085282 * temp_f * humidity ** 2
        - 0.00000199 * temp_f ** 2 * humidity ** 2
    )

    heat_index_c = (heat_index_f - 32) * 5 / 9

    return heat_index_c


def calculate_thermal_stress(
    temperature,
    humidity,
    wind_speed
):

    heat_index = calculate_heat_index(
        temperature,
        humidity
    )

    score = 0

    # Temperature
    if temperature >= 45:
        score += 40
    elif temperature >= 42:
        score += 35
    elif temperature >= 40:
        score += 25
    elif temperature >= 38:
        score += 15

    # Humidity
    if humidity >= 70:
        score += 25
    elif humidity >= 60:
        score += 20
    elif humidity >= 50:
        score += 15
    elif humidity >= 40:
        score += 10

    # Wind
    if wind_speed < 5:
        score += 15
    elif wind_speed < 10:
        score += 10

    # Heat index
    if heat_index >= 50:
        score += 20
    elif heat_index >= 45:
        score += 15
    elif heat_index >= 40:
        score += 10

    score = min(score, 100)

    if score >= 80:
        risk = "EXTREME"
    elif score >= 60:
        risk = "HIGH"
    elif score >= 40:
        risk = "MODERATE"
    else:
        risk = "LOW"

    return {
        "score": score,
        "risk": risk,
        "heat_index": round(heat_index, 1)
    }