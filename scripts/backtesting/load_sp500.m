function [dates_sp500, prices_sp500] = load_sp500(filename)
    opts = detectImportOptions(filename, 'VariableNamingRule', 'preserve');
    sp500_data = readtable(filename, opts);
    fecha_columna = sp500_data.Properties.VariableNames{1};  
    precio_columna = sp500_data.Properties.VariableNames{5}; 

    dates_sp500 = datetime(sp500_data.(fecha_columna), 'InputFormat', 'yyyy-MM-dd', 'Format', 'yyyy-MM-dd');
    prices_sp500 = sp500_data.(precio_columna);

    [dates_sp500, idx] = sort(dates_sp500);
    prices_sp500 = prices_sp500(idx);

    disp("Datos del S&P500 cargados correctamente.");
end
