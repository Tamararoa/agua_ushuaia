# Diccionario de datos

**Proyecto:** Predicción del consumo diario de agua de Ushuaia **Autora:** Tamara Roa · Aprendizaje Automático · 2026

Las tablas de las plantas están en `data/processed/` y tienen una lectura cada 2 horas. La columna **¿Se usa?** indica si la variable entra al cálculo del consumo o a los modelos.

---

## 1\. Columnas comunes a las tres plantas

| Columna | Tipo | Unidad | Descripción | ¿Se usa? |
| :---- | :---- | :---- | :---- | :---- |
| `fecha_hora` | texto (fecha y hora) | UTC | Momento de la lectura. En el notebook se pasa a hora de Ushuaia | Sí |
| `turbidez_ntu` | decimal | NTU | Turbidez del agua cruda que ingresa a la planta | Sí |
| `turbidez_999` | verdadero/falso | — | Lectura en el tope del sensor (999 NTU): la turbidez real fue igual o mayor. Se conserva | Informativa |
| `caudal_ls_crudo` | decimal | L/s | Caudal de agua cruda que ingresa, tal como lo registró el sistema | No |
| `caudal_ls` | decimal | L/s | Caudal de ingreso corregido: las lecturas anómalas quedan sin dato | Sí |
| `caudal_anomalo` | verdadero/falso | — | Lectura de caudal sospechosa (cero o fuera del rango de operación) | Informativa |

## 2\. Planta 2 — `planta2_turbidez_cisternas_2h.csv`

13 columnas: las 6 comunes y estas 7\.

| Columna | Tipo | Unidad | Descripción | ¿Se usa? |
| :---- | :---- | :---- | :---- | :---- |
| `nivel_pct_a` | decimal | % | Nivel de la cisterna A | No (se usa el volumen) |
| `nivel_pct_b` | decimal | % | Nivel de la cisterna B. Tiene dos lecturas por encima del 100 % | No (se usa el volumen) |
| `vol_m3_a` | decimal | m³ | Volumen de la cisterna A (capacidad 5.000 m³) | Sí |
| `vol_m3_b` | decimal | m³ | Volumen de la cisterna B (capacidad 5.000 m³) | Sí |
| `vol_total_m3` | decimal | m³ | Suma de las cisternas con lectura en ese momento | No |
| `vol_total_completo` | verdadero/falso | — | Indica si todas las cisternas tenían lectura | No |
| `n_cisternas_validas` | entero | — | Cantidad de cisternas con lectura en ese momento | No |

**Volumen de la planta en el notebook:** `vol_m3_a + vol_m3_b`. Si falta una de las dos, queda sin dato.

## 3\. Planta 3 — `planta3_2h.csv`

23 columnas: las 6 comunes y estas 17\.

| Columna | Tipo | Unidad | Descripción | ¿Se usa? |
| :---- | :---- | :---- | :---- | :---- |
| `nivel_pct_400` … `nivel_pct_terrazas` | decimal | % | Nivel de cada cisterna (8 columnas: 400, 500, 640, 2000, 5000, lenadores, reinas y terrazas) | No (se usa el volumen) |
| `vol_m3_400` | decimal | m³ | Cisterna de 400 m³ | Sí |
| `vol_m3_500` | decimal | m³ | Cisterna de 500 m³ | Sí |
| `vol_m3_2000` | decimal | m³ | Cisterna de 2.000 m³ | Sí |
| `vol_m3_5000` | decimal | m³ | Cisterna de 5.000 m³ | Sí |
| `vol_m3_terrazas` | decimal | m³ | Cisterna Las Terrazas (100 m³) | Sí |
| `vol_m3_640` | decimal | m³ | Cisterna 640 (400 m³). 23 % sin dato | No |
| `vol_m3_lenadores` | decimal | m³ | Cisterna Antiguos Leñadores (500 m³). 23 % sin dato | No |
| `vol_m3_reinas` | decimal | m³ | Cisterna Las Reinas (500 m³). 24 % sin dato | No |
| `vol_obj_m3` | decimal | m³ | Suma de las cisternas 400, 500, 2000, 5000 y Las Terrazas | Sí |

**Volumen de la planta en el notebook:** `vol_obj_m3`. Las tres cisternas con registro parcial quedan afuera para que la serie sea comparable en todo el período.

## 4\. Planta 4 — `planta4_turbidez_cisternas_2h.csv`

13 columnas: las 6 comunes y estas 7\.

| Columna | Tipo | Unidad | Descripción | ¿Se usa? |
| :---- | :---- | :---- | :---- | :---- |
| `nivel_pct_principal` | decimal | % | Nivel de la cisterna principal | No (se usa el volumen) |
| `nivel_pct_costa_susana` | decimal | % | Nivel de la cisterna Costa Susana | No |
| `vol_m3_principal` | decimal | m³ | Volumen de la cisterna principal (1.250 m³) | Sí |
| `vol_m3_costa_susana` | decimal | m³ | Volumen de la cisterna Costa Susana (500 m³). 66 % sin dato | No |
| `vol_total_m3` | decimal | m³ | Suma de las cisternas con lectura en ese momento | No |
| `vol_total_completo` | verdadero/falso | — | Indica si todas las cisternas tenían lectura | No |
| `n_cisternas_validas` | entero | — | Cantidad de cisternas con lectura en ese momento | No |

**Volumen de la planta en el notebook:** `vol_m3_principal`.

## 5\. Clima — `data/raw/Temperatura, humedad y precipitaciones.xlsx`

Datos horarios del SMN, estación Ushuaia Aero. 4 columnas; en el notebook se renombran así:

| Columna | Tipo | Unidad | Descripción | ¿Se usa? |
| :---- | :---- | :---- | :---- | :---- |
| `fecha_hora` | fecha y hora | hora local | Momento de la observación (formato `dd.mm.aaaa hh:mm`) | Sí |
| `temp` | decimal | °C | Temperatura del aire | Sí |
| `hum` | decimal | % | Humedad relativa | Sí |
| `precip` | decimal | mm | Precipitación. 85,5 % sin dato | No |

---

## 6\. Variables del dataset diario (modelo)

Una fila por día. Todas las variables usan solo información disponible al cierre del día, salvo el objetivo `y`.

| Variable | Unidad | Descripción | Conjunto |
| :---- | :---- | :---- | :---- |
| `y` | m³ | **Objetivo:** consumo estimado del día siguiente | — |
| `cons_hoy` | m³ | Consumo estimado del día que termina | A |
| `cons_m7` | m³ | Promedio del consumo de los últimos 7 días | A |
| `cons_l7` | m³ | Consumo del mismo día de la semana que se predice, una semana antes | A |
| `dow_sig` | categoría (0 a 6\) | Día de la semana que se predice (one-hot en Ridge y KNN) | A |
| `mes` | categoría (1 a 12\) | Mes (one-hot en Ridge y KNN) | A |
| `turb_mean` | NTU | Turbidez media del día, promedio de las tres plantas | B |
| `turb_max` | NTU | Turbidez máxima del día entre las tres plantas | B |
| `turb_max3` | NTU | Turbidez máxima de los últimos 3 días | B |
| `caudal` | L/s | Caudal medio de ingreso del día, sumado entre las tres plantas | C |
| `vol_inicio` | m³ | Volumen almacenado a las 00:00 del día que termina, sumado entre las tres plantas | C |
| `temp_m` | °C | Temperatura media del día | D |
| `temp_min` | °C | Temperatura mínima del día | D |
| `temp_max` | °C | Temperatura máxima del día | D |
| `hum_m` | % | Humedad media del día | D |
| `temp_m3` | °C | Temperatura media de los últimos 3 días | D |

**Conjuntos de variables:** A (5 variables), B \= A \+ turbidez (8), C \= B \+ caudal y volumen (10) y D \= C \+ clima (15). El modelo elegido usa el conjunto C.