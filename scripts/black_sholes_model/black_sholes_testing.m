% test_black_scholes.m
% Script de test para validar el modelo de Black-Scholes y guardar el log

clc; clear; close all;

%% Crear carpeta de resultados si no existe
result_dir = fullfile('results', 'results_black_scholes');
if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end

log_file = fullfile(result_dir, 'black_scholes_test_log.txt');
fid = fopen(log_file, 'w'); % abrir archivo para escribir

% Función auxiliar para imprimir en consola y guardar log
logprint = @(str) fprintf(fid, "%s\n", str);

fprintf("===== Test del Modelo Black-Scholes =====\n");
logprint("===== Test del Modelo Black-Scholes =====");

% Parámetros comunes
r = 0.05;
sigma = 0.2;
T = 0.5;

% Helper: función para calcular Call y Put
black_scholes = @(S, K) deal( ...
    S * normcdf((log(S/K)+(r+sigma^2/2)*T)/(sigma*sqrt(T))) - ...
    K * exp(-r*T) * normcdf((log(S/K)+(r-sigma^2/2)*T)/(sigma*sqrt(T))), ...
    K * exp(-r*T) * normcdf(-(log(S/K)+(r-sigma^2/2)*T)/(sigma*sqrt(T))) - ...
    S * normcdf(-(log(S/K)+(r+sigma^2/2)*T)/(sigma*sqrt(T))) ...
);

%% Test T1 – Cálculo básico Call/Put
logprint("\nT1: Cálculo básico Call/Put");
[S, K] = deal(4500, 4600);
[call, put] = black_scholes(S, K);
assert(call > 0 && put > 0, " Call o Put no son positivos.");
logprint(sprintf(" Call = %.2f, Put = %.2f", call, put));

%% Test T2 – Paridad Put-Call
logprint("\nT2: Paridad Put-Call");
S = 4500; K = 4500;
[call, put] = black_scholes(S, K);
lhs = call - put;
rhs = S - K * exp(-r*T);
tolerancia = 1e-2;
assert(abs(lhs - rhs) < tolerancia, " No se cumple la paridad Put-Call.");
logprint(sprintf("Paridad verificada: Call - Put = %.2f ≈ %.2f", lhs, rhs));

%% Test T3 – Opción in-the-money
logprint("\nT3: Opción in-the-money (S >> K)");
[S, K] = deal(5000, 4600);
[call, put] = black_scholes(S, K);
assert(call > put, " Call no es significativamente mayor que Put.");
logprint(sprintf(" Call = %.2f, Put = %.2f", call, put));

%% Test T4 – Opción out-of-the-money (S << K)
logprint("\nT4: Opción out-of-the-money (S << K)");
[S, K] = deal(4000, 4600);
[call, put] = black_scholes(S, K);
assert(put > call, " Put no es significativamente mayor que Call.");
logprint(sprintf(" Call = %.2f, Put = %.2f", call, put));

%% Test T5 – Rango gráfico sin errores
logprint("\nT5: Gráfico limpio");
try
    S_range = 4000:10:5000;
    Call = zeros(size(S_range));
    Put = zeros(size(S_range));
    for i = 1:length(S_range)
        [Call(i), Put(i)] = black_scholes(S_range(i), 4600);
    end
    figure;
    plot(S_range, Call, 'b', S_range, Put, 'r');
    title('Test Gráfico Call vs Put');
    xlabel('Precio S');
    ylabel('Valor opción');
    legend('Call', 'Put');
    grid on;
    saveas(gcf, fullfile(result_dir, 'black_scholes_plot_test.png'));
    logprint(" Gráfico generado y guardado correctamente.");
catch
    error(" Error al generar el gráfico");
end

%% Test T6 – Tiempo al vencimiento cero
logprint("\nT6: Vencimiento inmediato (T = 0)");
S = 4600; K = 4600; T = 0;
call = max(S - K, 0);
put  = max(K - S, 0);
logprint(sprintf(" Call = %.2f, Put = %.2f (vencimiento inmediato)", call, put));

logprint("\n===== Todos los tests completados correctamente =====");

fclose(fid); % cerrar archivo

fprintf("\n Log guardado en: %s\n", log_file);
