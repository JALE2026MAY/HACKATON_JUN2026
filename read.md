# Olist Churn-Shield Retailer

Producto de datos orientado a retencion de clientes y segmentacion RFM para un contexto de comercio electronico basado en fuentes Olist. Esta documentacion resume el valor de negocio del producto y, al mismo tiempo, describe la implementacion real encontrada en el proyecto Talend `RETAIL_G4`.

## 1. Objetivo del producto

`Olist Churn-Shield Retailer` busca transformar datos transaccionales del ecosistema Olist en activos analiticos confiables para:

- anticipar churn o riesgo de abandono en horizontes de negocio definidos en el documento funcional
- soportar segmentacion RFM de clientes
- habilitar analitica comercial y operativa sobre fuentes consolidadas y trazables
- reforzar la confianza ejecutiva mediante reglas de calidad, linaje y gobierno

Problema de negocio principal: la organizacion no puede identificar con suficiente anticipacion que clientes abandonaran la plataforma ni que categorias o comportamientos estan asociados a esa fuga.

## 2. Resumen ejecutivo

Desde la perspectiva del PDF funcional, el producto aspira a combinar:

- valor de negocio: mejorar decisiones de retencion y priorizacion comercial
- valor tecnico: automatizar ingestion, limpieza, perfilado y modelado dimensional
- valor de gobierno: asegurar trazabilidad, ownership y calidad del dato
- valor analitico: preparar una base confiable para vistas certificadas y consumo BI

En el repositorio actual ya existe una implementacion Talend organizada por capas y orquestadores. La evidencia encontrada confirma una cadena tecnica principal:

`RAW -> Perfilado -> Limpieza/STG -> ELT Snowflake/MART`

## 3. Fuentes usadas para esta documentacion

Esta documentacion cruza dos fuentes de verdad con alcances distintos:

- PDF funcional: [Olist Churn-Shield Retailer.pdf](C:\Tmp\HACKATON_JUN2026\Olist Churn-Shield Retailer.pdf)
- Implementacion Talend: [RETAIL_G4](C:\Tmp\HACKATON_JUN2026\RETAIL_G4)

Regla aplicada:

- para narrativa de producto, proposito, valor y marco de gobierno, se toma como referencia el PDF
- para jobs, secuencia operativa, capas y configuracion tecnica, se prioriza el contenido real del repositorio Talend

## 4. Arquitectura logica end-to-end

### 4.1 Vision objetivo del producto

Segun el PDF, la arquitectura objetivo contempla:

- Talend como motor de orquestacion e integracion
- SingleStore como plataforma para capas iniciales y control de calidad
- Snowflake como destino analitico y capa MART
- OpenMetadata como catalogo, linaje y gobierno
- una herramienta BI para consumo ejecutivo sobre vistas certificadas

Nota importante: el PDF menciona OpenMetadata y BI como parte del marco completo del producto. En este repositorio se valida con claridad la implementacion Talend y la preparacion tecnica hacia SingleStore y Snowflake, pero no toda la capa de gobierno o consumo final aparece materializada aqui.

### 4.2 Flujo tecnico implementado en el repositorio

El orquestador principal del proyecto es `Grupo4_Retail_Super_Orquestador`. Su secuencia real encadena cuatro bloques:

1. `Grupo4_Retail_orquestador`
2. `Grupo4_Retail_perfilado`
3. `Grupo4_Retail_job_orquestador_clean`
4. `Grupo4_Retail_orquestador_snowflake`

Interpretacion funcional del flujo:

- `Grupo4_Retail_orquestador`: carga inicial de fuentes hacia la capa RAW
- `Grupo4_Retail_perfilado`: revision estructural y exploratoria de la calidad del dato
- `Grupo4_Retail_job_orquestador_clean`: limpieza, estandarizacion y poblamiento de staging
- `Grupo4_Retail_orquestador_snowflake`: construccion del modelo analitico final en Snowflake

## 5. Estructura del proyecto Talend

La raiz del proyecto contiene carpetas tipicas de Talend y, en particular, una organizacion de procesos alineada al producto:

- `process/RETAIL_OLIST_G4`
- `context`
- `metadata`
- `documentations`
- `joblets`
- `components`
- `tests`

Dentro de `process/RETAIL_OLIST_G4` se identifican cuatro grupos principales:

- `Ingesta_RETAIL_OLIST_G4`
- `Perfilado_RETAIL_OLIST_G4`
- `Limpieza_RETAIL_OLIST_G4`
- `ELT_Snowflake_RETAIL_OLIST_G4`

Esta estructura refleja una separacion por responsabilidad y facilita tanto la lectura del flujo como el mantenimiento del pipeline.

## 6. Capas de datos y proposito

### 6.1 Capa RAW

Responsable de cargar archivos fuente sin mayor transformacion inicial. El proyecto apunta a datasets del ecosistema Olist, entre ellos:

- customers
- geolocation
- orders
- order_items
- payments
- reviews
- products
- product_category
- sellers

### 6.2 Capa de perfilado y calidad

Responsable de inspeccionar estructura, completitud y consistencia de los datos antes de consolidar transformaciones de negocio. Esta capa se alinea con el marco de calidad del PDF, aunque el detalle normativo completo del contrato no esta embebido integramente en este README.

### 6.3 Capa STG / limpieza

Responsable de normalizar, depurar y preparar informacion confiable para la explotacion analitica. En el repositorio se observa que el orquestador de limpieza tambien ejecuta truncados y cargas hacia tablas de staging en SingleStore.

### 6.4 Capa MART / Snowflake

Responsable de construir hechos y dimensiones analiticas para consumo posterior. Esta capa representa el paso desde datos integrados hacia un modelo dimensional orientado a consulta y analitica.

## 7. Inventario funcional de jobs

### 7.1 Orquestadores principales

- `Grupo4_Retail_Super_Orquestador`: punto central de ejecucion del pipeline
- `Grupo4_Retail_orquestador`: orquestador de ingesta RAW
- `Grupo4_Retail_job_orquestador_clean`: orquestador de limpieza y staging
- `Grupo4_Retail_orquestador_snowflake`: orquestador de modelado final en Snowflake
- `Grupo4_Retail_perfilado`: proceso central de perfilado
- `Grupo4_Retail_perfilado_por_tabla`: perfilado orientado por entidad

### 7.2 Jobs de ingesta RAW

Se identifican jobs para la carga inicial de:

- `customers`
- `geolocation`
- `orders`
- `order_items`
- `order_payments`
- `order_review`
- `products`
- `product_category`
- `seller`

### 7.3 Jobs de limpieza / estandarizacion

Se identifican jobs de limpieza para:

- `customers`
- `geolocation`
- `orders`
- `order_items`
- `order_payments`
- `order_review`
- `products`
- `product_category`
- `sellers`
- `scoring`

Observacion: el job `scoring` sugiere una etapa especifica de evaluacion o consolidacion ligada a calidad o preparacion analitica.

### 7.4 Jobs de modelado en Snowflake

Se identifican procesos para poblar al menos los siguientes objetos analiticos:

- `dim_customer`
- `dim_date`
- `dim_product`
- `dim_review`
- `dim_seller`
- `fact_orders`
- `fact_customer_rfm`
- `fact_churn`
- `fact_churn_snapshot`

Esto confirma que el proyecto no se limita a ingestion ETL, sino que ya contempla una salida dimensional de negocio.

## 8. Contextos y configuracion requerida

El proyecto contiene variables de contexto operativas para conexiones, entorno y rutas. Por seguridad, en esta documentacion no se publican valores reales ni credenciales.

### 8.1 Contextos funcionales esperados

- `olist_path`: ruta de archivos fuente
- `run_id`: identificador de corrida
- `env`: entorno de ejecucion

### 8.2 Contextos asociados a SingleStore

- `ss_host`
- `ss_port`
- `ss_db`
- `ss_db_stg`
- `ss_db_mart`
- `ss_db_audit`
- `ss_user`
- `ss_password`

### 8.3 Contextos asociados a Snowflake

- `sn_account`
- `sn_database`
- `sn_user_id`
- `sn_password`
- `sn_warehouse`

### 8.4 Politica de documentacion segura

- no copiar passwords ni tokens
- no publicar hosts, cuentas ni identificadores completos sensibles
- documentar solo nombres de variables y su proposito
- usar placeholders en cualquier manual operativo derivado

## 9. Calidad de datos y gobierno

### 9.1 Lo que plantea el producto

El PDF define un marco de calidad basado en seis dimensiones:

- completitud
- precision o exactitud
- consistencia
- validez
- unicidad
- oportunidad

Tambien plantea:

- ownership y roles
- glosario y tags
- linaje extremo a extremo
- politicas de uso permitido y uso prohibido
- vistas certificadas para consumo analitico

### 9.2 Lo que se confirma en el repositorio

En el proyecto Talend si se confirma:

- una capa de perfilado
- jobs especificos de limpieza
- separacion por capas de procesamiento
- componentes que apuntan a RAW, STG, MART y auditoria

En cambio, no se confirma de forma completa en este repositorio:

- configuracion operativa de OpenMetadata
- dashboards BI finales
- data contract formal como artefacto versionado dentro del repo
- SLA monitorizados externamente

Por eso, estos ultimos deben entenderse como parte del marco funcional y de la arquitectura objetivo, no como elementos totalmente implementados aqui.

## 10. Como leer y ejecutar el proyecto

### 10.1 Orden recomendado para entenderlo

1. Revisar el super orquestador para entender la secuencia completa.
2. Revisar los orquestadores por capa.
3. Revisar los jobs por dataset.
4. Revisar contextos y conexiones.
5. Revisar la salida dimensional en Snowflake.

### 10.2 Punto de entrada tecnico

El mejor punto de entrada para la lectura del flujo es:

- [Grupo4_Retail_Super_Orquestador_0.1.item](C:\Tmp\HACKATON_JUN2026\RETAIL_G4\process\RETAIL_OLIST_G4\Grupo4_Retail_Super_Orquestador_0.1.item)

### 10.3 Requisitos practicos para operar

Para ejecutar o migrar este proyecto de forma controlada, se requiere:

- Talend Studio compatible con la version del proyecto
- acceso a las rutas de archivos fuente
- credenciales validas para SingleStore
- credenciales validas para Snowflake
- validacion previa de contextos por entorno

Recomendacion: nunca ejecutar directamente con contextos productivos sin revisar variables, rutas y dependencias externas.

## 11. Limitaciones y supuestos

- Este README documenta el estado observable del proyecto Talend y el marco funcional del PDF.
- No sustituye un runbook de despliegue ni una guia detallada de soporte operativo.
- La presencia de nombres de jobs o contextos no implica que todas las dependencias externas sigan activas.
- Algunas piezas del producto de datos, como OpenMetadata, BI certificado o contratos de datos firmados, aparecen como alcance esperado del producto pero no necesariamente como configuracion implementada dentro de este repositorio.

## 12. Siguientes pasos recomendados

- completar un runbook tecnico de ejecucion por entorno
- documentar mappings de tablas RAW, STG y MART
- versionar reglas de calidad de datos fuera del PDF, idealmente como artefactos tecnicos reutilizables
- formalizar catalogo, glosario y linaje en la herramienta de gobierno elegida
- vincular este README con evidencia de pruebas, validaciones de calidad y entregables BI

## 13. Referencias

- Documento funcional: [Olist Churn-Shield Retailer.pdf](C:\Tmp\HACKATON_JUN2026\Olist Churn-Shield Retailer.pdf)
- Proyecto Talend: [RETAIL_G4](C:\Tmp\HACKATON_JUN2026\RETAIL_G4)
- Orquestador principal: [Grupo4_Retail_Super_Orquestador_0.1.item](C:\Tmp\HACKATON_JUN2026\RETAIL_G4\process\RETAIL_OLIST_G4\Grupo4_Retail_Super_Orquestador_0.1.item)
