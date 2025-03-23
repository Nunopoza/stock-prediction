# Monte Carlo Simulation of Stock Prices - MATLAB

This project performs a price simulation of a financial asset (S&P500) using the geometric Brownian motion model (GBM), based on real data.

## Features.

- 250 days of historical data
- Historical drift and volatility calculation
- 5-year forward simulation with 5,000 trajectories
- Trajectory, histogram and comparison charts
- Export of results and key statistics

## Structure

- `montecarlo_sim.m`: main script
- `montecarlo_sim.mlx`: Live Script with visualizations and explanation
- `/results/`: `.png` graphics and `.csv` summary
- `/html/`: exported HTML version for visualization without MATLAB

## How to run

1. Place your `sp500_data.csv` file in `/data/`.
2. Run the script from `/scripts/`
3. Review the results in `/results/` or open the HTML in `/html/`.

