function [S, vol_series] = simulate_market(T, dt, mu, sigma0, alpha, beta, omega)
    N = round(T / dt);
    S = zeros(N,1);
    vol_series = zeros(N,1);
    S(1) = 100; % Precio inicial
    vol_series(1) = sigma0;

    for t = 2:N
        % Choque aleatorio
        Z = randn();

        % Actualización de volatilidad tipo GARCH
        vol_series(t) = sqrt( omega + alpha * (vol_series(t-1) * Z)^2 + beta * vol_series(t-1)^2 );

        % Precio
        S(t) = S(t-1) * exp( (mu - 0.5 * vol_series(t)^2) * dt + vol_series(t) * sqrt(dt) * randn() );
    end
end
T = 20;                  % 1 año
dt = 1/252;             % diario
mu = 0.05;              % 5% drift anual
sigma0 = 0.3;           % volatilidad inicial (30%)
alpha = 0.1;            % efecto del shock
beta = 0.85;            % persistencia de la volatilidad
omega = 0.0005;         % volatilidad base

[S, vol] = simulate_market(T, dt, mu, sigma0, alpha, beta, omega);

subplot(2,1,1)
plot(S)
title('Precio simulado')

subplot(2,1,2)
plot(vol)
title('Volatilidad simulada')
