clc; clear; close all;

% 📌 Nombre del archivo CSV con los datos del S&P 500
filename_sp500 = 'sp500_data.csv';

% 📌 Leer archivo CSV
opts = detectImportOptions(filename_sp500, 'VariableNamingRule', 'preserve');
sp500_data = readtable(filename_sp500, opts);

% 📌 Detectar columnas de fecha y precio de cierre
fecha_columna = sp500_data.Properties.VariableNames{1};  % Primera columna (Fecha)
precio_columna = sp500_data.Properties.VariableNames{5}; % Última columna (Precio cierre)

% 📌 Convertir a formato datetime
dates_sp500 = datetime(sp500_data.(fecha_columna), 'InputFormat', 'yyyy-MM-dd', 'Format', 'yyyy-MM-dd');
prices_sp500 = sp500_data.(precio_columna);

% 📌 Ordenar datos por fecha
[dates_sp500, idx] = sort(dates_sp500);
prices_sp500 = prices_sp500(idx);

disp("Datos del S&P 500 cargados correctamente.");

% 📌 Nombre del archivo Excel con Margin Debt
filename_finra = 'margin-statistics.xlsx';

% 📌 Leer datos
opts = detectImportOptions(filename_finra, 'Sheet', 1, 'VariableNamingRule', 'preserve');
margin_data = readtable(filename_finra, opts);

% 📌 Columnas correctas
fecha_columna = 'Year-Month';
deuda_columna = 'Debt';

% 📌 Convertir fechas y valores
margin_dates = datetime(margin_data.(fecha_columna), 'InputFormat', 'yyyy-MM');
margin_values = margin_data.(2);

% 📌 Calcular media móvil de 12 meses
window_12m = 12;
margin_ma_12m = movmean(margin_data.(2), window_12m, 'omitnan');

disp("Datos de Margin Debt cargados correctamente.");

% 📌 Encontrar fechas comunes entre ambos conjuntos de datos
[common_dates, idx_sp500, idx_margin] = intersect(dates_sp500, margin_dates);
sp500_filtered = prices_sp500(idx_sp500);

% 📌 Ajustar longitudes de los datos
min_length = min([length(common_dates), length(sp500_filtered), length(margin_values)]);
common_dates = common_dates(1:min_length);
sp500_filtered = sp500_filtered(1:min_length);
margin_values = margin_values(idx_margin(1:min_length));
margin_ma_12m = margin_ma_12m(idx_margin(1:min_length));

disp("Fechas alineadas correctamente.");

% 📌 Parámetros de la estrategia
buy_threshold = 0.005; % Comprar si Margin Debt MA está 2% arriba
sell_threshold = -0.005; % Vender si está 2% abajo
stop_loss = -0.15; % -10%
take_profit = 0.20; % +20%

signals = zeros(size(margin_values));

for i = 2:length(margin_values)
    diff = (margin_ma_12m(i) - margin_values(i)) / margin_values(i);
    if diff > buy_threshold
        signals(i) = 1; % Comprar
    elseif diff < sell_threshold
        signals(i) = -1; % Vender
    end
end

disp("Estrategia de trading calculada.");

% 📌 Configuración inicial
initial_cash = 10000;
max_holding_period = 12; % Máximo 6 meses manteniendo posición
holding_period = 0;
shares = 0;
cash = initial_cash;
portfolio_value = nan(size(sp500_filtered));
num_trades = 0;
winning_trades = 0;
contador_mensual = 0;
trade_returns = [];
dinero_metido_despues = [10000];
buy_price_list = [];
media_movil_sp500 = movmean(sp500_filtered, [12 0]); % Media móvil de 8 meses del S&P500
espera_minima = 1; % Espera mínima en meses entre operaciones
last_trade_index = -inf; % Índice temporal última operación

for i = 2:length(sp500_filtered)

    dinero_metido_despues(i) = dinero_metido_despues(i-1) + 200;
    cash = cash + 200;

    % Condición de compra: señal, sin acciones y SP500 > su media móvil
    if (signals(i) == 1) && (shares == 0) && (i - last_trade_index >= espera_minima)  
        shares = cash / sp500_filtered(i);
        cash = 0;
        buy_price = sp500_filtered(i);
        holding_period = 0;
        last_trade_index = i; % Actualizar último índice de operación
        disp(" COMPRA en " + datestr(common_dates(i)) + " a $" + num2str(buy_price));
        buy_price_list(i) = buy_price;
        if(buy_price_list(i)== 0)
            buy_price_list(i) = NaN;
        end
        num_trades = num_trades + 1;

    % Condición de venta: señal, stop loss, take profit o periodo máximo
    elseif shares > 0
        current_return = (sp500_filtered(i) - buy_price) / buy_price;
        
        if signals(i) == -1 || current_return <= stop_loss || current_return >= take_profit || holding_period >= max_holding_period
            sell_price = sp500_filtered(i);
            trade_return = current_return;
            trade_returns = [trade_returns, trade_return];

            if trade_return > 0
                winning_trades = winning_trades + 1;
            end

            cash = shares * sp500_filtered(i);
            shares = 0;
            holding_period = 0;

            if current_return <= stop_loss
                disp("STOP LOSS en " + datestr(common_dates(i)) + " a $" + num2str(sell_price) + " | Rentabilidad: " + num2str(trade_return * 100, '%.2f') + " %");
            elseif current_return >= take_profit
                disp("TAKE PROFIT en " + datestr(common_dates(i)) + " a $" + num2str(sell_price) + " | Rentabilidad: " + num2str(trade_return * 100, '%.2f') + " %");
            elseif holding_period >= max_holding_period
                disp(" FORZADA VENTA en " + datestr(common_dates(i)) + " a $" + num2str(sell_price) + " | Rentabilidad: " + num2str(trade_return * 100, '%.2f') + " %");
            else
                disp("VENTA en " + datestr(common_dates(i)) + " a $" + num2str(sell_price) + " | Rentabilidad: " + num2str(trade_return * 100, '%.2f') + " %");
            end
            num_trades = num_trades + 1;
        else
            holding_period = holding_period + 1;
        end
    end

    % Actualizar valor del portafolio
    portfolio_value(i) = cash + (shares * sp500_filtered(i));
end

% 📌 Rentabilidad final (%)
final_return = (portfolio_value(end) - initial_cash) / initial_cash * 100;

% 📌 Rentabilidad anualizada (%)
num_years = years(common_dates(end) - common_dates(1));
annualized_return = ((portfolio_value(end) / initial_cash)^(1/num_years) - 1) * 100;

% 📌 Máxima caída (Drawdown)
max_value = max(portfolio_value);
max_drawdown = min(portfolio_value - max_value) / max_value * 100;

% 📌 Ratio de Sharpe
% 📌 Evitar cálculos con NaN
valid_indices = ~isnan(portfolio_value);
valid_portfolio = portfolio_value(valid_indices);
risk_free_rate = 0.05; % Supongamos 2% de tasa libre de riesgo anual

% 📌 Calcular Ratio de Sharpe alternativo
if length(valid_portfolio) > 2
    total_return = (valid_portfolio(end) - valid_portfolio(1)) / valid_portfolio(1); % Rentabilidad total
    vol = std(valid_portfolio); % Desviación estándar del portafolio

    if vol > 0
        sharpe_ratio = (annualized_return - risk_free_rate) / vol; % Fórmula modificada
    else
        sharpe_ratio = NaN; % No se puede calcular
    end
else
    sharpe_ratio = NaN; % No hay suficientes datos
end

disp("Ratio Sharpe: " + num2str(sharpe_ratio, '%.2f'));

% 📌 Calcular tasa de acierto (% de operaciones ganadoras)
if num_trades > 0
    % Solo contamos las operaciones cerradas (pares de compra/venta)
    num_closed_trades = num_trades / 2;  

    if num_closed_trades > 0
        win_rate = (winning_trades / num_closed_trades) * 100;  
    else
        win_rate = 0; % No se cerraron operaciones, tasa de acierto = 0%
    end
else
    win_rate = 0; % Si no hubo operaciones, tasa de acierto = 0%
end

disp("Tasa de acierto: " + num2str(win_rate, '%.2f') + " %");


% 📌 Imprimir resultados
disp("----- Resultados de la Estrategia -----");
disp("Rentabilidad final: " + num2str(final_return, '%.2f') + " %");
disp("Cartera final: " + fix(portfolio_value(end)) + " $");
disp("Rentabilidad anualizada: " + num2str(annualized_return, '%.2f') + " %");
disp("Máxima caída (Drawdown): " + num2str(max_drawdown, '%.2f') + " %");
disp("Ratio Sharpe: " + sharpe_ratio);
disp("Número total de operaciones: " + num2str(num_trades));
disp("Tasa de acierto: " + num2str(win_rate, '%.2f') + " %");

disp("Rentabilidades de cada operación:");
disp(trade_returns * 100);

% 📌 Verificar estadísticas básicas
disp("Rentabilidad media por operación: " + num2str(mean(trade_returns), '%.2f') + " %");
disp("Rentabilidad máxima: " + num2str(max(trade_returns), '%.2f') + " %");
disp("Rentabilidad mínima: " + num2str(min(trade_returns), '%.2f') + " %");

% Bandas de bollinger
[middle,upper,lower]= bollinger(prices_sp500);
CloseBolling = [middle, upper, lower];

% Manipulamos array de precios
buy_price_list(end+1,end+3)= NaN;
buy_price_list(2, :) = [];
buy_price_list(buy_price_list == 0) = NaN;
buy_price_listT = buy_price_list.';


%buy_price_listT(end+1,end+3)= NaN;
% Gráficas y ploteos
x1 = common_dates;
x2 = dates_sp500;
y1 = sp500_filtered;
y2 = prices_sp500;
y3 = margin_values;
y4 = margin_ma_12m;
y5 = dinero_metido_despues;
y6 = portfolio_value;
y7 = buy_price_listT;

% Medium plot
%ax2 = nexttile;
%plot(ax2,x2,y2,x2,CloseBolling)
%title(ax2, 'Sp500 puro')
%ylabel(ax2,'Prices puros')

% Bottom plotfigure;
ax3 = nexttile;
plot(ax3,x1,y5,x1,y6)

ax4 = nexttile;
plot(ax4, x1, y1, x1, y7, "r.", 'MarkerSize', 10)
