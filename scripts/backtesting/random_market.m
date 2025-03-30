function [S, vol_series] = random_market(T, dt, mu, sigma0, alpha, beta, omega)
    N = round(T / dt);
    S = zeros(N,1);
    vol_series = zeros(N,1);
    S(1) = 100; % Precio inicial
    vol_series(1) = sigma0;

    for t = 2:N
        % Choque aleatorio
        Z = randn();

        % Volatilidad tipo GARCH
        vol_series(t) = sqrt( omega + alpha * (vol_series(t-1) * Z)^2 + beta * vol_series(t-1)^2 );

        % Precio
        S(t) = S(t-1) * exp( (mu - 0.5 * vol_series(t)^2) * dt + vol_series(t) * sqrt(dt) * randn() );
    end
end
