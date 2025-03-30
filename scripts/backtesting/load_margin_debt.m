function [margin_dates, margin_values] = load_margin_debt(filename)
    
    % Detecta opciones sin especificar hoja (usar por defecto)
    opts = detectImportOptions(filename, 'VariableNamingRule', 'preserve');
    
    % Leer la tabla completa
    margin_data = readtable(filename, opts);
    
    % Ajustar columnas reales según tu Excel
    fecha_columna = 'Year-Month';   % <-- asegúrate que tu excel tiene esta columna
    deuda_columna = 'Debt';         % <-- asegúrate que la columna se llama exactamente así
    
    % Extraer datos
    margin_dates = datetime(margin_data.(fecha_columna), 'InputFormat', 'yyyy-MM');
    margin_values = margin_data.(deuda_columna);
    
    disp("Datos de Margin Debt cargados correctamente.");
end
