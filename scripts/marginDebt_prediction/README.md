# Margin Debt-Based Trading Strategy - MATLAB

This project implements an investment strategy based on the relationship between the S&P 500 Index and the evolution of Margin Debt.


## Strategy Logic

The strategy is based on:

- Buy when Margin Debt is above its 12-month moving average (rising optimism).
- Sell when it falls below (loss of confidence or overbought).
- Additional conditions:
  - Stop loss: -15% **Take profit:** +20
  - Take profit: +20% **Take profit:** +20
  - Maximum holding period: 12 months
  - Additional investment of $200 each month

---

## Files

- `marginDebt_predictor.m`: complete script with download, filtering, strategy and visualization
- `/data/`: contains:
  - `sp500_data.csv` (index prices).
  - `margin-statistics.xlsx` (FINRA data on Margin Debt)
- `/results/results_marginDebt/`:
  - `marginDebt_simulation.png`: graph of portfolio vs invested capital.
  - `marginDebt_summary.csv`: statistical summary

---

## Calculated Statistics

- Final total and annualized returns
- Maximum drawdown (**drawdown**)
- Sharpe Ratio
- Total number of trades
- Hit Rate (profitable trades)
- Average return per trade
- Maximum / minimum return



## Requirements

- MATLAB R2021b or higher (datetime compatible)
- Data files in the `/data/` folder
- Folder structure: