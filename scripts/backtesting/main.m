clear; close all; clc;

filename_sp500 = fullfile('data', 'sp500_data.csv');
filename_finra = fullfile('data','margin-statistics.xlsx');

[dates_sp500, prices_sp500] = load_sp500(filename_sp500);
[margin_dates, margin_values_raw] = load_margin_debt(filename_finra);

[signals, margin_ma_12m, margin_values, common_dates] = strategy_marginDebt(...
    dates_sp500, prices_sp500, margin_dates, margin_values_raw);

[PnL, position] = backtest_engine(prices_sp500, signals, 100000);

plot_results(PnL)
