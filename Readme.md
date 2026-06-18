# INEC_NBI

Proyecto Talend Studio para integrar, validar y preparar datos del INEC sobre necesidades básicas insatisfechas (NBI) y ENEMDU, cargando la información en Snowflake para su consumo analítico.

## Qué hace

Este proyecto automatiza la carga de archivos fuente, la estandarización de referencias y la ejecución de controles de calidad para dejar los datos listos para un modelo analítico tipo RAW / REF / MART.

En concreto:

- Carga personas y viviendas desde archivos CSV hacia tablas `RAW`.
- Carga catálogos y referencias geográficas / oficiales desde Excel hacia tablas `REF`.
- Ejecuta un proceso de calidad de datos sobre los registros cargados.
- Orquesta la preparación final del mart en Snowflake.

## Tecnologías

- Qlik Talend Cloud Enterprise Edition 8.0.1
- Snowflake
- Archivos CSV y Excel como fuentes de entrada
- Talend Data Quality para análisis y reglas de calidad

## Estructura del proyecto

```text
INEC_NBI/
├── context/
├── joblets/
├── metadata/
├── process/
├── TDQ_Data Profiling/
├── TDQ_Libraries/
└── sqlPatterns/
```

## Componentes principales

| Componente | Propósito |
| --- | --- |
| `JOB_PIPELINE_NBI` | Orquestador principal del flujo. Abre conexión con Snowflake, limpia tablas RAW y ejecuta la preparación final del mart. |
| `J01_LOAD_RAW_PERSONAS` | Lee `BDDenemdu_personas_2025_anual.csv` y carga `RAW.ENEMDU_PERSONAS`. |
| `J02_LOAD_RAW_VIVIENDA` | Lee `BDDenemdu_vivienda_2025_anual.csv` y carga `RAW.ENEMDU_VIVIENDA`. |
| `J03_LOAD_REF_DPA` | Lee `CODIFICACIÓN_2026.xlsx` y carga `REF.DPA_ECUADOR`. |
| `J04_LOAD_REF_NBI_OFICIAL` | Lee `nbi_oficial_inec_canton.xlsx` y carga `REF.NBI_OFICIAL_CANTON`. |
| `JOB_DQ` | Ejecuta reglas de calidad sobre datos en Snowflake y registra resultados / rechazados. |
| `JL_DQ` | Joblet reutilizable para capturar rechazados y métricas de calidad. |

## Flujo general

1. Se toma el contexto `context_inec`.
2. Se abre conexión con Snowflake.
3. Se ejecutan las cargas RAW de personas y viviendas.
4. Se procesan tablas de referencia desde Excel.
5. Se corre el proceso de calidad de datos.
6. Se ejecuta la preparación final del mart con Snowflake.

## Fuentes de datos

| Archivo | Uso |
| --- | --- |
| `BDDenemdu_personas_2025_anual.csv` | Fuente de personas. |
| `BDDenemdu_vivienda_2025_anual.csv` | Fuente de viviendas. |
| `CODIFICACIÓN_2026.xlsx` | Catálogo geográfico DPA. |
| `nbi_oficial_inec_canton.xlsx` | NBI oficial por cantón. |

## Tablas de salida

| Esquema | Tabla |
| --- | --- |
| `RAW` | `ENEMDU_PERSONAS` |
| `RAW` | `ENEMDU_VIVIENDA` |
| `REF` | `DPA_ECUADOR` |
| `REF` | `NBI_OFICIAL_CANTON` |

## Configuración

El proyecto usa un contexto llamado `context_inec` con variables como:

- `inec_path`
- `account`
- `user_id`
- `password`
- `warehouse`
- `database`
- `run_id`
- `run_ts`

Antes de ejecutar, ajusta estas variables según tu entorno.

## Requisitos

- Talend Studio o Qlik Talend Cloud compatible con el proyecto
- Acceso a Snowflake
- Archivos fuente ubicados en la ruta configurada en `inec_path`
- Permisos de escritura sobre las tablas destino

## Ejecución

La forma normal de uso es ejecutar el job principal `JOB_PIPELINE_NBI`.

Si necesitas validar por separado, también puedes correr:

- `J01_LOAD_RAW_PERSONAS`
- `J02_LOAD_RAW_VIVIENDA`
- `J03_LOAD_REF_DPA`
- `J04_LOAD_REF_NBI_OFICIAL`
- `JOB_DQ`

## Calidad de datos

El proyecto incluye análisis y reglas de calidad para detectar registros rechazados y registrar métricas de evaluación.

## Notas

- Los nombres de tablas y esquemas pueden variar si cambias el contexto.
- El proyecto está pensado para Snowflake como destino principal.
- Algunos assets de `TDQ_Data Profiling` y `TDQ_Libraries` sirven de soporte para las reglas de calidad.
