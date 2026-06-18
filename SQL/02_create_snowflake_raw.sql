--- SELECCIONAR ENTORNO ---
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;

--- CREACION DE TABLA / ESQUEMA RAW ---
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

--- VALIDACIONES ---
SELECT dq_status, COUNT(*) AS total
FROM RAW.STG_BANK_VALID
GROUP BY dq_status;

SELECT COUNT(*) AS total
FROM RAW.STG_BANK_VALID;