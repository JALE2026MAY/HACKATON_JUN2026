CREATE WAREHOUSE IF NOT EXISTS WH_UCI_BANK
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS DB_UCI_BANK;

USE DATABASE DB_UCI_BANK;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS DWH;
CREATE SCHEMA IF NOT EXISTS SCORING;

USE WAREHOUSE WH_UCI_BANK;
USE SCHEMA RAW;


CREATE OR REPLACE TABLE RAW.STG_BANK_VALID (
    age INT,
    job VARCHAR(13),
    marital VARCHAR(8),
    education VARCHAR(19),
    credit_default VARCHAR(7),
    housing VARCHAR(7),
    loan VARCHAR(7),
    contact VARCHAR(9),
    month VARCHAR(3),
    day_of_week VARCHAR(3),
    duration INT,
    campaign INT,
    pdays INT,
    previous INT,
    poutcome VARCHAR(11),

    emp_var_rate DOUBLE,
    cons_price_idx DOUBLE,
    cons_conf_idx DOUBLE,
    euribor3m DOUBLE,
    nr_employed DOUBLE,

    y VARCHAR(5),

    pdays_clean INT,
    was_previously_contacted VARCHAR(3),
    target_subscribed INT,
    dq_status VARCHAR(7),
    dq_error_reason VARCHAR(100),

    load_ts TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;
USE SCHEMA RAW;

SHOW TABLES LIKE 'STG_BANK_VALID';
-------------------------------------------------------------------
select * from STG_BANK_VALID;
-------------------------------------------------------------------
SELECT dq_status, COUNT(*) AS total
FROM RAW.STG_BANK_VALID
GROUP BY dq_status;

SELECT COUNT(*) AS total
FROM RAW.STG_BANK_VALID;
-----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;

-----CREA DIM CLIENT----
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

-----Comprobar----
SELECT COUNT(*) AS total_clientes
FROM DWH.DIM_CLIENT;

SELECT *
FROM DWH.DIM_CLIENT
LIMIT 10;

---------DIM CAMPIENG------
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

-----Comprobar----
SELECT COUNT(*) AS total_campanias
FROM DWH.DIM_CAMPAIGN;

SELECT *
FROM DWH.DIM_CAMPAIGN
LIMIT 10;

---------FACT CALLS------
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

-----Comprobar----
SELECT COUNT(*) AS registros_raw
FROM RAW.STG_BANK_VALID
WHERE dq_status = 'VALID';

SELECT COUNT(*) AS registros_fact
FROM DWH.FACT_CALLS;

-----Comprobar relaciones vacias----
SELECT
    COUNT(*) AS total_registros,
    COUNT_IF(client_key IS NULL) AS clientes_sin_clave,
    COUNT_IF(campaign_key IS NULL) AS campanias_sin_clave
FROM DWH.FACT_CALLS;

-------------------------------------------------------------
---Esquema Scoring-----
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;

CREATE SCHEMA IF NOT EXISTS SCORING;

-----------------------------------------
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

--------------Verificar Dataset-------------------------
SELECT COUNT(*) AS total_registros
FROM SCORING.BANK_PROPENSITY_DATASET;

SELECT *
FROM SCORING.BANK_PROPENSITY_DATASET
LIMIT 20;
-------------------------------------------------------
--------------Verificar Variable Obje-------------------------
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
----------------------Comprobar Nulos-------------------------------------------

SELECT
    COUNT_IF(age IS NULL) AS null_age,
    COUNT_IF(job IS NULL) AS null_job,
    COUNT_IF(pdays_clean IS NULL) AS null_pdays_clean,
    COUNT_IF(emp_var_rate IS NULL) AS null_emp_var_rate,
    COUNT_IF(cons_price_idx IS NULL) AS null_cons_price_idx,
    COUNT_IF(euribor3m IS NULL) AS null_euribor3m,
    COUNT_IF(target_subscribed IS NULL) AS null_target
FROM SCORING.BANK_PROPENSITY_DATASET;

----------------------------------------------------------------