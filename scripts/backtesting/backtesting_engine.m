function [PnL, position] = backtest_engine(prices, signals, initial_cash)
% BACKTEST_ENGINE: Performs a simple backtest on generated signals
% Inputs:
%   prices        - Vector de precios [n x 1]
%   signals       - Vector de señales de trading [-1, 0, 1]
%   initial_cash  - Capital inicial

n = length(prices);
position = zeros(n,1);
PnL = zeros(n,1);
cash = initial_cash;

for t = 2:n
    % Mantener posición anterior o actualizar
    if signals(t) ~= 0
        position(t) = signals(t);
    else
        position(t) = position(t-1);
    end
    
    % Variación diaria
    ret = (prices(t) - prices(t-1)) / prices(t-1);
    
    % Actualización del P&L acumulado
    PnL(t) = PnL(t-1) + position(t-1) * cash * ret;
end

end
