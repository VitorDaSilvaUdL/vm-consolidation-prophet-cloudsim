# Plan Ejecutivo de Publicación — Paper 4

**Paper:** "Virtual Machine Consolidation in Cloud Computing based on Facebook Prophet Forecasting Neural-Network"
**Journal:** Future Generation Computer Systems (Elsevier)
**Tipo de revisión recibida:** Major Revision
**Fecha de elaboración:** 2026-06-02
**Fecha objetivo de re-envío:** 2026-08-18 (~11 semanas desde hoy)

---

## Introducción

### Estado actual

El paper ha recibido una **Major Revision** de Future Generation Computer Systems (Elsevier, 2023). Dos revisores han emitido comentarios detallados que cubren: (1) justificación de la contribución respecto al estado del arte, (2) formalización matemática incompleta del método WBF, (3) descripción insuficiente de Facebook Prophet como componente neuronal, (4) organización estructural del manuscrito, y (5) análisis de resultados puramente descriptivo sin cuantificación de trade-offs.

El método propuesto **WBF** (WPSP + Bollinger Bands + Facebook Prophet) ya demuestra resultados sólidos en los experimentos realizados:
- Reducción de energía: ~10% vs técnicas clásicas
- Reducción de SLA: 25–60% respecto a técnicas clásicas
- Reducción de migraciones: 45–70% respecto a técnicas clásicas
- Evaluación en 4 workloads reales: PlanetLab, Alibaba 2018, Materna, Azure 2019
- 7 técnicas comparadas con 30 seeds por configuración

El objetivo de la revisión **no es cambiar la contribución técnica central**, sino fortalecer la narrativa científica, completar la formalización matemática, añadir comparaciones con el estado del arte reciente, y responder punto a punto a los 15+ comentarios críticos identificados en `MAJOR_REVIEW_ACTION_PLAN.md`.

### Objetivo

Preparar el manuscrito revisado y el paquete completo de re-envío a **Future Generation Computer Systems** (Elsevier), incluyendo carta de respuesta a revisores, en un plazo de 11–14 semanas.

### Actores y roles

| Actor | Rol | Responsabilidad principal |
|-------|-----|--------------------------|
| Sergi Vila | Autor, investigador UdL | Método WBF, diseño experimental, entorno original de simulación, **pymodule** |
| **Vitor Luiz da Silva** | **Co-autor, UdL** | **Reproducibilidad (Docker/jpy), validación (energía compuesta), experimentos nuevos (NeuralProphet, Bollinger), posicionamiento SOTA, revisión mayor y respuesta a revisores** |
| Rosa Ana Tomás | Co-autora, UdL | Revisión de contenido |
| Francesc Giné | Co-autor, UdL | Revisión de contenido |
| Fernando Guirado | Co-autor, UdL | Revisión de metodología y sección CloudSim |
| Josep L. Lérida | Co-autor, UdL | Revisión de resultados y discusión |
| Fernando Cores | Co-autor, UdL | Revisión estadística, related work / estado del arte |

---

## Fase 1 — Reproducibilidad del entorno de simulación

**Duración estimada:** Semanas 1–3
**Responsable:** Vitor (ejecución) + Sergi (desbloqueador crítico)

### Contexto

Las simulaciones están **bloqueadas** en el entorno actual (Windows, PcVIP):
- Java 8 no instalado (requerido por CloudSim)
- Python 3.13 instalado en lugar de 3.8 (versión requerida)
- `pymodule` (código Python CloudSim) ✅ **disponible en `networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python`** — bloqueador resuelto

Los resultados originales del paper están preservados en `networkExperiments/paper4_data/` y son el ground truth. El objetivo de esta fase no es re-ejecutar todo, sino establecer reproducibilidad mínima verificable.

### Pasos

**Paso 1 — ~~`pymodule` obtenido~~ ✅ (Resuelto 2026-06-03)**

El módulo Python está disponible en:
`networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python`

Contiene: forecastingTechniques.py, bollingerFunctions.py, signalProcessing.py, pythonBinding.py, traceImporter.py

Las técnicas WF y WBF (contribución central del paper) **son ahora reproducibles**. El `launcher.json` ya ha sido actualizado con la ruta correcta.

**Paso 2 — Instalar Docker Desktop en Windows (Semana 1)**

URL: https://docs.docker.com/desktop/install/windows-install/

Verificar instalación:
```powershell
docker --version
docker run hello-world
```

El `Dockerfile` ya está creado en `project_minimized/`. Usa Java 8 (imagen `openjdk:8-jdk`) + Python 3.8 + todas las dependencias necesarias.

**Paso 3 — Construir imagen Docker (Semana 1–2)**

```powershell
cd "C:\Users\PcVIP\Desktop\Proyecto Sergi\project_minimized"
docker build -t metacloudsim .
# Tiempo estimado: 10-20 minutos (descarga de dependencias)
```

Si la build falla:
- Verificar que Docker Desktop tiene acceso a internet
- Revisar `Dockerfile` en `project_minimized/Dockerfile`
- Si falla en compilación de `jpy`: verificar que Maven está disponible en la imagen base

**Paso 4 — Ejecutar smoke test (Semana 2)**

El smoke test usa solo técnicas estáticas (sin `pymodule`, sin jpy):
```powershell
.\scripts\run_smoke_test.ps1 -UseDocker
```

O equivalentemente con la configuración mínima:
```powershell
docker run --rm -v "$(pwd)/results:/app/results" metacloudsim \
  java -jar metacloudsim.jar -config configs/paper4/paper4_smoke.json
```

**Criterio de éxito del smoke test:** Técnicas MU, MMT, RS, MC producen valores próximos a los de la Tabla 6 del paper (PlanetLab). Tolerancia: ±5% en energía, ±10% en SLA (variabilidad por semilla).

**Paso 5 — Si smoke test OK: análisis Python de resultados existentes (Semana 2–3)**

Los datos reales del paper están en `networkExperiments/paper4_data/`. El análisis Python puede ejecutarse sobre ellos sin re-correr simulaciones:
```powershell
docker run --rm -p 8888:8888 \
  -v "$(pwd)/../networkExperiments/paper4_data:/data" \
  -v "$(pwd):/app" \
  metacloudsim jupyter notebook --ip=0.0.0.0 --allow-root
```

Abrir `statistics_paper4_neural.ipynb` para verificar que los notebooks cargan los datos correctamente.

**Paso 6 — Documentar nivel de reproducibilidad alcanzado (Semana 3)**

Actualizar `REPRODUCIBILITY_REPORT.md` con los resultados obtenidos. Niveles definidos:

| Nivel | Descripción |
|-------|-------------|
| BLOQUEADA | Estado actual — ninguna simulación ejecutable |
| SMOKE-TEST | Técnicas estáticas con Docker ejecutan sin errores |
| PARCIAL | Técnicas estáticas + análisis Python de datos existentes |
| COMPLETA-SIN-WBF | Todas las técnicas excepto WBF (pymodule disponible ✅) |
| COMPLETA | Paper 4 completamente reproducible (pymodule disponible ✅ + todo) |

### Criterio de salida de Fase 1

`REPRODUCIBILITY_REPORT.md` actualizado con nivel **≥ SMOKE-TEST**.
Si se obtiene el pymodule de Sergi: objetivo nivel **PARCIAL** o superior.

---

## Fase 2 — Limpieza y minimización del proyecto

**Duración estimada:** Semanas 3–4
**Responsable:** Vitor

### Contexto

El directorio `project_minimized/` ya existe (trabajo previo completado). Esta fase lo finaliza y lo deja ejecutable de forma reproducible por cualquier co-autor.

### Pasos

1. **Completar documentación** si el smoke test añadió información relevante:
   - Actualizar `README.md` con comandos verificados que funcionan
   - Actualizar `environment/java_python_versions.md` con las versiones exactas usadas en Docker
   - Si el pymodule llegó: añadir instrucciones de cómo integrarlo

2. **Actualizar `launcher.json`** con los paths correctos para el entorno Docker:
   - Eliminar paths hardcodeados de `C:/Users/Sergi/...`
   - Usar paths relativos dentro del contenedor
   - Verificar que los 4 workloads están referenciados correctamente

3. **Verificar scripts de automatización:**
   - `scripts/docker_build_and_run.ps1` — build y run básico
   - `scripts/run_smoke_test.ps1` — smoke test con técnicas estáticas
   - `scripts/check_env.ps1` — verificación de entorno
   - Ejecutar cada script y confirmar salida esperada

4. **Verificar acceso a los datos de referencia:**
   - `results/reference/README.md` contiene los valores de las Tablas 6–9
   - Confirmar que los notebooks pueden cargar datos desde `networkExperiments/paper4_data/`

### Criterio de salida de Fase 2

`project_minimized/` es ejecutable con Docker siguiendo únicamente las instrucciones del `README.md`. Un co-autor con Docker instalado puede reproducir el smoke test desde cero.

---

## Fase 3 — Nuevos experimentos y análisis

**Duración estimada:** Semanas 4–8
**Responsable:** Vitor (análisis) + co-autores (revisión de resultados)

Esta fase se divide en dos prioridades según si requieren re-ejecutar simulaciones o solo análisis Python sobre datos ya disponibles.

---

### Prioridad 1 — Análisis sobre datos existentes (sin re-ejecutar simulaciones)

Estos experimentos usan datos ya en `networkExperiments/paper4_data/` o en los pools de experimentos. No requieren Docker ni pymodule.

#### E1: NeuralProphet vs WBF

**Objetivo:** Comparar WBF con Facebook Prophet estándar vs WBF con NeuralProphet. Responde directamente al comentario AU-02 y justifica la elección de Prophet en el paper.

**Notebook:** `statistics_paper4_neural.ipynb` — ya existe con análisis preliminar.

**Pasos:**
1. Abrir el notebook con Python 3.8 (o en Docker con Jupyter)
2. Verificar que carga los datos correctamente de `paper4_data/`
3. Ejecutar todas las celdas
4. Documentar resultados: tabla comparativa NeuralProphet vs WBF por workload y métrica
5. Generar figuras en alta resolución (≥300 DPI, formato .eps o .pdf)
6. Redactar párrafo de resultados para la sección Discussion del paper

**Resultado esperado en el paper:** Nueva fila "WBF-NP" (NeuralProphet) en las Tablas 6–9, y párrafo en Discussion justificando la elección de Prophet estándar (menor overhead, mayor interpretabilidad, resultados comparables).

**Tiempo estimado:** 2–3 días (análisis + redacción).

#### E3: Análisis por workload — ¿cuándo WBF supera a WF?

**Objetivo:** Identificar las condiciones (características del workload) bajo las cuales WBF obtiene sus mejores y peores resultados. Responde a R2-07 (análisis de trade-offs) y AU-03 (conclusión por workload).

**Notebooks disponibles:**
- `p4_test3_materna_tuning_30.ipynb`
- `p4_test3_alibaba_30.ipynb`
- `p4_test3_azure_30.ipynb`
- Verificar si existe notebook equivalente para PlanetLab

**Pasos:**
1. Abrir los 3 notebooks y ejecutar
2. Extraer estadísticas de variabilidad temporal (coeficiente de variación, autocorrelación) por workload
3. Correlacionar características del workload con la ventaja de WBF sobre WF
4. Crear tabla resumen: WBF vs WF por workload (rankings en energía, SLA, migraciones, ESV)
5. Generar figuras comparativas
6. Redactar subsección "Discussion of results by workload" para el paper

**Resultado esperado:** Tabla de rankings por workload que muestra: WBF supera en SLA y migraciones en todos los workloads; WF gana en energía en Alibaba/Materna/Azure; PlanetLab muestra mayor ventaja de WBF por su alta variabilidad temporal.

**Tiempo estimado:** 3–4 días (análisis + redacción).

#### E4: Sensitivity Analysis — Parámetros Bollinger Bands

**Objetivo:** Análisis de sensibilidad de N (ventana temporal, rango 5–40) y alfa (multiplicador de desviación estándar, rango 0.5–2.5). Responde a R1-04 (justificación de BB para cloud).

**Notebooks disponibles:** `p4_test3_*.ipynb` — verificar si el grid completo ya está ejecutado.

**Pasos:**
1. Verificar en los notebooks si el análisis de sensibilidad cubre el rango N=5..40, alfa=0.5..2.5
2. Si datos completos: generar heatmap (N, alfa) → ESV para PlanetLab y Alibaba
3. Si faltan puntos del grid: anotar qué combinaciones faltan y estimar si son críticas
4. Redactar subsección de análisis de sensibilidad y justificación de parámetros elegidos

**Tiempo estimado:** 1–2 días si datos ya existen.

---

### Prioridad 2 — Experimentos que requieren re-ejecutar simulaciones

Estos experimentos requieren Docker + pymodule de Sergi. Ejecutar solo si Fase 1 alcanza nivel COMPLETA-SIN-WBF o superior.

#### E2: AutoARIMA como baseline adicional

**Objetivo:** Comparar WBF-Prophet con WBF-AutoARIMA. Responde implícitamente a [C] "Is ML Necessary?" y justifica la elección de Prophet sobre modelos estadísticos puros.

**Dependencias:** pymodule (contiene `autoARIMA.py`), Docker con pymodule integrado.

**Pasos:**
1. Verificar que `autoARIMA.py` está disponible en pymodule obtenido de Sergi
2. Crear `statistics_paper4_autoarima.ipynb` basado en la estructura de `statistics_paper4_neural.ipynb`
3. Ejecutar para PlanetLab y Alibaba 2018 (los dos workloads con mayor contraste en resultados actuales)
4. Comparar métricas con WBF-Prophet y generar tabla/figura

**Tiempo estimado:** 2–3 días si pymodule disponible.

#### E5: Comparación cuantitativa con papers [A], [B], [C]

**Objetivo:** Posicionar WBF respecto a los métodos propuestos en los papers del correo. Responde a R1-01 y R1-02 (contribución pequeña, falta comparación reciente).

**Pasos:**
1. Leer los 3 papers y extraer sus métricas reportadas
2. Evaluar si comparación directa es posible (mismo simulador, misma configuración de workload)
3. Si comparable: añadir fila WBF en las tablas de resultados de [A], [B], [C]
4. Si no directamente comparable: tabla de comparación de características + discusión cualitativa

**Tiempo estimado:** 1–2 semanas (lectura + análisis + redacción).

---

### Criterio de salida de Fase 3

**Mínimo exigible:** E1 (NeuralProphet) y E3 (análisis por workload) documentados con figuras en alta resolución y texto redactado para el paper.

**Deseable:** E4 (sensitivity analysis BB) completado si los datos ya existen en los notebooks.

**Opcional:** E2 y E5 si el tiempo y los recursos lo permiten.

---

## Fase 4 — Reescritura del manuscrito

**Duración estimada:** Semanas 8–12
**Responsable:** Vitor (borrador) + todos los co-autores (revisión)

Esta fase implementa todos los cambios estructurales y textuales identificados en `MAJOR_REVIEW_ACTION_PLAN.md`. Los cambios se organizan de mayor a menor impacto en la revisión.

### Cambios estructurales obligatorios

**1. Reorganizar estructura de secciones (Acción R2-04)**

Cambiar la organización actual a la estructura IMRaD propuesta:
```
1. Introduction (RQ1, RQ2, RQ3 explícitas + contribuciones + URL código)
2. Related Work (VM consolidation + forecasting cloud + comparación tabular vs estado del arte)
3. Background (WPSP + BB con propiedades estadísticas + Prophet arquitectura completa)
4. WBF Methodology (definición formal + Algoritmo 1 mejorado + diagrama de flujo)
5. Experimental Setup (datasets detallados + configuración CloudSim)
6. Results (Tablas 6–9 + figuras, sin cambios en valores)
7. Discussion (trade-offs cuantitativos + análisis por workload + E1 NeuralProphet)
8. Conclusions (por workload + limitaciones)
```

**2. Reescribir Sección 4.3 Prophet (Acción R1-03)**

Descripción completa de Facebook Prophet como red neuronal/modelo de series temporales:
- Arquitectura: componentes de tendencia (piecewise linear/logistic), estacionalidad (series de Fourier), efectos de festivos
- Proceso de entrenamiento: MAP (máxima a posteriori) y MCMC para estimación de parámetros
- Cross-validation en Prophet: parámetros `horizon`, `period`, `initial`; métricas MAE, MAPE, RMSE
- Hiperparámetros relevantes para el contexto cloud: `changepoint_prior_scale`, `seasonality_mode`, granularidad temporal
- Referencia a NeuralProphet como extensión con componentes de deep learning (AR-Net)

**3. Definición formal de WBF al inicio de la sección de metodología (Acción R2-01, R2-02)**

Añadir caja o párrafo definitorio antes de descomponer el método:
```
WBF = WPSP + BF(h) + FP

donde:
- WPSP: Weighted Pearson Selection Policy — selección de VMs para migrar
         basada en correlación de Pearson ponderada
- BF(h): Bollinger Filter aplicado al host h — filtro que usa bandas de Bollinger
          para detectar uso de CPU anómalo (sobreutilización o infrautilización)
- WBF(H0): WBF aplicado al conjunto de hosts H0 del datacenter — política
            completa de consolidación
```
Añadir ecuaciones explícitas para BF(h) con variables y parámetros N y alfa.

**4. Mejorar Algoritmo 1 (Acción R2-05)**

Añadir en el pseudocódigo:
- Comentarios en cada bloque principal
- Expansión de las condiciones de guardia
- Descripción textual del algoritmo en el párrafo siguiente: qué hace cada fase (detección de sobrecarga → selección WPSP → filtro BB → predicción FP → decisión de migración)

**5. Crear diagrama de flujo del proceso WBF (Acción R2-06)**

Nueva figura: flowchart completo desde "host con CPU > umbral detectado" hasta "migración ejecutada o descartada". Incluir ramas de decisión para BB y FP.

**6. Expandir descripción de datasets en Experimental Setup (Acción R2-08)**

Para cada dataset (PlanetLab, Alibaba 2018, Materna, Azure 2019) documentar:
- Origen y URL de descarga pública
- Granularidad temporal (minutos/intervalos)
- Número total de VMs en la traza
- Número de VMs seleccionadas para el experimento y criterio de selección
- Preprocesamiento aplicado: normalización, imputación de valores faltantes
- Ventanas temporales usadas para entrenamiento de Prophet vs evaluación

**7. Añadir análisis cuantitativo de trade-offs (Acción R2-07)**

En Discussion, reemplazar afirmaciones del tipo "WBF obtiene mejores resultados" por análisis cuantitativo:
- Tabla de rankings por workload y métrica
- Cuantificación de trade-off energía-SLA: "WBF acepta X% más energía en Alibaba a cambio de Y% menos violaciones de SLA"
- Explicación causal del trade-off: Prophet predice picos de carga con antelación, lo que permite encender hosts antes de que se produzca la violación (coste: más energía), evitando la migración de emergencia (beneficio: menos SLA violations)

**8. Añadir sección de limitaciones (Acción R2-09)**

Subsección "Limitations" en Conclusions:
1. Dependencia de la calidad del workload de entrenamiento de Prophet
2. Escalabilidad a clusters grandes (>100 hosts): overhead computacional de Prophet por host
3. Overhead en producción: tiempo de inferencia de Prophet vs latencia de decisión requerida
4. Sensibilidad a parámetros BB en workloads no estacionarios (justificada parcialmente por E4)
5. Evaluación limitada a CloudSim (simulador) — no evaluado en producción real

**9. Añadir resultados de E1 y E3 (Nuevos experimentos)**

- E1 (NeuralProphet): nueva fila en Tablas 6–9 o tabla separada con comparación Prophet vs NeuralProphet
- E3 (análisis por workload): subsección en Discussion con caracterización de workloads y correlación con ventaja de WBF

**10. Citar papers [A], [B], [C] del correo (Acción R1-02)**

- [A] Prophet for Cloud: citar en Related Work sección de forecasting + en Background sección Prophet + en Discussion
- [B] VM migration survey: citar en Related Work sección de surveys + en Introduction
- [C] ML Necessary: citar en Discussion sección de justificación de Prophet vs modelos estadísticos

**11. Reescribir introducción con RQs explícitas (Acción AU-01)**

Los primeros párrafos deben plantear:
- RQ1: ¿Puede Facebook Prophet predecir el uso de recursos de VMs cloud con precisión suficiente para guiar decisiones de consolidación?
- RQ2: ¿Los filtros de Bollinger Bands reducen las migraciones innecesarias causadas por picos transitorios de carga?
- RQ3: ¿WBF supera al estado del arte en la métrica ESV (Energy-SLA violations) de forma consistente en múltiples workloads reales?

**12. Añadir URL del repositorio desde la introducción (Acción R1-06)**

Insertar en el primer párrafo de la introducción y en la sección Experimental Setup:
```
The source code and experimental data are publicly available at:
[URL del repositorio Bitbucket — verificar con Sergi]
```

**13. Revisar gramática y estilo (Acción R1-05)**

Revisión completa del inglés técnico:
- Usar Grammarly o LanguageTool para primera pasada automática
- Revisión manual con especial atención a consistencia de terminología: `host` vs `server` vs `machine` vs `physical machine`
- Revisar consistencia de tiempos verbales en metodología y resultados
- Verificar que los términos CloudSim específicos son consistentes

**14. Marcar cambios en magenta (convención del paper)**

Todos los cambios realizados en la revisión deben marcarse en magenta en el PDF final. Usar `\textcolor{magenta}{...}` o equivalente en el sistema de edición que use el paper.

**15. Revisar orden de citas a tablas y figuras (Acción AU-04)**

Auditoría completa: todas las referencias a `Table X` y `Figure Y` deben aparecer en el cuerpo del texto *antes* de que la tabla/figura aparezca en el documento. Reordenar si es necesario.

### Criterio de salida de Fase 4

Borrador completo del paper revisado, con todos los 15+ comentarios críticos abordados, revisado y aprobado por todos los co-autores. Los cambios marcados en magenta para facilitar la revisión editorial.

---

## Fase 5 — Validación de resultados y consistencia

**Duración estimada:** Semanas 12–13
**Responsable:** Vitor + Sergi

### Pasos

1. **Verificar tablas vs datos reales:**
   - Tablas 6–9: confrontar cada valor con los archivos xlsx en `networkExperiments/paper4_data/`
   - Nueva tabla NeuralProphet (E1): confrontar con salida del notebook
   - Confirmar que ningún valor fue redondeado de forma inconsistente

2. **Verificar figuras:**
   - Todas las figuras deben estar en alta resolución (≥300 DPI)
   - Formatos aceptados: `.eps` o `.pdf` para figuras vectoriales; `.tiff` o `.png` para rasters
   - Verificar que los ejes tienen labels, unidades y leyendas legibles
   - Confirmar que las figuras del paper corresponden a los datos reales (no a versiones preliminares)

3. **Verificar referencias bibliográficas:**
   - Todos los papers citados en el texto tienen entrada en la bibliografía
   - Las referencias [A], [B], [C] del correo están correctamente formateadas (Elsevier citation style)
   - Orden de aparición en el texto es consistente con la numeración de referencias

4. **Verificar orden de tablas y figuras:**
   - Table 1 se cita antes de que aparezca en el PDF, Table 2 también, etc.
   - Si el sistema de edición es LaTeX: `\label` y `\ref` correctamente enlazados

5. **Verificar declaraciones cuantitativas:**
   - Cada afirmación del tipo "WBF reduces migrations by 45%" debe tener base en los datos de las Tablas 6–9
   - Las afirmaciones en Abstract deben ser verificables con los resultados

### Checklist de verificación

```
[ ] Tabla 6 (PlanetLab): todos los valores coinciden con paper4_data/planetlab/
[ ] Tabla 7 (Alibaba): todos los valores coinciden con paper4_data/alibaba_wbf_final_without_wibf/
[ ] Tabla 8 (Materna): todos los valores coinciden con paper4_data/materna_wbf_final_without_wibf/
[ ] Tabla 9 (Azure): todos los valores coinciden con paper4_data/azure_wbf_final_without_wibf/
[ ] Tabla NeuralProphet (nueva): coincide con salida de statistics_paper4_neural.ipynb
[ ] Todas las figuras: resolución ≥ 300 DPI, formato .eps/.pdf/.tiff
[ ] Abstract: cada afirmación cuantitativa verificada con tablas
[ ] Referencias [A], [B], [C]: en bibliografía con formato Elsevier correcto
[ ] Tablas y figuras: citadas en orden numérico ascendente en el texto
[ ] Cambios en magenta: todos los párrafos nuevos/modificados marcados
```

### Criterio de salida de Fase 5

Checklist de verificación completado al 100%. Sin discrepancias entre el texto del paper y los datos en `paper4_data/`.

---

## Fase 6 — Carta de respuesta a revisores

**Duración estimada:** Semanas 13–14
**Responsable:** Vitor (borrador) + Sergi (revisión y aprobación)

### Estructura de la carta

```
Estimados editores y revisores,

Agradecemos los detallados comentarios que han enriquecido significativamente
este trabajo. Hemos abordado todos los comentarios de ambos revisores y
del equipo editorial. A continuación presentamos una descripción de los
cambios principales, seguida de una respuesta punto a punto.

CAMBIOS PRINCIPALES EN EL MANUSCRITO REVISADO:
1. [Lista de cambios más importantes, 5–8 puntos]

RESPUESTAS PUNTO A PUNTO A LOS REVISORES:
[Ver secciones siguientes]
```

### Template para cada respuesta

```
**Comentario del Revisor X:**
[Cita exacta del comentario original]

**Nuestra respuesta:**
Agradecemos este comentario. Hemos [descripción concreta de la acción tomada].
[Si aplica: Los cambios se reflejan en la Sección X, párrafo Y / Tabla Z / Figura W
del manuscrito revisado (marcado en magenta).]
```

### Respuestas a preparar (mínimo 15)

Las respuestas deben cubrir todos los comentarios de `MAJOR_REVIEW_ACTION_PLAN.md`:

| ID | Tema | Sección del paper afectada |
|----|------|---------------------------|
| R1-01 | Contribución vs estado del arte — tabla comparativa | Introducción + Related Work |
| R1-02 | Citar papers [A], [B], [C] y posicionar WBF | Related Work + Discussion |
| R1-03 | Reescribir sección Prophet — arquitectura completa | Background (nueva Sección 3.4) |
| R1-04 | Justificación analógica BB para cloud | Background (nueva Sección 3.3) |
| R1-05 | Revisión de gramática y estilo | Todo el manuscrito |
| R1-06 | URL código fuente en introducción | Introducción + Experimental Setup |
| R2-01 | Definición formal de WBF en Abstract e introducción | Abstract + Introducción |
| R2-02 | Definición formal de BF(h) y WBF(H0) con ecuaciones | Metodología (Sección 4) |
| R2-03 | Título de Sección 4 revisado | Título de sección |
| R2-04 | Reorganización estructural IMRaD | Todo el manuscrito |
| R2-05 | Algoritmo 1 mejorado con comentarios paso a paso | Metodología |
| R2-06 | Diagrama de flujo del proceso WBF | Nueva figura en Metodología |
| R2-07 | Análisis cuantitativo de trade-offs | Discussion |
| R2-08 | Datasets expandidos con preprocessing y filtros | Experimental Setup |
| R2-09 | Sección de limitaciones en Conclusions | Conclusions |
| AU-01 | Preguntas de investigación explícitas (RQ1, RQ2, RQ3) | Introducción |
| AU-02 | NeuralProphet en Related Work + resultados E1 | Related Work + Results |
| AU-03 | Conclusión comparativa por workload | Conclusions |
| AU-04 | Orden de citas tablas/figuras | Todo el manuscrito |

### Criterio de salida de Fase 6

Carta de respuesta a revisores completa con **≥ 15 respuestas punto a punto**, cada una indicando la sección exacta donde se realizó el cambio. Revisada y aprobada por Sergi antes del envío.

---

## Fase 7 — Checklist final de envío

**Duración estimada:** Semana 14
**Responsable:** Vitor + Sergi

### Checklist de submisión

```
MANUSCRITO
[ ] Todos los comentarios de revisores respondidos (≥15 respuestas)
[ ] Manuscrito revisado con cambios marcados en magenta
[ ] Estructura IMRaD implementada (Secciones reorganizadas)
[ ] Sección 4.3 Prophet reescrita completamente
[ ] WBF, BF(h), WBF(H0) formalmente definidos con ecuaciones
[ ] Algoritmo 1 mejorado con comentarios paso a paso
[ ] Diagrama de flujo WBF incluido como figura
[ ] Datasets expandidos con preprocessing y filtros
[ ] Análisis cuantitativo de trade-offs en Discussion
[ ] Sección de limitaciones añadida en Conclusions
[ ] NeuralProphet (E1) añadido como comparación
[ ] Análisis por workload (E3) añadido en Discussion
[ ] RQs explícitas (RQ1, RQ2, RQ3) en Introducción
[ ] Papers [A], [B], [C] citados y discutidos
[ ] URL del repositorio en Introducción y Experimental Setup

CALIDAD
[ ] Gramática revisada (Grammarly/LanguageTool + revisión manual)
[ ] Consistencia terminológica verificada (host/server/machine)
[ ] Tablas y figuras citadas en orden numérico ascendente
[ ] Valores de tablas verificados contra datos reales en paper4_data/

FIGURAS Y TABLAS
[ ] Todas las figuras en alta resolución (≥300 DPI)
[ ] Formato de figuras: .eps o .pdf (vectorial) o .tiff (raster)
[ ] Leyendas y etiquetas de ejes en todas las figuras
[ ] Tablas correctamente numeradas (Table 1, Table 2, ...)
[ ] Nueva tabla NeuralProphet verificada contra notebook

REFERENCIAS
[ ] Referencias en orden de aparición (estilo Elsevier numérico)
[ ] Papers [A], [B], [C] en bibliografía con formato completo
[ ] DOI incluido en todas las referencias donde esté disponible

ELEMENTOS DE SUBMISIÓN
[ ] Código fuente accesible en repositorio público (URL verificada)
[ ] Contribuciones de autores (CRediT) declaradas en el manuscrito
[ ] Conflict of interest declarado (o ausencia declarada)
[ ] Acknowledgments actualizado con proyecto financiador: PID2020-113614RB-C22
[ ] Cover letter actualizada con referencia al número de manuscrito original
[ ] Highlights: 3–5 puntos, ≤85 caracteres cada uno
[ ] Carta de respuesta a revisores adjunta como documento separado
[ ] Todos los archivos en el formato requerido por Elsevier (Word o LaTeX)
```

### Highlights sugeridos (borrador)

```
• WBF combines Bollinger Bands and Facebook Prophet for VM consolidation
• Evaluated on four real workloads: PlanetLab, Alibaba, Materna, Azure 2019
• WBF reduces SLA violations by up to 60% vs. classical consolidation methods
• Trade-off analysis shows WBF optimizes ESV across heterogeneous workloads
• NeuralProphet comparison confirms Prophet's suitability for cloud forecasting
```
(Verificar longitud ≤85 caracteres cada uno antes del envío)

### Criterio de salida de Fase 7

Submission package completo: manuscrito + carta de respuesta + figuras + highlights + cover letter, todos en los formatos requeridos por Elsevier y subidos al sistema de submisión de Future Generation Computer Systems.

---

## Riesgos y contingencias

| Riesgo | Probabilidad | Impacto | Plan de mitigación |
|--------|-------------|---------|-------------------|
| ~~pymodule no disponible~~ — obtenido ✅ (2026-06-03) | Baja | Alto | pymodule disponible en `networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python`; riesgo residual: verificar compatibilidad de nombres de módulo con el JAR |
| Resultados NeuralProphet peores que WBF | Media | Medio | Presentar como análisis comparativo: "NeuralProphet introduce overhead sin mejora consistente en métricas cloud; Prophet estándar ofrece mejor balance entre precisión y costo computacional" |
| Smoke test Docker falla por incompatibilidad Java 8 / arm64 | Media | Bajo | Añadir `--platform linux/amd64` al Dockerfile y al comando `docker build`; usar imagen `eclipse-temurin:8-jdk-focal` en lugar de `openjdk:8-jdk` |
| Revisores del major revision piden workloads adicionales | Baja | Alto | Google 2011 trace ya está en `workloads/` según estructura del proyecto; ejecutable con Docker si se tiene pymodule |
| Análisis E3 no muestra diferencias significativas entre workloads | Baja | Medio | Documentar la ausencia de diferencia como resultado (WBF robusto a variaciones de workload) y reenmarcarlo positivamente |
| Tiempo de ejecución E2 (AutoARIMA) excede estimación | Media | Bajo | Limitar E2 a PlanetLab únicamente; AutoARIMA es un "nice to have", no un requerimiento mínimo del re-envío |
| Paper rechazado tras major revision | Baja | Alto | Journals alternativos preparados: IEEE Transactions on Parallel and Distributed Systems (TPDS), Journal of Parallel and Distributed Computing (JPDC); el trabajo de revisión es reutilizable al 100% |
| Co-autores no responden en tiempo para revisión del borrador | Media | Medio | Establecer deadline explícito con 2 semanas de margen; enviar borrador con secciones pre-asignadas para revisión |

---

## Criterios mínimos para re-enviar

El paper está listo para re-envío cuando todos estos criterios están cumplidos:

1. **[ ]** Todos los 15+ comentarios críticos del `MAJOR_REVIEW_ACTION_PLAN.md` respondidos en la carta de respuesta a revisores
2. **[ ]** NeuralProphet añadido como comparación (E1) — tabla de resultados + texto en Discussion
3. **[ ]** Sección 4.3 (Prophet) reescrita con arquitectura, entrenamiento y cross-validation
4. **[ ]** WBF, BF(h), WBF(H0) formalmente definidos con ecuaciones en la sección de metodología
5. **[ ]** Sección de limitaciones añadida en Conclusions
6. **[ ]** Gramática revisada por herramienta + revisión manual de co-autor nativo/experto
7. **[ ]** Carta de respuesta a revisores completa con ≥15 respuestas punto a punto
8. **[ ]** Todos los valores de las tablas verificados contra datos reales en `paper4_data/`
9. **[ ]** URL del repositorio accesible añadida en el paper
10. **[ ]** Aprobación final de Sergi Vila (autor principal)

---

## Próximos 3 pasos inmediatos (esta semana)

### ~~Paso 1 — Contactar a Sergi para obtener el `pymodule`~~ ✅ Resuelto (2026-06-03)

El módulo Python está disponible en:
`networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python`

Contiene: forecastingTechniques.py, bollingerFunctions.py, signalProcessing.py, pythonBinding.py, traceImporter.py. El `launcher.json` ya ha sido actualizado con la ruta correcta.

### Paso 2 — Instalar Docker Desktop en Windows

URL: https://docs.docker.com/desktop/install/windows-install/

Una vez instalado, ejecutar en PowerShell:
```powershell
docker --version
docker run hello-world
```
Si ambos comandos funcionan, Docker está listo para la siguiente fase.

### Paso 3 — Abrir `statistics_paper4_neural.ipynb` para análisis NeuralProphet

Este es el experimento E1, el de mayor impacto en el paper y que no requiere Docker ni pymodule. Ejecutar con Python 3.8 (o en entorno virtual con dependencias instaladas):

```powershell
# Opción A: entorno virtual local (si Python 3.8 disponible)
python3.8 -m venv venv_paper4
venv_paper4\Scripts\Activate.ps1
pip install neuralprophet==0.2.7 prophet pandas==1.2.5 matplotlib jupyter
jupyter notebook statistics_paper4_neural.ipynb

# Opción B: via Docker (una vez construida la imagen en Paso 2)
docker run --rm -p 8888:8888 \
  -v "C:\Users\PcVIP\Desktop\Proyecto Sergi\networkExperiments\paper4_data:/data" \
  metacloudsim jupyter notebook --ip=0.0.0.0 --allow-root
```

Documentar los resultados obtenidos y generar figuras para el paper.

---

## Apéndice — Referencias de documentos del proyecto

| Documento | Ruta | Contenido |
|-----------|------|-----------|
| Plan de acción de revisión | `project_minimized/docs/MAJOR_REVIEW_ACTION_PLAN.md` | Lista completa de 19 acciones con prioridad, esfuerzo y estado |
| Informe de reproducibilidad | `project_minimized/docs/REPRODUCIBILITY_REPORT.md` | Estado actual del entorno, bloqueadores y soluciones |
| Especificaciones del paper | `project_minimized/docs/PAPER4_SPECS.md` | Descripción técnica completa del paper |
| Auditoría de código | `project_minimized/docs/CODE_AUDIT.md` | Análisis del código de simulación |
| Informe de minimización | `project_minimized/docs/PROJECT_MINIMIZATION_REPORT.md` | Estado del proyecto minimizado |
| Datos de referencia | `networkExperiments/paper4_data/` | Resultados originales — ground truth (Tablas 6–9) |
| Notebook NeuralProphet | `statistics_paper4_neural.ipynb` | Análisis E1 — ejecutar como prioridad |
| Notebooks por workload | `p4_test3_materna_tuning_30.ipynb`, `p4_test3_alibaba_30.ipynb`, `p4_test3_azure_30.ipynb` | Análisis E3 y E4 |
| Dockerfile | `project_minimized/Dockerfile` | Entorno reproducible en Docker |
| Docker Compose | `project_minimized/docker-compose.yml` | Orquestación de servicios |

---

*Documento generado el 2026-06-02. Actualizar criterios de salida y estados conforme avance el trabajo.*
