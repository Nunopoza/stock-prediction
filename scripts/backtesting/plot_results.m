function plot_results(PnL)
% PLOT_RESULTS: Grafica el P&L acumulado

figure
plot(PnL, 'LineWidth', 1.5)
grid on
xlabel('Time')
ylabel('Cumulative P&L')
title('Backtest Results')
end
