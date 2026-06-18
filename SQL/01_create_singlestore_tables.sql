--- CREACION DE TABLA DE VALIDOS ---
CREATE TABLE stg_bank_valid (
  age INT,
  job VARCHAR(20),
  marital VARCHAR(15),
  education VARCHAR(25),
  credit_default VARCHAR(10),
  housing VARCHAR(10),
  loan VARCHAR(10),
  contact VARCHAR(15),
  month VARCHAR(3),
  day_of_week VARCHAR(3),
  duration INT,
  campaign INT,
  pdays INT,
  previous INT,
  poutcome VARCHAR(15),
  emp_var_rate DOUBLE,
  cons_price_idx DOUBLE,
  cons_conf_idx DOUBLE,
  euribor3m DOUBLE,
  nr_employed DOUBLE,
  y VARCHAR(3),
  pdays_clean INT,
  was_previously_contacted VARCHAR(3),
  target_subscribed INT,
  dq_status VARCHAR(7),
  dq_error_reason VARCHAR(100)
);


--- CREACION DE TABLA DE RECHAZADOS ---
CREATE TABLE stg_bank_valid (
  age INT,
  job VARCHAR(20),
  marital VARCHAR(15),
  education VARCHAR(25),
  credit_default VARCHAR(10),
  housing VARCHAR(10),
  loan VARCHAR(10),
  contact VARCHAR(15),
  month VARCHAR(3),
  day_of_week VARCHAR(3),
  duration INT,
  campaign INT,
  pdays INT,
  previous INT,
  poutcome VARCHAR(15),
  emp_var_rate DOUBLE,
  cons_price_idx DOUBLE,
  cons_conf_idx DOUBLE,
  euribor3m DOUBLE,
  nr_employed DOUBLE,
  y VARCHAR(3),
  pdays_clean INT,
  was_previously_contacted VARCHAR(3),
  target_subscribed INT,
  dq_status VARCHAR(7),
  dq_error_reason VARCHAR(100),
  errorMessage VARCHAR(255)
);

--- VALIDACIONES DE TABLA DE VALIDOS Y RECHAZADOS ---
SELECT 'VALIDOS' AS estado, COUNT(*) AS cantidad
FROM stg_bank_valid
UNION ALL
SELECT 'RECHAZADOS', COUNT(*)
FROM stg_bank_rejected;

SELECT dq_error_reason, COUNT(*) AS cantidad
FROM stg_bank_rejected