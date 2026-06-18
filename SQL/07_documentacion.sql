--- SELECCIONAR ENTORNO ---
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_UCI_BANK;
USE DATABASE DB_UCI_BANK;

COMMENT ON TABLE RAW.STG_BANK_VALID IS
'Datos válidos provenientes de SingleStore y cargados mediante Talend.';

COMMENT ON TABLE DWH.DIM_CLIENT IS
'Dimensión con atributos demográficos y financieros del perfil del cliente.';

COMMENT ON TABLE DWH.DIM_CAMPAIGN IS
'Dimensión con información del contacto y antecedentes de campaña.';

COMMENT ON TABLE DWH.FACT_CALLS IS
'Tabla de hechos de llamadas bancarias, resultado real y variables económicas.';

COMMENT ON TABLE SCORING.BANK_PROPENSITY_DATASET IS
'Dataset analítico para entrenamiento y evaluación. Duration está excluida como predictor.';

COMMENT ON TABLE SCORING.BANK_TEST_PREDICTIONS IS
'Predicciones realizadas sobre el 20 por ciento reservado para prueba.';

COMMENT ON TABLE SCORING.MODEL_EVALUATION_METRICS IS
'Métricas del modelo: matriz de confusión, precision, recall y F1.';

COMMENT ON TABLE SCORING.BANK_ALL_SCORES IS
'Scoring de propensión entre 0 y 100 para los 41183 registros válidos.';

COMMENT ON TABLE SCORING.TOP_20_CALL_LIST IS
'Lista priorizada del 20 por ciento con mayor probabilidad de suscripción.';

SHOW TABLES IN DATABASE DB_UCI_BANK;