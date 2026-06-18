--- SELECCIONAR ENTORNO ---
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;

CREATE SCHEMA IF NOT EXISTS SCORING;
USE SCHEMA SCORING;

--- GUARDAR METRICA DEL MODELO SCORING ---
CREATE OR REPLACE TABLE SCORING.MODEL_EVALUATION_METRICS AS
WITH confusion AS (
    SELECT
        SUM(IFF(real_target = 1 AND predicted_target = 1, 1, 0)) AS tp,
        SUM(IFF(real_target = 0 AND predicted_target = 1, 1, 0)) AS fp,
        SUM(IFF(real_target = 1 AND predicted_target = 0, 1, 0)) AS fn,
        SUM(IFF(real_target = 0 AND predicted_target = 0, 1, 0)) AS tn
    FROM SCORING.BANK_TEST_PREDICTIONS
),
metrics AS (
    SELECT
        tp,
        fp,
        fn,
        tn,
        tp::FLOAT / NULLIF(tp + fp, 0) AS precision_value,
        tp::FLOAT / NULLIF(tp + fn, 0) AS recall_value
    FROM confusion
)
SELECT
    tp,
    fp,
    fn,
    tn,
    ROUND(precision_value, 4) AS precision,
    ROUND(recall_value, 4) AS recall,
    ROUND(
        2 * precision_value * recall_value
        / NULLIF(precision_value + recall_value, 0),
        4
    ) AS f1_score,
    CURRENT_TIMESTAMP() AS evaluation_ts
FROM metrics;

--- VALIDAR MODELO SCORING---
SELECT *FROM SCORING.MODEL_EVALUATION_METRICS;

--- GENERAR SCORING PARA TODOS LOS REGISTROS VALIDOS ---
CREATE OR REPLACE TABLE SCORING.BANK_ALL_SCORES AS

WITH predictions AS (
    SELECT
        src.call_key AS call_key,

        src.age,
        src.job,
        src.marital,
        src.education,
        src.credit_default,
        src.housing,
        src.loan,

        src.contact,
        src.month,
        src.day_of_week,
        src.campaign,
        src.pdays_clean,
        src.previous,
        src.poutcome,
        src.was_previously_contacted,

        src.emp_var_rate,
        src.cons_price_idx,
        src.euribor3m,

        src.target_subscribed AS real_target,

        SCORING.BANK_PROPENSITY_MODEL!PREDICT(
            INPUT_DATA => OBJECT_CONSTRUCT(
                'AGE', src.age,
                'JOB', src.job,
                'MARITAL', src.marital,
                'EDUCATION', src.education,
                'CREDIT_DEFAULT', src.credit_default,
                'HOUSING', src.housing,
                'LOAN', src.loan,
                'CONTACT', src.contact,
                'MONTH', src.month,
                'DAY_OF_WEEK', src.day_of_week,
                'CAMPAIGN', src.campaign,
                'PDAYS_CLEAN', src.pdays_clean,
                'PREVIOUS', src.previous,
                'POUTCOME', src.poutcome,
                'WAS_PREVIOUSLY_CONTACTED',
                    src.was_previously_contacted,
                'EMP_VAR_RATE', src.emp_var_rate,
                'CONS_PRICE_IDX', src.cons_price_idx,
                'EURIBOR3M', src.euribor3m
            )
        ) AS prediction_result

    FROM SCORING.BANK_PROPENSITY_DATASET src
)

SELECT
    call_key,

    age,
    job,
    marital,
    education,
    credit_default,
    housing,
    loan,

    contact,
    month,
    day_of_week,
    campaign,
    pdays_clean,
    previous,
    poutcome,
    was_previously_contacted,

    emp_var_rate,
    cons_price_idx,
    euribor3m,

    real_target,

    prediction_result:class::INTEGER
        AS predicted_target,

    prediction_result:probability:"1"::FLOAT
        AS probability_subscribed,

    ROUND(
        prediction_result:probability:"1"::FLOAT * 100,
        2
    ) AS propensity_score,

    CURRENT_TIMESTAMP() AS scoring_ts

FROM predictions;

--- VERIFICAR LA CANTIDAD DE SCORING---
SELECT COUNT(*) AS total_scored
FROM SCORING.BANK_ALL_SCORES;

--- VERIFICAR LOS PUNTAJES MÁS ALTOS DE SCORING---
SELECT
    call_key,
    age,
    job,
    predicted_target,
    probability_subscribed,
    propensity_score
FROM SCORING.BANK_ALL_SCORES
ORDER BY propensity_score DESC, call_key
LIMIT 10;

--- CREAR LISTA PRIORIZADA DEL 20% CON MAYOR PROPENSION ---
CREATE OR REPLACE TABLE SCORING.TOP_20_CALL_LIST AS

WITH ranked_scores AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY
                propensity_score DESC,
                probability_subscribed DESC,
                call_key ASC
        ) AS priority_rank,

        COUNT(*) OVER () AS total_records

    FROM SCORING.BANK_ALL_SCORES
)

SELECT
    priority_rank,
    call_key,

    age,
    job,
    marital,
    education,
    credit_default,
    housing,
    loan,

    contact,
    month,
    day_of_week,
    campaign,
    pdays_clean,
    previous,
    poutcome,
    was_previously_contacted,

    emp_var_rate,
    cons_price_idx,
    euribor3m,

    predicted_target,
    probability_subscribed,
    propensity_score,

    real_target,
    scoring_ts

FROM ranked_scores
WHERE priority_rank <= CEIL(total_records * 0.20);

--- REVISAR LOS PRIMEROS CLIENTES PRIORIZADOS ---
SELECT
    priority_rank,
    call_key,
    age,
    job,
    marital,
    education,
    housing,
    loan,
    campaign,
    pdays_clean,
    poutcome,
    propensity_score
FROM SCORING.TOP_20_CALL_LIST
ORDER BY priority_rank
LIMIT 20;