install.packages(c("quantmod", "TTR"), repos="https://cloud.r-project.org")
stopifnot(requireNamespace("quantmod", quietly=TRUE), requireNamespace("TTR", quietly=TRUE))
packageVersion("quantmod")
packageVersion("TTR")
