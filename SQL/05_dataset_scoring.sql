--- SELECCIONAR ENTORNO ---
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;

CREATE SCHEMA IF NOT EXISTS SCORING;


--- CREAR DATASET PARA MODELADO DE SCORING ---
CREATE OR REPLACE TABLE SCORING.BANK_PROPENSITY_DATASET AS
SELECT
    f.call_key,
    -- Características del cliente
    c.age,
    c.job,
    c.marital,
    c.education,
    c.credit_default,
    c.housing,
    c.loan,
    -- Características de la campaña
    ca.contact,
    ca.month,
    ca.day_of_week,
    ca.campaign,
    ca.pdays_clean,
    ca.previous,
    ca.poutcome,
    ca.was_previously_contacted,
    -- Variables económicas seleccionadas
    f.emp_var_rate,
    f.cons_price_idx,
    f.euribor3m,
    -- Variable objetivo
    f.target_subscribed

FROM DWH.FACT_CALLS f
INNER JOIN DWH.DIM_CLIENT c
    ON f.client_key = c.client_key
INNER JOIN DWH.DIM_CAMPAIGN ca
    ON f.campaign_key = ca.campaign_key;

--- VERIFICAR EL DATASET SCORING.BANK_PROPENSITY_DATASET ---
SELECT COUNT(*) AS total_registros
FROM SCORING.BANK_PROPENSITY_DATASET;

SELECT *FROM SCORING.BANK_PROPENSITY_DATASET
LIMIT 20;

--- VERIFICAR LA VARIABLE DE OBJETIVO ---
SELECT
    target_subscribed,
    COUNT(*) AS cantidad,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS porcentaje
FROM SCORING.BANK_PROPENSITY_DATASET
GROUP BY target_subscribed
ORDER BY target_subscribed;

--- REVISAR VALORES NULOS ---
SELECT
    COUNT_IF(age IS NULL) AS null_age,
    COUNT_IF(job IS NULL) AS null_job,
    COUNT_IF(pdays_clean IS NULL) AS null_pdays_clean,
    COUNT_IF(emp_var_rate IS NULL) AS null_emp_var_rate,
    COUNT_IF(cons_price_idx IS NULL) AS null_cons_price_idx,
    COUNT_IF(euribor3m IS NULL) AS null_euribor3m,
    COUNT_IF(target_subscribed IS NULL) AS null_target
FROM SCORING.BANK_PROPENSITY_DATASET;