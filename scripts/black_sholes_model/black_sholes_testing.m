% black_scholes_full_test.m
% Test del modelo de Black-Scholes con datos actuales (marzo 2025)

clc; clear; close all;

%% Configuración
result_dir = fullfile('results', 'results_black_scholes');
if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end

log_file = fullfile(result_dir, 'black_scholes_test_log.txt');
fid = fopen(log_file, 'w');
logprint = @(str) fprintf(fid, "%s\n", str);

logprint("===== Test del Modelo Black-Scholes =====");

%% Parámetros base
S = 5767.57;   % Precio actual del S&P 500 (marzo 2025)
K = 5800;      % Strike cercano
r = 0.045;     % Tasa libre de riesgo (4.5%)
sigma = 0.18;  % Volatilidad anual (18%)
T = 0.5;       % 6 meses

%% Test T1 – Cálculo básico
logprint("\nT1: Cálculo básico Call/Put");
[call, put] = black_scholes_price(S, K, r, sigma, T);
assert(call > 0 && put > 0, "Call o Put no son positivos.");
logprint(sprintf("Call = %.2f, Put = %.2f", call, put));

%% Test T2 – Paridad Put-Call
logprint("\nT2: Paridad Put-Call");
S2 = 5767.57; K2 = 5767.57;
[call2, put2] = black_scholes_price(S2, K2, r, sigma, T);
lhs = call2 - put2;
rhs = S2 - K2 * exp(-r*T);
assert(abs(lhs - rhs) < 1e-2, "No se cumple la paridad Put-Call.");
logprint(sprintf("Paridad verificada: Call - Put = %.2f ≈ %.2f", lhs, rhs));

%% Test T3 – In-the-money
logprint("\nT3: Opción in-the-money");
[call, put] = black_scholes_price(6000, 5600, r, sigma, T);
assert(call > put, "Call no es mayor que Put in-the-money.");
logprint(sprintf("Call = %.2f, Put = %.2f", call, put));

%% Test T4 – Out-of-the-money
logprint("\nT4: Opción out-of-the-money");
[call, put] = black_scholes_price(5400, 5800, r, sigma, T);
assert(put > call, "Put no es mayor que Call out-of-the-money.");
logprint(sprintf("Call = %.2f, Put = %.2f", call, put));

%% Test T5 – Gráfico Call/Put vs S
logprint("\nT5: Gráfico Call/Put vs S");
S_range = 5400:10:6100;
Call = zeros(size(S_range));
Put = zeros(size(S_range));
for i = 1:length(S_range)
    [Call(i), Put(i)] = black_scholes_price(S_range(i), K, r, sigma, T);
end
figure;
plot(S_range, Call, 'b', S_range, Put, 'r', 'LineWidth', 2);
xlabel('Precio del subyacente (S)');
ylabel('Valor de la opción');
title('Valor de Call y Put según S');
legend('Call', 'Put'); grid on;
saveas(gcf, fullfile(result_dir, 'call_put_vs_S.png'));
logprint("Gráfico Call/Put guardado.");

%% Test T6 – Vencimiento inmediato
logprint("\nT6: Vencimiento inmediato (T=0)");
call_T0 = max(S - K, 0);
put_T0 = max(K - S, 0);
logprint(sprintf("Call = %.2f, Put = %.2f (T = 0)", call_T0, put_T0));

%% Test A1 – Vega
logprint("\nA1: Sensibilidad a la volatilidad (Vega)");
sigmas = 0.1:0.01:0.5;
calls_vega = zeros(size(sigmas));
for i = 1:length(sigmas)
    [calls_vega(i), ~] = black_scholes_price(S, K, r, sigmas(i), T);
end
figure;
plot(sigmas, calls_vega, 'LineWidth', 2);
xlabel('Volatilidad');
ylabel('Valor del Call');
title('Sensibilidad del Call a la Volatilidad');
grid on;
saveas(gcf, fullfile(result_dir, 'vega_plot.png'));
logprint("Gráfico Vega guardado.");

%% Test A2 – Theta
logprint("\nA2: Sensibilidad al tiempo (Theta)");
Ts = 0.01:0.01:1.0;
calls_theta = zeros(size(Ts));
for i = 1:length(Ts)
    [calls_theta(i), ~] = black_scholes_price(S, K, r, sigma, Ts(i));
end
figure;
plot(Ts, calls_theta, 'm', 'LineWidth', 2);
xlabel('Tiempo hasta vencimiento (años)');
ylabel('Valor del Call');
title('Sensibilidad del Call al Tiempo');
grid on;
saveas(gcf, fullfile(result_dir, 'theta_plot.png'));
logprint("Gráfico Theta guardado.");

%% Test A3 – Superficie 3D
logprint("\nA3: Superficie 3D (Call vs S y sigma)");
[S_grid, sigma_grid] = meshgrid(5400:50:6100, 0.1:0.02:0.5);
call_surface = zeros(size(S_grid));
for i = 1:size(S_grid,1)
    for j = 1:size(S_grid,2)
        [call_surface(i,j), ~] = black_scholes_price(S_grid(i,j), K, r, sigma_grid(i,j), T);
    end
end
figure;
surf(S_grid, sigma_grid, call_surface);
xlabel('Precio del subyacente (S)');
ylabel('Volatilidad');
zlabel('Valor del Call');
title('Superficie del valor del Call');
saveas(gcf, fullfile(result_dir, 'call_surface_3D.png'));
logprint("Superficie 3D guardada.");

%% Final
logprint("\n===== Todos los tests completados correctamente =====");
fclose(fid);
fprintf("Log guardado en: %s\n", log_file);

%% Función de valoración Black-Scholes
function [call, put] = black_scholes_price(S, K, r, sigma, T)
    d1 = (log(S./K) + (r + sigma.^2 / 2) .* T) ./ (sigma .* sqrt(T));
    d2 = d1 - sigma .* sqrt(T);
    call = S .* normcdf(d1) - K .* exp(-r .* T) .* normcdf(d2);
    put  = K .* exp(-r .* T) .* normcdf(-d2) - S .* normcdf(-d1);
end
