# BDA400 Assignment 2 — Technical Analysis using R (Preliminary Stage)

Student: Mireille Kamikazi | Course: BDA400

## Setup
1. Install R and RStudio. Open RStudio.
2. Create a GitHub repository named `TechnicalAnalysis`; place this folder inside it.
3. Open this folder as the working directory in RStudio.
4. Run `source("install_packages.R")` once while connected to the internet.
5. Edit `portfolio.txt` if desired; one Yahoo Finance ticker per line.
6. Run `source("technical_analysis.R")`.
7. Inspect `stock_statistics.csv`, the `plots/` directory, and the console output.
8. Add genuine screenshots to the Word report and upload the files to GitHub.

## Methods
For each ticker, Yahoo Finance OHLCV data are downloaded using `quantmod`. Closing-price mean, median, sample standard deviation, empirical mode (NA if no repeated value), and 20-day simple moving average are computed. The last available moving average and closing price are reported. Charts show close and 20-day SMA.

## Limitations
Live data require internet access and Yahoo Finance availability. Historical prices may be revised; values change with dates. Prices are descriptive, not trading advice. The mode of continuous prices is often undefined by the chosen frequency convention.
