# BDA400 Assignment 2 | Mireille Kamikazi
# Run from the Assignment2 folder. Requires internet access for Yahoo Finance.
# Install once: install.packages(c("quantmod", "TTR"))
required <- c("quantmod", "TTR")
missing_packages <- required[!vapply(required, requireNamespace, logical(1), quietly=TRUE)]
if (length(missing_packages)) stop("Install missing packages: ", paste(missing_packages, collapse=", "))
suppressPackageStartupMessages(library(quantmod))
suppressPackageStartupMessages(library(TTR))

read_portfolio <- function(path="portfolio.txt") {
  if (!file.exists(path)) stop("Missing portfolio file: ", path)
  symbols <- unique(toupper(trimws(readLines(path, warn=FALSE))))
  symbols <- symbols[nzchar(symbols)]
  if (!length(symbols)) stop("Portfolio file is empty")
  if (any(!grepl("^[A-Z0-9.^-]+$", symbols))) stop("Invalid ticker symbol")
  symbols
}

load_stock_data <- function(path="portfolio.txt", from=Sys.Date()-365, to=Sys.Date()) {
  symbols <- read_portfolio(path)
  result <- list()
  for (symbol in symbols) {
    tryCatch({
      xt <- quantmod::getSymbols(symbol, src="yahoo", from=from, to=to,
                                 auto.assign=FALSE, warnings=FALSE)
      if (NROW(xt)==0) stop("No observations returned")
      frame <- data.frame(Date=as.Date(zoo::index(xt)), zoo::coredata(xt),
                          check.names=FALSE)
      names(frame) <- c("Date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
      result[[symbol]] <- frame
      message(symbol, ": ", nrow(frame), " rows loaded")
    }, error=function(e) warning(symbol, ": download failed: ", conditionMessage(e)))
  }
  if (!length(result)) stop("No symbols loaded. Check connection and symbols.")
  result
}

# For continuous stock prices, exact modes are often absent or non-informative.
# This function returns NA when no observed value occurs more than once.
statistical_mode <- function(x) {
  x <- x[is.finite(x)]
  if (!length(x)) return(NA_real_)
  counts <- table(x)
  if (max(counts)==1L) return(NA_real_)
  as.numeric(names(counts)[which.max(counts)])
}

calculate_statistics <- function(stock_df, symbol, window=20L) {
  stopifnot(is.data.frame(stock_df), "Close" %in% names(stock_df))
  close <- as.numeric(stock_df$Close)
  close <- close[is.finite(close)]
  if (!length(close)) stop("No valid closing prices for ", symbol)
  ma <- TTR::SMA(close, n=window)
  data.frame(Symbol=symbol, Observations=length(close),
             Mean=mean(close), Median=median(close), Mode=statistical_mode(close),
             Std_Dev=if(length(close)>1) sd(close) else NA_real_,
             Latest_Close=tail(close,1),
             Latest_MA20=if(length(close)>=window) tail(ma,1) else NA_real_)
}

display_stock_data <- function(stock_list, preview_rows=6L) {
  for (symbol in names(stock_list)) {
    cat("\n===", symbol, "===\n")
    print(utils::head(stock_list[[symbol]], preview_rows), row.names=FALSE)
    cat("Rows:", nrow(stock_list[[symbol]]), "| Date range:",
        as.character(min(stock_list[[symbol]]$Date)), "to",
        as.character(max(stock_list[[symbol]]$Date)), "\n")
  }
}

plot_stock_data <- function(stock_list, output_dir="plots", window=20L) {
  dir.create(output_dir, recursive=TRUE, showWarnings=FALSE)
  for (symbol in names(stock_list)) {
    df <- stock_list[[symbol]]
    ma <- TTR::SMA(df$Close, n=window)
    file <- file.path(output_dir, paste0(symbol,"_closing_prices.png"))
    png(file, width=1100, height=650, res=130)
    plot(df$Date, df$Close, type="l", col="steelblue", lwd=2,
         xlab="Date", ylab="Price (USD)", main=paste(symbol,"Closing Price and 20-Day SMA"))
    lines(df$Date, ma, col="firebrick", lwd=2)
    legend("topleft", c("Close", "20-day SMA"),
           col=c("steelblue","firebrick"), lty=1, lwd=2, bty="n")
    grid()
    dev.off()
    message("Saved: ", file)
  }
}

# Execute the analysis. Yahoo Finance may change historical observations.
stocks <- load_stock_data()
display_stock_data(stocks)
summary_table <- do.call(rbind, lapply(names(stocks), function(sym)
  calculate_statistics(stocks[[sym]], sym)))
print(summary_table, row.names=FALSE)
write.csv(summary_table, "stock_statistics.csv", row.names=FALSE, na="")
plot_stock_data(stocks)
cat("\nFinished. Review stock_statistics.csv and plots/.\n")
