function signals = strategy_MA_crossover(prices, short_window, long_window)
% STRATEGY_MA_CROSSOVER: Genera señales de trading basadas en cruce de medias móviles

signals = zeros(length(prices),1);

shortMA = movmean(prices, short_window);
longMA = movmean(prices, long_window);

signals(shortMA > longMA) = 1;   % Señal de compra
signals(shortMA < longMA) = -1;  % Señal de venta
signals(shortMA == longMA) = 0;  % Neutral

end
