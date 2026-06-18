--- SELECCIONAR ENTORNO ---
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;

CREATE SCHEMA IF NOT EXISTS DWH;

-----CREACION DE DIMENSION CLIENTE----
CREATE OR REPLACE TABLE DWH.DIM_CLIENT AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            age,
            job,
            marital,
            education,
            credit_default,
            housing,
            loan
    ) AS client_key,
    age,
    job,
    marital,
    education,
    credit_default,
    housing,
    loan
FROM (
    SELECT DISTINCT
        age,
        job,
        marital,
        education,
        credit_default,
        housing,
        loan
    FROM RAW.STG_BANK_VALID
    WHERE dq_status = 'VALID'
);

--- VERIFICACION DE DIM_CLIENT ---
SELECT COUNT(*) AS total_clientes
FROM DWH.DIM_CLIENT;

SELECT *
FROM DWH.DIM_CLIENT
LIMIT 10;

-----CREACION DE DIMENSION CAMPAÑA----
CREATE OR REPLACE TABLE DWH.DIM_CAMPAIGN AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            contact,
            month,
            day_of_week,
            campaign,
            pdays_clean,
            previous,
            poutcome,
            was_previously_contacted
    ) AS campaign_key,
    contact,
    month,
    day_of_week,
    campaign,
    pdays_clean,
    previous,
    poutcome,
    was_previously_contacted
FROM (
    SELECT DISTINCT
        contact,
        month,
        day_of_week,
        campaign,
        pdays_clean,
        previous,
        poutcome,
        was_previously_contacted
    FROM RAW.STG_BANK_VALID
    WHERE dq_status = 'VALID'
);

--- VERIFICACION DIM_CAMPAIGN ---
SELECT COUNT(*) AS total_campanias
FROM DWH.DIM_CAMPAIGN;

SELECT *
FROM DWH.DIM_CAMPAIGN
LIMIT 10;


---- CREACION DE TABLA DE HECHOS: FACT_CALLS ----
CREATE OR REPLACE TABLE DWH.FACT_CALLS AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            c.client_key,
            ca.campaign_key,
            s.duration,
            s.target_subscribed
    ) AS call_key,

    c.client_key,
    ca.campaign_key,

    s.duration,
    s.emp_var_rate,
    s.cons_price_idx,
    s.cons_conf_idx,
    s.euribor3m,
    s.nr_employed,

    s.y,
    s.target_subscribed,
    CURRENT_TIMESTAMP() AS load_ts

FROM RAW.STG_BANK_VALID s

INNER JOIN DWH.DIM_CLIENT c
    ON EQUAL_NULL(c.age, s.age)
   AND EQUAL_NULL(c.job, s.job)
   AND EQUAL_NULL(c.marital, s.marital)
   AND EQUAL_NULL(c.education, s.education)
   AND EQUAL_NULL(c.credit_default, s.credit_default)
   AND EQUAL_NULL(c.housing, s.housing)
   AND EQUAL_NULL(c.loan, s.loan)

INNER JOIN DWH.DIM_CAMPAIGN ca
    ON EQUAL_NULL(ca.contact, s.contact)
   AND EQUAL_NULL(ca.month, s.month)
   AND EQUAL_NULL(ca.day_of_week, s.day_of_week)
   AND EQUAL_NULL(ca.campaign, s.campaign)
   AND EQUAL_NULL(ca.pdays_clean, s.pdays_clean)
   AND EQUAL_NULL(ca.previous, s.previous)
   AND EQUAL_NULL(ca.poutcome, s.poutcome)
   AND EQUAL_NULL(
       ca.was_previously_contacted,
       s.was_previously_contacted
   )

WHERE s.dq_status = 'VALID';

--- VERIFICACION FACT_CALLS --
SELECT COUNT(*) AS registros_raw
FROM RAW.STG_BANK_VALID
WHERE dq_status = 'VALID';

SELECT COUNT(*) AS registros_fact
FROM DWH.FACT_CALLS;