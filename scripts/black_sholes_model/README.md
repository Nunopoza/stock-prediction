## Objetivo
Verificar que la implementación del modelo Black-Scholes en MATLAB:
- Calcule correctamente el precio de opciones europeas Call y Put.
- Genere gráficas precisas del comportamiento del valor de las opciones frente al precio del subyacente.
- Cumpla con propiedades teóricas como la paridad Put-Call.

## Archivos Relevantes
- black_scholes_plot.m — Código principal con gráficos.
- black_scholes_basic.m — Versión simple sin visualización (opcional).
- test_black_scholes.m — Script de pruebas (si decides hacerlo).

## Casos de Prueba
Test ID	Descripción	Entrada	Resultado Esperado
- T1	Cálculo básico Call/Put	S = 4500, K = 4600, r = 0.05, σ = 0.2, T = 0.5	Devuelve valores Call y Put positivos
- T2	Paridad Put-Call	S = K = 4500	Call - Put ≈ S - K * exp(-r*T)
- T3	Opciones "in-the-money"	S ≫ K (ej. S = 5000, K = 4600)	Valor Call alto, Put bajo
- T4	Opciones "out-of-the-money"	S ≪ K (ej. S = 4000, K = 4600)	Valor Call bajo, Put alto
- T5	Gráfica limpia	Rango de S entre 4000 y 5000	Se muestran dos curvas suaves, sin errores
- T6	Tiempo al vencimiento cero	T = 0	Call = max(S - K, 0), Put = max(K - S, 0)

## Procedimiento de Testeo
1. Ejecutar el script principal (black_scholes_plot.m).
2. Verificar visualmente la gráfica generada.
3. Probar distintas combinaciones de parámetros (usando los casos de prueba).
4. Validar la fórmula de paridad Put-Call.
5. (Opcional) Comparar con resultados de sitios como option-price.com para confirmar precisión.

