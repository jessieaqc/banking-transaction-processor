# L1 Validate: verify amount > 0, country with 2-letter ISO format, account with valid format.

import json
import logging
import re

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Validate recibio: %s", json.dumps(event))

    errors = []

    # verifica si AMOUNT falta, es num y mayor a 0
    amount = event.get("amount")
    if amount is None:
        errors.append("Falta el campo: amount")
    elif not isinstance(amount, (int, float)):
        errors.append("amount debe ser numerico")
    elif amount <= 0:
        errors.append("amount debe ser mayor a 0")

    # verifica que COUNTRY sea formato iso o si falta
    country = event.get("country")
    if country is None:
        errors.append("Falta el campo: country")
    elif not isinstance(country, str) or not re.fullmatch(r"[A-Z]{2}", country):
        errors.append("country debe ser codigo ISO de 2 letras mayusculas (ej. MX, US)")

    # verifica que ACCOUNT siga formato NNNN-NNNN o si falta
    account = event.get("account")
    if account is None:
        errors.append("Falta el campo: account")
    elif not isinstance(account, str) or not re.fullmatch(r"\d{4}-\d{4}", account):
        errors.append("account debe seguir el formato NNNN-NNNN (ej. 1234-5678)")

    # verifica que TRANSACTION_ID esté presente y no esté vacío
    if not event.get("transaction_id"):
        errors.append("Falta el campo: transaction_id")

    #devuelve errores si los hay, si no, devuelve validacion exitosa
    if errors:
        logger.warning("Validacion fallida: %s", errors)
        return {
            **event,
            "validation_status": "INVALID",
            "validation_errors": errors,
        }

    # si no hay errores, se considera validacion exitosa
    logger.info("Validacion exitosa para transaccion %s", event.get("transaction_id"))
    return {
        **event,
        "validation_status": "VALID",
        "validation_errors": [],
    }
