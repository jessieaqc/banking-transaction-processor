# Banking Transaction Processor

Esta pipeline simula un sistema antifraude en un banco. Las transacciones pasar por tres lambdas a través de Step Functions donde se valida la estructura del JSON, se le da un nivel de riesgo financiero y se envía a la carpeta correspondiente en S3. 

## ¿Qué hace el pipeline?

El sistema decide si una transacción es segura o sospechosa siguiendo estas reglas de negocio:

- **Aprobada** (`approved/`): esi el monto es menor o igual a 10000 y país de origen = `MX`
- **En revisión** (`review/`): si el monto es mayor a 10000 o es un país distinto a `MX` 
- **Fallida** (estado `Fail`): cuando los datos son inválidos (monto negativo, formato de cuenta incorrecto, o código de país mal formado)

## Arquitectura

```
Input JSON
     │
     ▼
┌──────────┐  INVALID  ┌──────────────────┐
│ Validate │ ────────► │ ValidationFailed │  (Fail)
└──────────┘           └──────────────────┘
     │ VALID
     ▼
┌─────────────┐
│ RiskAssess  │  Agrega: risk_level, risk_reasons
└─────────────┘
     │
     ▼
┌────────┐   low  -> s3://.../approved/<id>.json
│ Route  │   high -> s3://.../review/<id>.json
└────────┘
     │
     ▼
┌──────────────────────┐
│ TransactionProcessed │  (Succeed)
└──────────────────────┘
```

El Step Function tiene **6 estados**, **1 Choice**, **1 Fail** y **1 Succeed**.

## Lógica de cada Lambda

| Lambda | Campos que lee | Campos que agrega |
|---|---|---|
| `validate` | `amount`, `country`, `account`, `transaction_id` | `validation_status`, `validation_errors` |
| `risk_assess` | `amount`, `country` | `risk_level`, `risk_reasons` |
| `route` | `transaction_id`, `risk_level` | `s3_bucket`, `s3_key`, `routed_to` |

Cada lambda recibe el evento completo, le agrega sus campos y lo retorna. El Step Function pasa el resultado de cada Lambda a la siguiente usando `ResultPath: "$"`.

## Despliegue

### Paso 1: Bootstrap (solo la primera vez)

Crea el bucket S3 donde se guarda el state remoto de OpenTofu.

```bash
cd bootstrap
tofu init
tofu apply
```

### Paso 2: Proyecto principal

```bash
cd ../banking-jessi
tofu init
tofu apply
```

## Flujo CI/CD

```
┌──────────────────────┐
│ Pull request a main  │  ──►  tofu plan (solo verifica)
└──────────────────────┘

┌──────────────────────┐
│ Push a main          │  ──►  tofu plan + tofu apply
└──────────────────────┘
```

El workflow `.github/workflows/tofu.yml` requiere dos secrets en GitHub:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Ejecutar pruebas

```bash
SM_ARN=$(tofu output -raw state_machine_arn)
BUCKET=$(tofu output -raw s3_bucket_name)

# Caso 1: aprobada (monto bajo, pais MX)
aws stepfunctions start-execution --state-machine-arn $SM_ARN \
  --name "test-approved" \
  --input file://tests/test_approved.json

# Caso 2: revision por monto alto
aws stepfunctions start-execution --state-machine-arn $SM_ARN \
  --name "test-review-amount" \
  --input file://tests/test_review_high_amount.json

# Caso 3: revision por pais extranjero
aws stepfunctions start-execution --state-machine-arn $SM_ARN \
  --name "test-review-foreign" \
  --input file://tests/test_review_foreign.json

# Caso 4: falla por datos invalidos
aws stepfunctions start-execution --state-machine-arn $SM_ARN \
  --name "test-invalid" \
  --input file://tests/test_invalid.json

# verificar que los archivos cayeron en el prefijo correcto
aws s3 ls s3://$BUCKET/ --recursive
```


## Destruir recursos

```bash
cd banking-transaction-processor
tofu destroy

# si quieres eliminar bucket del state (bootstrap)
aws s3 rb s3://banking-jessi-state-quintero --force
```
