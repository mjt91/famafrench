###############################################################################################################
### Used in Fama_French_Factors.R ####
### Support functions Marius

coalesce<-function(...) {
  # Based on SAS coalesce and selects first available non-NA number in vector
  # Eg: BE <- coalesce(seq, ceq + pstk, at - lt)
  
  Reduce(function(x,y) {
    i<-which(is.na(x))
    x[i] <- if(length(y)==1) {y} else{y[i]} # modified to take care of constants
    x
  },
  list(...))
}


# When working with time series data using base R na.locf function is not advised
na_locf_until = function(x, n) {
  # in time series data, fill in na's untill indicated n
  l <- cumsum(! is.na(x))
  c(NA, x[! is.na(x)])[replace(l, ave(l, l, FUN=seq_along) > (n+1), 0) + 1]
}


# Winsorize function
# To avoid outliers the bottom (top) 1% values are set equal to the value corresponding
# to the 1st (99th) percentile of the empirical distribution
winsorize <- function(x, q=0.01) { 
  extrema <- quantile(x, c(q, 1-q), na.rm = TRUE)	
  x[x<extrema[1]] <- extrema[1] 
  x[x>extrema[2]] <- extrema[2] 
  x 
} 


## function to convert time series to USD
convertXtoUSD <- function(main, exch.data) {
  
  GBPtoUSD <- exch.data %>% filter(tocurm == "USD") %>%
    select(datadate, exratm)
  
  data.cln <- exch.data %>% filter(tocurm == main[["curcd"]]) %>%
    mutate(XtoGBP = exratm ^-1) %>%
    select(datadate, XtoGBP)
  
  convertDf <- data.cln %>%
    merge(GBPtoUSD, by = "datadate", all.x = TRUE) %>%
    mutate(XtoUSD = XtoGBP * exratm) %>%
    select(datadate, XtoUSD)
  
  output <- merge(main, convertDf, by = "datadate", all.x = TRUE) %>%
    select(-curcd, -gvkey) # must remove and sort later
  
  return(output)
  
}

## function to convert time series to EUR
convertXtoEUR <- function(main, exch.data) {
  
  GBPtoUSD <- exch.data %>% filter(tocurm == "EUR") %>%
    select(datadate, exratm)
  
  data.cln <- exch.data %>% filter(tocurm == main[["curcd"]]) %>%
    mutate(XtoGBP = exratm ^-1) %>%
    select(datadate, XtoGBP)
  
  convertDf <- data.cln %>%
    merge(GBPtoUSD, by = "datadate", all.x = TRUE) %>%
    mutate(XtoEUR = XtoGBP * exratm) %>%
    select(datadate, XtoEUR)
  
  output <- merge(main, convertDf, by = "datadate", all.x = TRUE) %>%
    select(-curcd, -gvkey) # must remove and sort later
  
  return(output)
  
}


Form_CharSizePorts2 <- function(main, size, var, wght, ret) {
  # forms 2x3 (size x specificed-characteristc) and forms the 6 portfolios 
  # variable broken by 30-70 percentiles, size broken up at 50 percentile
  # requires Date and EXCHCD 
  # outputs portfolio returns for each period,
  
  main.cln <- main %>%
    select(Date, gvkey, paste(size), paste(var), paste(wght), 
           paste(ret)) %>% data.table
  
  Bkpts.NYSE <- main.cln %>% # create size and var breakpoints based on NYSE stocks only
    # filter(exchg == 11) %>% # NYSE exchange
    group_by(Date) %>%
    summarize(var.P70 = quantile(.[[var]], probs=.7, na.rm=TRUE), 
              var.P30 = quantile(.[[var]], probs=.3, na.rm=TRUE),
              size.Med = quantile(.[[size]], probs=.5, na.rm=TRUE))
  
  # calculate size and var portfolio returns
  main.rank <- main.cln %>%
    merge(Bkpts.NYSE, by="Date", all.x=TRUE) %>%
    mutate(Size = ifelse(.[[size]]<size.Med, "Small", "Big"),
           Var = ifelse(.[[var]]<var.P30, "Low", ifelse(.[[var]]>var.P70, "High", "Neutral")),
           Port = paste(Size, Var, sep="."))
  
  Ret <- main.rank %>% # name 2 x 3 size-var portfolios
    group_by(Date, Port) %>%
    summarize(ret.port = weighted.mean(.[[ret]], .[[wght]], na.rm=TRUE)) %>% # calc value-weighted returns
    spread(Port, ret.port) %>% # transpose portfolios expressed as rows into seperate columns
    mutate(Small = (Small.High + Small.Neutral + Small.Low)/3,
           Big = (Big.High + Big.Neutral + Big.Low)/3,
           SMB = Small - Big,
           High = (Small.High + Big.High)/2,
           Low = (Small.Low + Big.Low)/2,
           HML = High - Low)
  
  return(Ret)
}
