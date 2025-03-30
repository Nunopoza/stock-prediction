function [signals, margin_ma_12m, margin_values, common_dates] = strategy_marginDebt(dates_sp500, prices_sp500, margin_dates, margin_values_raw)
% Estrategia basada en Margin Debt y Media móvil de 12 meses

%% ---- Preprocesado de datos ----
% Calcular media móvil
window_12m = 12;
margin_ma_12m = movmean(margin_values_raw, window_12m, 'omitnan');

% Encontrar fechas comunes
[common_dates, idx_sp500, idx_margin] = intersect(dates_sp500, margin_dates);
prices_sp500 = prices_sp500(idx_sp500);
margin_values = margin_values_raw(idx_margin);
margin_ma_12m = margin_ma_12m(idx_margin);

%% ---- Generación de señales ----
buy_threshold = 0.005;
sell_threshold = -0.005;

signals = zeros(size(margin_values));

for i = 2:length(margin_values)
    diff = (margin_ma_12m(i) - margin_values(i)) / margin_values(i);
    if diff > buy_threshold
        signals(i) = 1; % Señal de compra
    elseif diff < sell_threshold
        signals(i) = -1; % Señal de venta
    end
end

end
