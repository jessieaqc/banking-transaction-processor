# L2 RiskAssess: compute risk_level. It's high if amount > 10000 or country != "MX". It's low otherwise.

import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

HIGH_AMOUNT_THRESHOLD = 10_000
DOMESTIC_COUNTRY = "MX"


def lambda_handler(event, context):
    logger.info("RiskAssess recibio: %s", json.dumps(event))

    # se extraen datos del evento (establecido en json)
    amount: float = event["amount"]
    country: str = event["country"]
    transaction_id: str = event["transaction_id"]

    reasons = []

    if amount > HIGH_AMOUNT_THRESHOLD:
        reasons.append(f"monto {amount} supera el limite de {HIGH_AMOUNT_THRESHOLD}")

    if country != DOMESTIC_COUNTRY:
        reasons.append(f"transaccion extranjera: pais {country}")

    # si hay razones en la lista, es riesgo high, si no, es low
    risk_level = "high" if reasons else "low"

    #log de riesgo y razones
    logger.info(
        "Transaccion %s -> risk_level=%s, razones=%s",
        transaction_id,
        risk_level,
        reasons if reasons else "ninguna",
    )

    # se devuelve el evento mas el riesgo y sus razones
    return {
        **event,
        "risk_level": risk_level,
        "risk_reasons": reasons,
    }
