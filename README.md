# Predicción del consumo diario de agua de Ushuaia

Proyecto de aprendizaje automático supervisado (regresión) que estima el consumo diario de agua potable de Ushuaia y predice el consumo del día siguiente.

**Autora:** Tamara Roa **Curso:** Aprendizaje Automático — Tecnicatura en Ciencia de Datos e Inteligencia Artificial, Centro Politécnico Superior Malvinas Argentinas (2026)

**Video explicativo:** [Video explicativo](https://drive.google.com/file/d/183zkLtPc8Kj0szCyjNBgboiLMohBFL97/view?usp=drive_link)&nbsp;

---

## 1\. Problema

Ushuaia consume cerca de 44.000 m³ de agua por día y la abastecen tres plantas potabilizadoras: la 2, la 3 y la 4 (la Planta 1 está fuera de servicio). No existe una medición directa del consumo total de la ciudad. Anticipar el consumo del día siguiente ayuda a planificar la producción, el mantenimiento y los cortes de cada planta.

- **Tipo de problema:** supervisado, regresión.  
- **Unidad de observación:** un día de la ciudad (suma de las plantas 2, 3 y 4).  
- **Momento de predicción:** al cierre de cada día, solo con la información disponible hasta ese momento.  
- **Horizonte:** 24 horas.  
- **Variable a predecir:** consumo del día siguiente (m³/día), estimado por balance.

## 2\. Objetivos

**General:** estimar el consumo diario de agua de Ushuaia y predecir el del día siguiente con modelos de regresión.

**Específicos:**

1. Estimar el consumo diario por balance entre el agua que ingresa y la variación del volumen de las cisternas de las plantas 2, 3 y 4\.  
2. Explorar los datos y su relación con la turbidez, el caudal, el calendario y el clima.  
3. Comparar Ridge, Random Forest y KNN con tres reglas simples.  
4. Evaluar los modelos con MAE, RMSE y R² y analizar sus errores.  
5. Analizar, como complemento, qué pasa con las reservas de la Planta 3 después de un episodio de turbidez alta.

## 3\. Datos

|  | Telemetría de las plantas | Clima |
| :---- | :---- | :---- |
| **Fuente** | Dirección Provincial de Obras y Servicios Sanitarios (Tierra del Fuego) | Servicio Meteorológico Nacional, estación Ushuaia Aero |
| **Variables** | Turbidez del agua cruda (NTU), caudal de ingreso (L/s), nivel de cisternas | Temperatura, humedad (y precipitación, incompleta) |
| **Frecuencia** | Una lectura cada 2 horas | Horaria |
| **Período** | 01/01/2025 a 31/07/2026 (Planta 2 hasta el 31/08/2026) | 01/01/2025 a 06/11/2026 |
| **Registros** | 6.924 a 7.296 por planta | 16.055 |
| **Obtención** | Octubre de 2026 | Noviembre de 2026 |

Los datos de las plantas no tienen información de personas: son mediciones de las instalaciones. El detalle de cada columna está en [`docs/diccionario_datos.md`](http://docs/diccionario_datos.md).

**Archivos:**

- `data/raw/`: datos originales tal como se obtuvieron (plantas y clima).  
- `data/processed/`: tablas de cada planta con una lectura cada 2 horas, volumen de cisternas en m³ e indicadores de calidad (`caudal_anomalo` y `turbidez_999`).

## 4\. Estructura del repositorio

Organizado con la plantilla [Cookiecutter Data Science](https://cookiecutter-data-science.drivendata.org/).

```
agua_ushuaia/
├── agua_ushuaia/        # código del proyecto (módulo de Python)
├── data/
│   ├── raw/             # datos originales
│   └── processed/       # tablas de las plantas 2, 3 y 4 cada 2 h
├── docs/                # diccionario de datos y descripción del proyecto
├── models/
├── notebooks/
│   └── Consumo_agua_Ushuaia.ipynb   # análisis completo
├── references/
├── reports/
│   └── figures/         # gráficos generados por el notebook
├── Makefile
├── pyproject.toml
├── requirements.txt
└── README.md
```

## 5\. Cómo ejecutarlo

**En Google Colab:** subir la carpeta del proyecto a Google Drive como `MyDrive/agua_ushuaia`, abrir `notebooks/Consumo_agua_Ushuaia.ipynb` y elegir *Entorno de ejecución → Ejecutar todas*. El notebook monta Drive automáticamente.

**En una computadora:**

```sh
pip install -r requirements.txt
jupyter notebook notebooks/Consumo_agua_Ushuaia.ipynb
```

Si no está en Colab, el notebook toma como raíz la carpeta del proyecto.

Librerías principales: pandas, numpy, matplotlib y scikit-learn.

## 6\. Metodología

1. **Preprocesamiento:** paso de la hora universal a hora de Ushuaia. Los caudales anómalos se marcan y se dejan sin dato. Las lecturas de turbidez de 999 NTU se conservan, porque son el tope del sensor: la turbidez real fue igual o mayor. No se completa ningún faltante: los días incompletos quedan fuera.  
2. **Consumo por balance:** consumo del día \= agua que ingresa − variación del volumen de las cisternas.  
3. **Análisis exploratorio:** distribución, ritmo horario y semanal, feriados, meses y correlaciones.  
4. **Variables:** solo información disponible al cierre del día, en cuatro conjuntos: A (consumo pasado y calendario), B (+ turbidez), C (+ caudal y volumen almacenado) y D (+ clima). El día de la semana y el mes se codifican con one-hot.  
5. **Partición temporal:** entrenamiento hasta el 29/04/2026 (414 días) y prueba desde el 01/05/2026 (87 días).  
6. **Modelos (scikit-learn):** Ridge, Random Forest y KNN, con `Pipeline`, `RandomizedSearchCV` y validación cruzada temporal (`TimeSeriesSplit`, 5 particiones).  
7. **Elección y evaluación:** el modelo se elige por validación cruzada dentro del entrenamiento. La prueba se usa una sola vez, al final. Todo se compara con tres reglas simples: repetir el consumo de hoy, promedio de los últimos 7 días y mismo día de la semana anterior.

## 7\. Resultados

**Elección (validación cruzada, error absoluto medio en m³/día):**

| Modelo (mejor conjunto) | MAE |
| :---- | :---- |
| **Ridge (C)** | **1.112** |
| Random Forest (C) | 1.167 |
| KNN (C) | 1.210 |
| Repetir el consumo de hoy (mejor regla simple) | 1.228 |

**Evaluación final (período de prueba, 01/05 al 26/07/2026):**

|  | MAE (m³/día) | % del consumo medio | R² |
| :---- | :---- | :---- | :---- |
| **Ridge (C), modelo elegido** | **1.121** | 2,5 % | 0,35 |
| Repetir el consumo de hoy | 1.127 | 2,5 % | 0,20 |
| Promedio de 7 días | 1.091 | 2,4 % | 0,40 |

**Análisis complementario (Planta 3):** después de un episodio de turbidez alta (≥ 30 NTU), el volumen de las cisternas bajó en promedio 522 m³ más de lo habitual en 24 h (IC 95 %: 366 a 677 m³; 66 episodios).

## 8\. Conclusiones

- El consumo se puede estimar por balance, y la estimación es coherente con el ritmo diario de una ciudad.  
- El consumo es muy estable (≈ 44.000 m³/día, con una variación típica del 4,5 %). Por eso una regla simple ya es muy difícil de superar.  
- Ridge es el mejor de los tres modelos y mejora un 9,5 % a la mejor regla simple en la validación cruzada. En la prueba no la supera: esa ventaja no es firme.  
- Lo que más usa el modelo es el caudal de ingreso y el consumo reciente. La turbidez resta, y el calendario y el clima pesan poco.  
- La turbidez alta se asocia con una caída de las reservas en la Planta 3\. Es una asociación, no una causa.

**Limitaciones:** el consumo es una estimación y no una medición; hay 19 meses de datos y la prueba cubre solo 87 días de otoño-invierno; la precipitación no se usó por estar incompleta.

**Trabajo futuro:** sumar la precipitación y el pronóstico del día siguiente, predecir por franja horaria, predecir cuánto bajan las cisternas después de un episodio de turbidez y sumar más años de datos.

## 9\. Documentación

- 📄 [**`reports/informe_final.md`**](http://reports/informe_final.md): informe final del proyecto, con el contexto de las plantas potabilizadoras, los resultados y las conclusiones.**  
- [`docs/diccionario_datos.md`](http://docs/diccionario_datos.md): descripción de cada columna.

&nbsp;