% Modelo de Black-Scholes con gráficos para opciones Call y Put
clear; clc; close all;

%% Parámetros base
S0 = 5761;         % Precio actual del S&P 500
K = 5900;          % Precio de ejercicio
r = 0.05;          % Tasa libre de riesgo (anual)
sigma = 0.20;      % Volatilidad (anual)
T = 0.5;           % Tiempo hasta el vencimiento (años)

%% Rango de precios del subyacente para graficar
S = 5400:10:6300;  % Precios hipotéticos del S&P 500

%% Inicializar vectores de precios de opciones
Call = zeros(size(S));
Put = zeros(size(S));

%% Calcular precios de las opciones para cada valor de S
for i = 1:length(S)
    d1 = (log(S(i)/K) + (r + sigma^2/2)*T) / (sigma * sqrt(T));
    d2 = d1 - sigma * sqrt(T);

    Call(i) = S(i) * normcdf(d1) - K * exp(-r*T) * normcdf(d2);
    Put(i)  = K * exp(-r*T) * normcdf(-d2) - S(i) * normcdf(-d1);
end

%% Graficar los resultados
figure;
plot(S, Call, 'b-', 'LineWidth', 2); hold on;
plot(S, Put, 'r-', 'LineWidth', 2);
xlabel('Precio del S&P 500 (S)');
ylabel('Valor de la opción (USD)');
title('Modelo de Black-Scholes: Valor de Call y Put vs. Precio del Subyacente');
legend('Call', 'Put', 'Location', 'northwest');
grid on;
