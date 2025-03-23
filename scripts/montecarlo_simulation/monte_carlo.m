% Clear workspace
close all;
clear;
clc;
try
    % Load stock price data from a CSV file (adjust filename and path as needed)
    stockData = readtable(fullfile('/Users/nunopoza/stock-prediction', 'data', 'sp500_data.csv'), 'PreserveVariableNames', true);
    
    % Only show data for 2025
    nDays = 250; 
    stockData_1_n = stockData(1:nDays, :);
    
    % Extract relevant columns from the table
    dates = stockData_1_n.timestamp;
    closes = stockData_1_n.close;
    % Calculate daily log returns
    dailyReturns = diff(log(closes)); % Log returns for accuracy
    % Calculate volatility (standard deviation of daily log returns)
    volatility = 3*std(dailyReturns);
    % Annualize volatility
    volatility_annual = volatility * sqrt(252); % Assuming 252 trading days in a year
    disp(['Historical volatility (annual): ', num2str(volatility_annual)]);
    % Calculate drift (average daily log return)
    mu = mean(dailyReturns);
    % Annualize drift
    mu_annual = mu * 252; % Assuming 252 trading days in a year
    disp(['Historical mu (annual): ', num2str(mu_annual)]);
    % Define parameters for Monte Carlo simulation
    T = 5;                   % Time period in years (adjust as needed)
    nSimulations = 1000;    % Number of Monte Carlo simulations
    nSteps = 252;            % Number of trading days in a year
    dt = T / nSteps;         % Time step
    S0 = closes(end);        % Initial stock price (last closing price in the data)
    % Preallocate matrix to store simulation results
    priceMatrix = zeros(nSimulations, nSteps);
    % Monte Carlo simulation
    for i = 1:nSimulations
        % Generate random shocks (Wiener process increments)
        dW = sqrt(dt) * randn(1, nSteps);
        % Initialize price path
        pricePath = zeros(1, nSteps);
        pricePath(1) = S0;
        % Simulate price path using GBM
        for j = 2:nSteps
            pricePath(j) = pricePath(j - 1) * exp((mu - 0.5 * volatility^2) * dt + volatility * dW(j));
        end
        % Store price path in matrix
        priceMatrix(i, :) = pricePath;
    end
    % Plot 1: Historical Stock Prices
    figure;
    subplot(2, 2, 1);
    plot(dates, closes, 'b-', 'LineWidth', 1.5);
    xlabel('Date');
    ylabel('Stock Price');
    title('Historical Stock Prices');
    grid on;
    saveas(gcf, '/Users/nunopoza/stock-prediction/results/montecarlo_simulation.png');  
    
    % Plot 2: Monte Carlo Simulation Results
    subplot(2, 2, 2);
    plot(dates(end) + (1:nSteps) * dt * 252, priceMatrix', 'Color', [0.5, 0.5, 0.5]);
    xlabel('Date');
    ylabel('Stock Price');
    title('Monte Carlo Simulation of Stock Prices');
    grid on;
    saveas(gcf, '/Users/nunopoza/stock-prediction/results/montecarlo_simulation_results.png');  

    
    % Plot 3: Historical and Monte Carlo Combined
    subplot(2, 2, [3, 4]);
    plot(dates, closes, 'b-', 'LineWidth', 1.5);
    hold on;
    plot(dates(end) + (1:nSteps) * dt * 252, priceMatrix', 'Color', [0.5, 0.5, 0.5]);
    hold off;
    xlabel('Date');
    ylabel('Stock Price');
    title('Historical and Monte Carlo Simulation Comparison');
    legend('Historical Data', 'Monte Carlo Simulation', 'Location', 'northwest');
    grid on;
    saveas(gcf, '/Users/nunopoza/stock-prediction/results/montecarlo_simulation_with_price.png');  
    
    % Adjust figure layout
    sgtitle('Stock Price Analysis');
    set(gcf, 'Position', [10, 100, 1200, 800]); % Adjust figure position (left: 10 pixels, top: 100 pixels, width: 1200, height: 800)
    % Display statistics
    finalPrices = priceMatrix(:, end);
    meanPrice = mean(finalPrices);
    probPriceIncrease = sum(finalPrices > S0) / nSimulations;
    probPriceDecrease = sum(finalPrices < S0) / nSimulations;
    disp(['Mean final price (Monte Carlo): ', num2str(meanPrice)]);
    disp(['Probability of price increase (Monte Carlo): ', num2str(probPriceIncrease)]);
    disp(['Probability of price decrease (Monte Carlo): ', num2str(probPriceDecrease)]);
     % Calculate statistics from Monte Carlo simulations
 
    finalPrices = priceMatrix(:, end);
    maxPrice = max(finalPrices);
    meanPrice= mean(finalPrices);
    minPrice = min(finalPrices);
    probMax = sum(finalPrices == maxPrice) / nSimulations;
    probMin = sum(finalPrices == minPrice) / nSimulations;
    disp(['Maximum predicted price: ', num2str(maxPrice)]);
    disp(['Probability of maximum price: ', num2str(probMax)]);
    disp(['Minimum predicted price: ', num2str(minPrice)]);
    disp(['Probability of minimum price: ', num2str(probMin)]);
    disp(['Mean predicted price: ', num2str(meanPrice)]);
    T_out = table(meanPrice, maxPrice, minPrice, probPriceIncrease, probPriceDecrease, probMax, probMin);
    writetable(T_out, '/Users/nunopoza/stock-prediction/results/montecarlo_summary.csv');
catch ME
    % Display error message
    disp('Error occurred:');
    disp(ME.message);
end


