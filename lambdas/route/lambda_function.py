# L3 Route: move to s3://bucket/approved/ or s3://bucket/review/.

import json
import logging
import os

import boto3 #kit oficial de aws para python 
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

#conexión para trabajar con s3
s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET_NAME"]


def lambda_handler(event, context):
    # imprime evento en cloudwatch 
    logger.info("Route recibio: %s", json.dumps(event))

    #datos del evento
    transaction_id: str = event["transaction_id"]
    risk_level: str = event["risk_level"]

    # se decide si va a carpeta reviw o approved 
    prefix = "review" if risk_level == "high" else "approved"

    # genera nombre del archivo en el bucket
    key = f"{prefix}/{transaction_id}.json"

    #se sube al bucket con el nombre de key y convierte a json
    try:
        s3.put_object(
            Bucket=BUCKET,
            Key=key,
            Body=json.dumps(event, indent=2),
            ContentType="application/json",
        )
    except ClientError as e:
        logger.error("Error al escribir en S3: %s", e.response["Error"]["Code"])
        raise

    logger.info(
        "Transaccion %s guardada en s3://%s/%s", transaction_id, BUCKET, key
    )

    #devuelve el evento y su ruta e info de almacenamiento en s3
    return {
        **event,
        "s3_bucket": BUCKET,
        "s3_key": key,
        "routed_to": prefix,
    }
