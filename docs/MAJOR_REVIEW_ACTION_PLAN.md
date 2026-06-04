# Plan de Acción — Major Review
## Paper: "Virtual Machine Consolidation in Cloud Computing based on Facebook Prophet Forecasting Neural-Network"
### Journal: Future Generation Computer Systems (Elsevier)
### Fecha de elaboración: 2026-06-02

---

## Resumen ejecutivo

El paper ha recibido una **Major Revision** con comentarios de dos revisores y anotaciones propias del autor identificadas durante la preparación del manuscrito. El plan siguiente organiza todas las acciones en orden de prioridad y esfuerzo estimado, distinguiendo claramente entre cambios puramente textuales, análisis de datos ya disponibles y experimentos nuevos que requieren ejecución computacional.

La propuesta **WBF** (WPSP + Bollinger Bands + Facebook Prophet) ya demuestra resultados sólidos: -10% energía, -25..60% SLA, -45..70% migraciones respecto a técnicas clásicas. El objetivo de la revisión es fortalecer la narrativa científica, la formalización matemática y la comparación con el estado del arte reciente, no cambiar la contribución técnica central.

---

## Sección 1: Tabla principal de acciones

| ID | Origen | Comentario / Problema | Acción propuesta | Tipo | Prioridad | Esfuerzo (días) | Estado |
|----|--------|----------------------|------------------|------|-----------|-----------------|--------|
| R1-01 | Revisor 1 | Contribución percibida como pequeña; falta diferenciación clara respecto a trabajos recientes de predicción en cloud | Redactar párrafo de contribuciones explícitas en la introducción: 3 bullets con lo que WBF aporta que no existía; añadir tabla de comparación de características vs. trabajos relacionados | Reescritura | Alta | 2 | Pendiente |
| R1-02 | Revisor 1 | Falta comparación con papers recientes: [A] Prophet for Cloud, [B] VM migration survey, [C] ML Necessary | Leer los 3 papers, extraer sus métricas comparables, posicionar WBF en las tablas de resultados existentes y añadir citas en Related Work y Discussion | Análisis + Texto | Alta | 3 | Pendiente |
| R1-03 | Revisor 1 / Autor | Sección 4.3 incompleta — falta descripción de cómo funciona Facebook Prophet como red neuronal, entrenamiento, cross-validation, hiperparámetros | Reescribir 4.3 completo: arquitectura de Prophet (componentes tendencia + estacionalidad + festivos), proceso de entrenamiento MAP/MCMC, cross-validation con horizon/period/initial, selección de hiperparámetros relevantes para el contexto cloud | Reescritura | Alta | 3 | Pendiente |
| R1-04 | Revisor 1 | Analogía stock market / Bollinger Bands insuficientemente justificada para el contexto cloud | Añadir subsección con evidencia empírica: mostrar que las series temporales de uso de CPU en cloud tienen propiedades estadísticas (autocorrelación, volatilidad) similares a las series financieras; citar estudios de caracterización de workloads cloud | Análisis + Texto | Alta | 2 | Pendiente |
| R1-05 | Revisor 1 | Grammar y estilo — revisión de inglés técnico completa | Revisión nativa del manuscrito completo con herramienta Grammarly/LanguageTool + corrección manual de términos técnicos cloud; especial atención a consistencia de terminología (host/server/machine) | Texto | Media | 2 | Pendiente |
| R1-06 | Autor | Código fuente debe estar accesible desde el inicio del paper (URL bitbucket en introducción) | Añadir URL pública del repositorio en la introducción y en la sección de experimental setup; verificar que el repositorio es público y contiene README con instrucciones de reproducción | Texto | Alta | 0.5 | Pendiente |
| R2-01 | Revisor 2 | WBF no está definido formalmente al principio del paper | Añadir en Abstract y en la primera mención del método: "WBF (WPSP + Bollinger Bands + Facebook Prophet)"; añadir caja de definición formal en Sección 3 o al inicio de Sección 4 | Texto | Alta | 0.5 | Pendiente |
| R2-02 | Revisor 2 | BF(h) y WBF(H0) sin definición formal en el texto | Definir BF(h) como "Bollinger Filter aplicado al host h" y WBF(H0) como "WBF aplicado al conjunto de hosts H0"; añadir notación formal en la sección de metodología con ecuaciones explícitas | Texto + Reescritura | Alta | 1 | Pendiente |
| R2-03 | Autor | Título de Sección 4 incorrecto semánticamente ("El títol no sembla correcte") | Revisar el título actual de la Sección 4 y proponer 3 alternativas; seleccionar la que mejor describe el contenido (metodología WBF + componentes); actualizar TOC y referencias internas | Texto | Media | 0.5 | Pendiente |
| R2-04 | Revisor 2 | Secciones mal organizadas — background mezclado con método; estructura no sigue convención IMRaD | Reorganizar manuscrito: Sección 2 = Related Work, Sección 3 = Background (solo fundamentos teóricos), Sección 4 = Methodology (WBF completo), Sección 5 = Experimental Setup, Sección 6 = Results, Sección 7 = Discussion, Sección 8 = Conclusions | Reescritura | Alta | 3 | Pendiente |
| R2-05 | Revisor 2 / Autor | Algoritmo 1 no explicado paso a paso; pseudocódigo insuficiente para reproducibilidad | Reescribir el Algoritmo 1: añadir comentarios en cada bloque, expandir condiciones de guard, explicar en texto corrido qué hace cada fase (detección de sobrecarga, selección WPSP, filtro BB, predicción FP, decisión de migración) | Reescritura | Alta | 2 | Pendiente |
| R2-06 | Revisor 2 | Proceso de migración vago — falta diagrama de flujo y descripción detallada | Crear figura de diagrama de flujo (flowchart) del proceso WBF completo: desde detección de host sobrecargado hasta ejecución de migración; descripción textual acompañando el diagrama | Análisis + Texto | Alta | 2 | Pendiente |
| R2-07 | Revisor 2 | Resultados solo descriptivos — falta análisis cuantitativo de trade-offs (energía vs SLA, etc.) | Añadir en Discussion: (1) análisis cuantitativo de trade-offs energía-SLA-migraciones, (2) por qué WBF sacrifica ligera energía vs WF en Alibaba/Materna/Azure pero gana en SLA, (3) tabla resumen de rankings por workload | Análisis + Texto | Alta | 2 | Pendiente |
| R2-08 | Revisor 2 | Datasets insuficientemente descritos — falta preprocessing exacto, filtros aplicados, número de VMs por trace | Ampliar Sección 5 (Experimental Setup): para cada dataset (PlanetLab, Alibaba 2018, Materna, Azure 2019) describir: origen, granularidad temporal, filtros aplicados, número de VMs usadas, preprocesamiento (normalización, imputación), ventanas temporales | Texto | Alta | 2 | Pendiente |
| R2-09 | Revisor 2 | Falta sección de limitaciones en conclusiones | Añadir subsección "Limitations" en Conclusions: (1) dependencia de calidad del workload de entrenamiento de Prophet, (2) escalabilidad a clusters grandes (>100 hosts), (3) overhead computacional de Prophet en producción, (4) sensibilidad a parámetros BB en workloads no estacionarios | Texto | Media | 1 | Pendiente |
| AU-01 | Autor | Introducción necesita revisión — "relevant questions" y vinculación al código desde el principio | Reescribir los 3-4 primeros párrafos de la introducción: plantear las preguntas de investigación explícitas (RQ1: ¿puede Prophet predecir uso de recursos cloud con precisión suficiente?, RQ2: ¿las BB reducen migraciones innecesarias?, RQ3: ¿WBF supera al estado del arte en ESV?) | Reescritura | Alta | 2 | Pendiente |
| AU-02 | Autor | Related Work debe incluir NeuralProphet como referencia adicional | Añadir párrafo en Related Work describiendo NeuralProphet (Taylor & Letham mejorado con componentes DL) y justificar por qué WBF usa Prophet estándar en lugar de NeuralProphet (overhead, interpretabilidad, convergencia) | Texto | Media | 1 | Pendiente |
| AU-03 | Autor | Falta conclusión final comparando comportamiento WBF por workload | Añadir párrafo final en Conclusions con tabla o texto comparativo: WBF sobresale especialmente en PlanetLab (alta variabilidad), comportamiento más similar a competidores en Alibaba/Azure (workloads más estables) | Análisis + Texto | Media | 1 | Pendiente |
| AU-04 | Autor | Tablas/figuras no citadas en orden correcto en el texto | Audit completo de todas las referencias a Table/Figure en el cuerpo del texto; reordenar citas para que sigan orden numérico ascendente; ajustar numeración de tablas si es necesario | Texto | Media | 1 | Pendiente |

---

## Sección 2: Nuevos experimentos candidatos

### Experimento E1: NeuralProphet vs WBF

**Descripción:** Comparar el rendimiento de WBF usando NeuralProphet (variante con componentes de deep learning) en lugar de Facebook Prophet estándar, en las mismas condiciones experimentales de CloudSim.

**Workloads:** PlanetLab, Alibaba 2018, Materna, Microsoft Azure 2019 (los 4 workloads del paper).

**Notebook disponible:** `statistics_paper4_neural.ipynb` — ya existe, contiene análisis preliminar.

**Tiempo estimado de ejecución:** 2-4 horas por workload (30 seeds), 1-2 días total en hardware disponible.

**Impacto esperado en el paper:**
- Fortalece la justificación de elegir Prophet estándar sobre NeuralProphet.
- Permite añadir fila "NeuralProphet-WBF" en las Tablas 6-9.
- Responde directamente al comentario AU-02 (añadir NeuralProphet como referencia).
- Si WBF-FP supera a WBF-NeuralProphet en algunos workloads, refuerza la elección de Prophet; si pierde, argumenta que Prophet ofrece mejor interpretabilidad con resultados comparables.

**Prioridad:** Alta. El notebook ya existe, el esfuerzo adicional es mínimo.

---

### Experimento E2: AutoARIMA como baseline adicional

**Descripción:** Análisis completo de AutoARIMA como técnica de forecasting alternativa a Prophet para la predicción de uso de recursos en VMs, evaluado dentro del framework WBF (sustituyendo el componente de predicción).

**Workloads:** PlanetLab y Alibaba 2018 (los dos workloads con mayor contraste en resultados actuales).

**Notebook disponible:** Los datos de poolExperiments ya están ejecutados. Crear `statistics_paper4_autoarima.ipynb` a partir de la estructura de `statistics_paper4_neural.ipynb`.

**Tiempo estimado de ejecución:** 1-2 días (AutoARIMA es más lento que Prophet en series largas; usar pmdarima o statsforecast).

**Impacto esperado en el paper:**
- Permite responder a revisores que cuestionen si Prophet es la mejor elección de forecasting.
- Si Prophet supera a AutoARIMA: argumento directo de que el componente neuronal de Prophet (tendencia + estacionalidad + festivos) aporta valor sobre modelos estadísticos puros.
- Si AutoARIMA es comparable: motiva la elección de Prophet por interpretabilidad y facilidad de deployment.
- Responde parcialmente a la pregunta implícita de [C] "Is ML Necessary?".

**Prioridad:** Media. Requiere crear notebook nuevo pero datos ya existen.

---

### Experimento E3: Análisis por workload — ¿cuándo funciona WBF mejor y peor?

**Descripción:** Análisis detallado de las condiciones bajo las cuales WBF obtiene sus mejores y peores resultados, identificando características del workload (variabilidad, autocorrelación, picos) que correlacionan con el rendimiento de WBF.

**Workloads:** Los 4 workloads (PlanetLab, Alibaba, Materna, Azure).

**Notebooks disponibles:**
- `p4_test3_materna_tuning_30.ipynb`
- `p4_test3_alibaba_30.ipynb`
- `p4_test3_azure_30.ipynb`
- Un notebook similar para PlanetLab (verificar si existe).

**Tiempo estimado de ejecución:** 0 días de ejecución nueva (datos ya disponibles). 2-3 días de análisis estadístico y redacción.

**Impacto esperado en el paper:**
- Responde directamente a R2-07 (análisis de trade-offs) y AU-03 (conclusión por workload).
- Permite añadir la subsección "Discussion of results by workload" en la Discussion.
- Caracterización de PlanetLab (alta variabilidad temporal) vs Azure (workload más estable) como explicación de por qué WBF gana más en PlanetLab.
- Añade profundidad científica sin coste computacional adicional.

**Prioridad:** Alta. No requiere nuevas ejecuciones; solo análisis.

---

### Experimento E4: Sensitivity Analysis — Bollinger Bands (N y alfa)

**Descripción:** Análisis de sensibilidad de los parámetros de las Bollinger Bands: ventana temporal N (rango 5..40) y multiplicador de desviación estándar alfa (rango 0.5..2.5), evaluando su impacto en energía, SLA y número de migraciones.

**Workloads:** PlanetLab (workload de referencia) + Alibaba (para validar generalización).

**Notebooks disponibles:** Los datos ya están en `p4_test3_*.ipynb` (sensitivity analysis ya ejecutado). Verificar si cubre el rango completo N=5..40, alfa=0.5..2.5.

**Tiempo estimado de ejecución:** Si los datos ya existen: 1-2 días de análisis. Si falta algún punto del grid: 4-8 horas de ejecución adicional.

**Impacto esperado en el paper:**
- Responde a R1-04 (justificación de Bollinger Bands): demuestra empíricamente qué valores de N y alfa son óptimos y por qué los valores elegidos en el paper son razonables.
- Permite añadir heatmap o contour plot de rendimiento en función de (N, alfa).
- Refuerza la robustez del método: WBF funciona bien en un rango amplio de parámetros, no solo en los óptimos.
- Justifica por qué los parámetros elegidos en Table 3 son apropiados.

**Prioridad:** Alta. Datos probablemente ya disponibles; análisis directo.

---

### Experimento E5: Comparación con métodos del estado del arte reciente

**Descripción:** Comparación cuantitativa de WBF con los métodos propuestos en los papers [A], [B] y [C] del correo, en términos de métricas comunes (consumo energético, violaciones de SLA, migraciones).

**Workloads:** Depende de qué workloads usen los papers [A], [B], [C]. PlanetLab es el más común en la literatura.

**Notebooks disponibles:** No existe aún. Requiere:
1. Lectura detallada de [A], [B], [C] para extraer métricas reportadas.
2. Evaluación de si los resultados son directamente comparables (mismo simulador, misma configuración).
3. Si no son comparables directamente: tabla de comparación cualitativa de características.

**Tiempo estimado de ejecución:** 1-2 semanas. Lectura de papers (3-4 días) + implementación si es necesaria (1 semana) + análisis (2-3 días).

**Impacto esperado en el paper:**
- Responde directamente a R1-01 y R1-02 (contribución pequeña, falta comparación con trabajos recientes).
- Si la comparación directa no es posible (diferentes simuladores, configuraciones), una tabla de comparación de características y una discusión cualitativa son suficientes.
- Añade una figura o tabla nueva de "Comparison with state of the art" que editors valoran mucho.

**Prioridad:** Alta para la revisión, pero esfuerzo elevado. Empezar con extracción de métricas de papers y evaluar si comparación cuantitativa es factible.

---

## Sección 3: Cambios estructurales al manuscrito

### 3.1 Reorganización general (Acción R2-04)

La estructura actual mezcla background con metodología. La estructura propuesta sigue el estándar IMRaD adaptado:

```
1. Introduction
   1.1 Motivation and context
   1.2 Research Questions (RQ1, RQ2, RQ3)
   1.3 Contributions
   1.4 Paper organization

2. Related Work
   2.1 VM consolidation policies
   2.2 Forecasting techniques for cloud (incluir Prophet for Cloud [A])
   2.3 Hybrid approaches
   2.4 Survey comparison (incluir [B])
   2.5 Position of WBF relative to state of the art

3. Background
   3.1 VM consolidation fundamentals
   3.2 Pearson correlation (base de WPSP)
   3.3 Bollinger Bands (analogia financiera + propiedades estadísticas)
   3.4 Facebook Prophet (arquitectura, entrenamiento, cross-validation)
   3.5 CloudSim y PlanetLab/Alibaba/Materna/Azure workloads

4. WBF Methodology
   4.1 Overview y definicion formal: WBF = WPSP + BB + FP
   4.2 WPSP: Weighted Pearson Selection Policy
   4.3 Bollinger Bands Filter: BF(h) y WBF(H0)
   4.4 Facebook Prophet Forecasting
   4.5 WBF Integration: Algoritmo 1 explicado paso a paso
   4.6 Complexity analysis

5. Experimental Setup
   5.1 Simulation environment (CloudSim)
   5.2 Hardware configuration (Table 3)
   5.3 Workloads: descripción detallada con preprocessing
       5.3.1 PlanetLab
       5.3.2 Alibaba 2018
       5.3.3 Materna
       5.3.4 Microsoft Azure 2019
   5.4 Baselines y comparadores
   5.5 Métricas de evaluación

6. Results
   6.1 Energy consumption (Tables 6-9 renumeradas si necesario)
   6.2 SLA violations
   6.3 Number of migrations
   6.4 ESV (Energy × SLA composite metric)
   6.5 Sensitivity analysis (BB parameters)

7. Discussion
   7.1 Trade-off analysis: energy vs SLA vs migrations
   7.2 Per-workload analysis: cuando WBF funciona mejor/peor
   7.3 Comparison with forecasting alternatives (NeuralProphet, AutoARIMA)
   7.4 Comparison with state of the art [A], [B], [C]
   7.5 Practical implications

8. Conclusions
   8.1 Summary of contributions
   8.2 Per-workload conclusions
   8.3 Limitations
   8.4 Future work
```

### 3.2 Secciones a reescribir completamente

**Introducción:** Reescribir párrafos 1-4. Plantear las 3 Research Questions de forma explícita. Añadir URL del repositorio. Listar contribuciones en bullets numerados.

**Sección 4.3 (Background de Prophet):** Reescribir desde cero. Incluir: (1) arquitectura de Prophet con ecuación del modelo completo, (2) componentes de tendencia (logística/lineal), estacionalidad (Fourier), festivos, (3) entrenamiento MAP vs MCMC, (4) cross-validation con parámetros horizon/period/initial, (5) configuración específica usada en WBF.

**Algoritmo 1:** Reescribir con comentarios en cada línea. Añadir explicación textual párrafo a párrafo en el texto principal.

**Discussion:** Ampliar significativamente. Añadir análisis cuantitativo, tabla de trade-offs, análisis por workload.

**Conclusions:** Añadir subsección "Limitations" al final. Añadir párrafo de comparación por workload.

### 3.3 Secciones a ampliar sin reescribir

**Related Work:** Añadir 1 párrafo sobre [A], 1 sobre [B], 1 sobre [C], y 1 sobre NeuralProphet.

**Experimental Setup (Datasets):** Ampliar descripción de cada dataset con preprocessing, filtros, número de VMs, granularidad temporal.

**Results:** Añadir filas de NeuralProphet y AutoARIMA en las tablas existentes si los experimentos E1 y E2 producen datos.

---

## Sección 4: Papers del correo — estrategia de uso

### Paper [A]: "Time Series Forecasting using Facebook Prophet for Cloud Resource Management"

**Posicionamiento del paper actual:**
El paper [A] es el precedente más directo. WBF utiliza Prophet como componente de predicción, pero va más allá: integra Prophet con WPSP (selección de VMs) y Bollinger Bands (filtro de migraciones). El paper actual debe posicionarse como una extensión aplicada de [A] al problema de consolidación de VMs, no como duplicación.

**Donde citar en el manuscrito:**
- En la Introducción: como motivación del uso de Prophet en cloud.
- En Related Work (nueva subsección 2.2): descripción de [A] y diferenciación.
- En Sección 4.4 (Background de Prophet): como referencia de validación de Prophet para cloud.
- En Discussion (sección 7.4): comparación de resultados si las métricas son comparables.

**Si requiere experimento comparativo:**
Revisar si [A] reporta métricas comparables (energía, SLA, migraciones) en los mismos workloads. Si usa PlanetLab: comparación directa posible. Si usa métricas diferentes: comparación cualitativa de características. Prioridad: verificar esto al leer el paper en detalle (3-4 horas).

---

### Paper [B]: "Efficient VM migrations using forecasting techniques in cloud computing: a comprehensive review"

**Posicionamiento del paper actual:**
El paper [B] es una encuesta/taxonomía, no un sistema competidor. WBF debe posicionarse como una instancia concreta de la taxonomía que [B] describe. Verificar si [B] menciona alguna combinación WPSP+BB+FP o similar; si no existe, ese "gap" justifica la contribución de WBF.

**Donde citar en el manuscrito:**
- En Related Work (nueva subsección 2.3): como encuesta de referencia del área.
- En Introducción: para justificar el gap que WBF cubre.
- En Discussion: para situar WBF dentro de la taxonomía de [B].

**Si requiere experimento comparativo:**
No. Al ser un survey, no hay implementación que comparar. El uso correcto es como referencia bibliográfica de contexto y taxonomía. Esfuerzo: 2-3 horas de lectura para extraer la taxonomía relevante.

---

### Paper [C]: "Is Machine Learning Necessary for Cloud Resource Usage Forecasting?"

**Posicionamiento del paper actual:**
El paper [C] compara ML (incluyendo LSTM) con métodos estadísticos clásicos para forecasting en cloud. WBF usa Prophet, que es un modelo híbrido (estadístico + components DL en NeuralProphet). Hay dos estrategias de posicionamiento:
- Estrategia A: Prophet no es "ML puro" sino un modelo estadístico interpretable con componentes de tendencia y estacionalidad — responde positivamente a la pregunta de [C].
- Estrategia B: El experimento E2 (AutoARIMA vs Prophet) demuestra que el componente predictivo de Prophet aporta valor sobre ARIMA puro en workloads con estacionalidad compleja.

Recomendar Estrategia A + Estrategia B combinadas.

**Donde citar en el manuscrito:**
- En Related Work (nueva subsección 2.2): para contextualizar el debate ML vs estadística.
- En Sección 4.4 (Background de Prophet): para justificar por qué Prophet es adecuado (interpretabilidad, convergencia, no requiere grandes datasets).
- En Discussion (sección 7.4): para responder explícitamente a la pregunta de [C] en el contexto de WBF.

**Si requiere experimento comparativo:**
El experimento E2 (AutoARIMA) responde parcialmente. Si [C] implementa métodos específicos con métricas comparables en PlanetLab, puede añadirse una fila en las tablas de resultados. Verificar al leer el paper (2-3 horas). Si las métricas no son directamente comparables, comparación cualitativa en Discussion es suficiente.

---

## Sección 5: Criterios para considerar el paper listo para re-envío

### Criterios obligatorios (sin estos, no re-enviar)

- [ ] **R1-01/R1-02 respondidos:** Párrafo de contribuciones explícitas en Introduction + tabla de comparación con trabajos recientes en Related Work.
- [ ] **R1-03 completado:** Sección 4.3 (Prophet) reescrita con arquitectura, entrenamiento, cross-validation y configuración usada.
- [ ] **R1-04 respondido:** Subsección de justificación de Bollinger Bands con evidencia empírica (o referencias bibliográficas sólidas que avalen la analogía estadística).
- [ ] **R1-06 completado:** URL del repositorio de código añadida en Introduction y Experimental Setup.
- [ ] **R2-01 completado:** WBF definido formalmente en Abstract y primera mención ("WBF = WPSP + BB + FP").
- [ ] **R2-02 completado:** BF(h) y WBF(H0) con definición formal y ecuaciones.
- [ ] **R2-04 completado:** Estructura del manuscrito reorganizada según esquema IMRaD propuesto.
- [ ] **R2-05 completado:** Algoritmo 1 con explicación paso a paso en texto y pseudocódigo mejorado.
- [ ] **R2-07 completado:** Discussion con análisis cuantitativo de trade-offs energía-SLA-migraciones.
- [ ] **R2-08 completado:** Datasets descritos con preprocessing, filtros, número de VMs y granularidad temporal.
- [ ] **R2-09 completado:** Subsección "Limitations" añadida en Conclusions.
- [ ] **Tablas/figuras en orden:** Audit completo de referencias a Table/Figure en el texto; todas citadas en orden numérico ascendente.
- [ ] **Grammar revisado:** Revisión completa del inglés técnico del manuscrito.

### Criterios altamente recomendados (añaden valor significativo)

- [ ] **E1 completado:** NeuralProphet vs WBF añadido en las tablas de resultados y en Discussion.
- [ ] **E3 completado:** Análisis por workload añadido en Discussion.
- [ ] **E4 completado:** Sensitivity analysis de BB (N, alfa) añadido en Results.
- [ ] **AU-01 completado:** Research Questions explícitas en Introduction.
- [ ] **AU-02 completado:** NeuralProphet añadido en Related Work con justificación de por qué WBF usa Prophet estándar.
- [ ] **AU-03 completado:** Conclusión final comparando comportamiento WBF por workload.
- [ ] **Papers [A][B][C] citados:** Los 3 papers del correo correctamente integrados en Related Work y Discussion.

### Criterios opcionales (mejoran la calidad pero no son críticos para aceptación)

- [ ] **E2 completado:** AutoARIMA como baseline adicional.
- [ ] **E5 completado:** Comparación cuantitativa directa con [A] si las métricas son comparables.
- [ ] **Diagrama de flujo WBF:** Figura adicional mostrando el proceso completo de WBF (responde a R2-06).

---

## Sección 6: Orden recomendado de trabajo

### Fase 1: Fundamentos (Semana 1)
**Objetivo:** Resolver todos los cambios que no requieren nuevos experimentos y que son prerequisitos para el resto.

| Día | Acción | ID |
|-----|--------|-----|
| 1 | Reorganizar estructura del manuscrito (crear nueva TOC, mover secciones) | R2-04 |
| 1 | Añadir definición formal WBF en Abstract e Introduction | R2-01 |
| 1 | Añadir URL repositorio código | R1-06 |
| 2 | Corregir título Sección 4 | R2-03 |
| 2 | Definir BF(h) y WBF(H0) formalmente | R2-02 |
| 2 | Audit de tablas/figuras en orden correcto | AU-04 |
| 3 | Reescribir párrafos 1-4 Introduction con RQs y contribuciones | AU-01, R1-01 |
| 4 | Reescribir Algoritmo 1 con explicación paso a paso | R2-05 |
| 5 | Descripción detallada de datasets con preprocessing | R2-08 |

### Fase 2: Contenido técnico (Semana 2)
**Objetivo:** Completar las secciones técnicas más importantes.

| Día | Acción | ID |
|-----|--------|-----|
| 6-7 | Reescribir Sección 4.3 — Prophet completo | R1-03 |
| 8 | Añadir justificación empírica de Bollinger Bands | R1-04 |
| 9 | Analizar datos existentes E3 (por workload) y E4 (sensitivity BB) | E3, E4 |
| 10 | Añadir Discussion: trade-offs y análisis por workload | R2-07, AU-03 |

### Fase 3: Estado del arte y comparaciones (Semana 3)
**Objetivo:** Integrar los papers del correo y añadir NeuralProphet.

| Día | Acción | ID |
|-----|--------|-----|
| 11-12 | Leer papers [A], [B], [C] y extraer métricas y taxonomía | R1-02 |
| 13 | Reescribir Related Work con [A], [B], [C], NeuralProphet | R1-02, AU-02 |
| 14 | Ejecutar E1 (NeuralProphet vs WBF, notebook existente) | E1 |
| 15 | Añadir resultados E1 en tablas y Discussion | E1 |

### Fase 4: Pulido y calidad (Semana 4)
**Objetivo:** Revisión de calidad, grammar, limitaciones, carta de respuesta.

| Día | Acción | ID |
|-----|--------|-----|
| 16-17 | Añadir sección Limitations en Conclusions | R2-09 |
| 18 | Grammar — revisión completa del manuscrito | R1-05 |
| 19 | Crear diagrama de flujo WBF (figura nueva) | R2-06 |
| 20 | Escribir carta de respuesta a revisores (punto por punto) | — |

### Fase 5: Experimentos adicionales (Semana 5, si tiempo permite)
**Objetivo:** Experimentos de comparación adicional si se consideran necesarios.

| Día | Acción | ID |
|-----|--------|-----|
| 21-22 | E2: AutoARIMA analysis (crear notebook) | E2 |
| 23-24 | E5: Comparación con [A] si métricas comparables | E5 |
| 25 | Revisión final integral antes de re-envío | — |

---

## Sección 7: Qué puede hacerse rápido vs qué requiere investigación

### Rapido (≤1 semana) — Cambios textuales y de estructura

Estas acciones se pueden completar en la primera semana sin ejecutar ningún experimento nuevo:

| Acción | Tiempo | ID |
|--------|--------|----|
| Añadir "WBF = WPSP + BB + FP" en Abstract + Introduction | 1 hora | R2-01 |
| Añadir URL repositorio código | 30 min | R1-06 |
| Corregir título Sección 4 | 30 min | R2-03 |
| Audit tablas/figuras en orden correcto | 2-3 horas | AU-04 |
| Definir BF(h) y WBF(H0) formalmente | 2 horas | R2-02 |
| Reorganizar estructura de secciones | 1-2 días | R2-04 |
| Reescribir Introduction con RQs y contribuciones | 1-2 días | AU-01, R1-01 |
| Descripción detallada de datasets | 1-2 días | R2-08 |
| Añadir NeuralProphet en Related Work | 2-3 horas | AU-02 |
| Crear subsección Limitations | 3-4 horas | R2-09 |
| Grammar — revisión con herramienta + manual | 1-2 días | R1-05 |

**Subtotal Rapido: ~7-10 días de trabajo efectivo. Sin bloqueos.**

---

### Medio (1-3 semanas) — Análisis de datos ya disponibles + Prophet

Estas acciones requieren trabajo técnico pero los datos ya están disponibles:

| Acción | Tiempo | ID/Exp |
|--------|--------|--------|
| Reescribir Sección 4.3 Prophet completo | 2-3 días | R1-03 |
| Justificación empírica de Bollinger Bands (análisis de series temporales) | 1-2 días | R1-04 |
| Reescribir Algoritmo 1 paso a paso | 1-2 días | R2-05 |
| E3: Análisis por workload (datos ya en notebooks) | 2-3 días | E3 |
| E4: Sensitivity analysis BB (datos probablemente en notebooks) | 2-3 días | E4 |
| E1: NeuralProphet vs WBF (notebook ya existe) | 1-2 días ejecución + 1 análisis | E1 |
| Discussion ampliada con trade-offs y análisis por workload | 2-3 días | R2-07, AU-03 |
| Leer papers [A], [B], [C] y actualizar Related Work | 3-4 días | R1-02 |

**Subtotal Medio: ~15-20 días de trabajo efectivo. Requiere acceso a notebooks y entorno de ejecución.**

---

### Lento (>3 semanas) — Investigacion nueva o experimentos costosos

Estas acciones requieren investigación o ejecución computacional significativa:

| Acción | Tiempo | ID/Exp |
|--------|--------|--------|
| E2: AutoARIMA completo (crear notebook, ejecutar, analizar) | 1-2 semanas | E2 |
| E5: Comparación cuantitativa con papers [A]/[C] si métricas comparables (requiere implementar o adaptar métodos externos) | 2-4 semanas | E5 |
| Crear diagrama de flujo WBF en herramienta gráfica | 2-3 días | R2-06 |
| Carta de respuesta a revisores (completa, punto por punto) | 3-5 días | — |

**Subtotal Lento: solo necesarios parcialmente. E5 puede hacerse de forma cualitativa en 1 semana si la comparación cuantitativa no es factible.**

---

### Estrategia recomendada de priorización

```
Semana 1: TODO lo "Rapido" → cambios textuales listos, estructura reorganizada
Semana 2: TODO lo "Medio" (primera parte) → Prophet 4.3, Algoritmo 1, datasets
Semana 3: Leer [A][B][C] + E3 + E4 + E1 → Related Work actualizado, análisis por workload
Semana 4: Discussion + Conclusions + grammar + Limitations
Semana 5: E2 si tiempo permite + carta de respuesta + revision final
```

**Timeline total estimado: 4-5 semanas de trabajo activo** (asumiendo dedicación parcial al proyecto).

---

## Apendice: Archivos relevantes del proyecto

### Notebooks de experimentos

| Notebook | Contenido | Acciones relacionadas |
|----------|-----------|----------------------|
| `statistics_paper4_neural.ipynb` | NeuralProphet vs WBF (análisis preliminar) | E1 |
| `p4_test3_materna_tuning_30.ipynb` | Tuning por workload — Materna | E3, E4 |
| `p4_test3_alibaba_30.ipynb` | Experimentos Alibaba 2018, 30 seeds | E3, E4 |
| `p4_test3_azure_30.ipynb` | Experimentos Azure 2019, 30 seeds | E3, E4 |
| `statistics_paper4_wpsp.ipynb` | Análisis específico de WPSP | R1-01, R2-02 |

### Workloads utilizados

| Workload | Fuente | Características clave | Descripción para Sec 5.3 |
|----------|--------|----------------------|--------------------------|
| PlanetLab | UCI Repository | Alta variabilidad, picos pronunciados | Necesita: granularidad, filtros, num. VMs |
| Alibaba 2018 | Alibaba Cloud | Workload de producción industrial | Necesita: preprocesamiento, normalización |
| Materna | Empresa real (Materna GmbH) | Workload empresarial privado | Necesita: permisos de descripción, granularidad |
| Microsoft Azure 2019 | Azure dataset público | Workload de nube pública comercial | Necesita: versión exacta, filtros aplicados |

### Técnicas comparadas en el paper

| Técnica | Descripción | Componentes |
|---------|-------------|-------------|
| MU | Minimum Utilization | Baseline clásico |
| MMT | Minimum Migration Time | Baseline clásico |
| RS | Random Selection | Baseline aleatorio |
| MC | Maximum Correlation | Correlación simple |
| WPSP | Weighted Pearson Selection Policy | Componente 1 de WBF |
| WF | WPSP + Facebook Prophet (sin BB) | WBF sin filtro Bollinger |
| WBF | WPSP + BB + FP (propuesta) | Propuesta completa |
| WBF-NP | WPSP + BB + NeuralProphet | **A añadir en E1** |
| WBF-ARIMA | WPSP + BB + AutoARIMA | **A añadir en E2** |

---

*Plan elaborado por: Research Software Engineer Senior*
*Fecha: 2026-06-02*
*Versión: 1.0*
