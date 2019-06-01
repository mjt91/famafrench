###############################################################################################################
### REPLICATE FAMA-FRENCH 5-FACTOR MODEL ####
#
# Last Update: September 2017
# Based on methodology described on Ken French website and relevant Fama-French papers
#


###############################################################################################################
## LOAD LIBS
##

library(magrittr); library(dplyr); library(data.table)
library(dtplyr); library(tidyr); library(zoo)
library(stringr);

## LOAD Support functions
source(file="support_functions.R")

# correct time settings for yearmon to work properly (only necessary if your system default fucks with yearmon)
# Sys.setlocale("LC_TIME", "English")

###############################################################################################################
## STEP 1:
## 
## data manipulation on fundamental data obtained from wrds
##

# load monthly fundamental data from local
load(file = "./data/data.comp.funda.de.RData") # fundamental company data
load(file = "./data/data.exch.mon.RData") # exchange rate data


# Cleaning stage 1 (fix variable types and dates)
# using factors and handling datadate as Date makes wrangling and filtering much easier
data.comp.funda <- data.comp.funda.de %>%
  mutate(datadate = as.Date(datadate),
         gvkey = as.factor(gvkey))

data.exch <- data.exch.mon %>% 
  mutate(datadate = as.Date(datadate)) %>%
  data.table
rm(data.comp.funda.de, data.exch.mon)


# Cleaning stage 2 (add fx rates for dates)
# convertXtoUSD loops through all currencies and adds a column with 
# the corresponding fx rate
# has WARNINGS but can ignore
data.ccm <- data.comp.funda %>%
  group_by(gvkey, curcd) %>%
  do(convertXtoEUR(., data.exch)) %>%
  ungroup %>%
  select(datadate, gvkey, isin, curcd, fic, fyr:XtoEUR) %>%
  data.table # need to add comp.count in next step
# save(data.ccm, file="./data/data.ccm.RData")
rm(data.comp.funda, data.exch)


# Cleaning stage 3 (date conversation and kill dublicate observations)
# Convert date to yearmon format ot match Fama French style
# distinct by date and gvkey identifier to kill dublicate observations (i.e. data errors in compustat)
data.comp <- data.ccm %>%
  group_by(gvkey) %>%
  mutate(datadate = as.yearmon(datadate),
         comp.count = row(.)) %>% # allows option to cut first year data; has WARNINGS but can ignore
  arrange(datadate, gvkey) %>%
  distinct(datadate, gvkey, .keep_all = TRUE) # hasn't been issue but just in case
# save(data.comp, file="./data/data.comp.RData")
rm(data.ccm)


# Cleaning stage 4 (convert each variable to be in USD numerical)
# Multiplicate every variable with USD fx rate
# Need all data in the common currency USD to apply Fama French methodology properly
data.comp.cur <- data.comp %>%
  group_by(gvkey) %>%
  as_tibble %>% # have to use tbl format since data.table is still not able to mutate_each w/o errors (as of Sept. 2017)
  mutate_at(vars(at:invt), funs(.* XtoEUR)) %>%
  ungroup %>%
  arrange(datadate, gvkey)
# save(data.comp.cur, file="./data/data.comp.cur.RData")
rm(data.comp)


# Cleaning stage 5 (remove first year errors)
# Some Firms had horendous first year data errors. Those where selected and deleted manually
# Create vector with corresponding gvkeys and find first occurence in fundamental data and rm
del1 <- read.table(file="./data/del1.txt", sep="\n", header=TRUE)
del2 <- read.table(file="./data/del2.txt", sep="\n", header=TRUE)

firstYearErrors <- match(del1$gvkey, data.comp.cur$gvkey) # returns row indices
data.comp.cur.clean <- data.comp.cur %>%
  slice(-firstYearErrors) %>%
  filter(!gvkey %in% del2$gvkey) %>%
  arrange(datadate, gvkey)
# save(data.comp.cur.clean, file="./data/data.comp.cur.clean.RData")
rm(data.comp.cur, del1, del2, firstYearErrors)


# Cleaning stage 6 (variable calculations)
# compute book equity (BE) and all other variables needed
data.comp.a <- data.comp.cur.clean %>%
  group_by(gvkey) %>%
  mutate(BE = coalesce(seq, ceq + pstk , at - lt) + coalesce(txditc, txdb, 0) - 
           coalesce(pstk, 0), # consistent w/ French website variable definitions
         OpProf = (revt - coalesce(cogs, 0) - coalesce(xint, 0) - coalesce(xsga,0)),
         OpProf = as.numeric(ifelse(is.na(cogs) & is.na(xint) & is.na(xsga), NA, OpProf)), # FF condition
         GrProf = (revt - cogs),
         Cflow = ib + coalesce(txdi, 0) + dp,  # operating; consistent w/ French website variable definitions
         Inv = (coalesce(ppegt - lag(ppegt), 0) + coalesce(invt - lag(invt), 0)) / lag(at), # Inventories (no need here)
         AstChg = (at - lag(at)) / lag(at), # note that lags use previously available (may be different from 1 yr)
         InvestChg = (lag(at) - at) / lag(at) # change of sign for better factor construction (Conservative vs Aggressive)
  ) %>%
  arrange(datadate, gvkey) %>%
  select(datadate, gvkey, comp.count, sich, naicsh, at, revt, ib, dvc, BE:InvestChg) %>%
  as_tibble %>% # thanks to a bug in dplyr mutate_at & mutate_each are not working as intended for data.table class
  mutate_at(vars(at:InvestChg), funs(as.numeric(ifelse(!is.infinite(.), ., NA)))) %>% # convert inf to NAs
  mutate_at(vars(at:InvestChg), funs(round(., 5))) %>% # round to 5 decimals (normalize weird zero entries in compustat)
  data.table
# save(data.comp.a, file="./data/data.comp.a.RData")
rm(data.comp.cur.clean)



###############################################################################################################
## STEP 2:
##
##


# load daily scurity data and daily fx rates from local
load(file="./data/data.comp.sec.de.RData")
load(file="./data/data.exch.dly.RData")


# Vars definitions and fix date
# using factors and handling datadate as Date makes wrangling and filtering much easier
data.comp.sec <- data.comp.sec.de %>%
  # filter(curcdd %in% c("DEM", "EUR") & exchg %in% c(154, 171)) %>% # filter missing currency info (only companies listed in DEM or EUR)
  filter(exchg %in% c(154, 171)) %>% # filter missing currency info (only companies listed in DEM or EUR)
  mutate(gvkey = as.factor(gvkey),
         datadate = as.Date(datadate)) %>%
  rename(curcd = curcdd) # rename currency variable to be consistent with fundamental data

# rename variables in fx rates data to be consistent with monthly data
# needed to work properly with convertCurrency helper function
data.exch <- data.exch.dly %>%
  mutate(datadate = as.Date(datadate)) %>%
  rename(tocurm = tocurd, fromcurm = fromcurd, exratm = exratd)


# Filter and clean security data stage 1 (takes about 7-10 mins)
# Data from compustat is already filtered for german 
# exchanges only (see exchg.xlsx in data/DE/monthly/ for infos)
# arrange data by date and remove dublicate dates (no DATAFMT = STD in G_SECD)
# use convertXtoUSD function from support_functions file
# has WARNINGS but can ignore
data.sec.d <- data.comp.sec %>%
  # filter(exchg %in% exchg_eval) %>%
  group_by(gvkey) %>%
  arrange(datadate, gvkey) %>%
  distinct(datadate, gvkey, .keep_all=TRUE) %>% # just in case
  group_by(gvkey, curcd) %>%
  do(convertXtoEUR(., data.exch)) %>%
  do(convertXtoUSD(., data.exch)) %>% # for correct return calc
  ungroup %>%
  select(datadate, gvkey, isin, conm, curcd, cshoc:XtoUSD) %>%
  arrange(datadate, gvkey)
# save(data.sec.d, file="./data/data.sec.d.RData")
rm(data.comp.sec, data.comp.sec.de, data.exch, data.exch.dly)


# Filter and clean stage 2 
# Calculate prccd in EUR and drop all unecessary variables
# Compute adjusted return using price in USD (DEM to EUR change results in huge errors otherwise)
# No need to adjust shares outstanding (cshoc) since prrcd need to be adjusted by ajexdi aswell and cancels out
# See Compustat Online Manuel Chapter 6 (p. 99) for infos
data.sec.m <- data.sec.d %>%
  # filter(monthend == 1) %>% # strip down to monthly data using compustat end of month indicator
  group_by(gvkey) %>%
  mutate(prccm = prccd * XtoEUR, # price in EUR
         # prccm = prccd * XtoUSD / ajexdi, # monthly price adjusted in USD
         retadj.1mn = (((prccd * XtoUSD) / ajexdi) * trfd / lag(((prccd * XtoUSD) / ajexdi) * trfd))-1, # return adjusted 
         # cshom = cshoc * ajexdi * 1E-6) %>%
         cshom = cshoc * 1E-6) %>% # adjust shares outstanding (cshoc is real number, adjust by 1E-6)
  ungroup %>%
  select(datadate, gvkey, isin, conm, prccm, cshom, exchg, ajexdi, retadj.1mn) %>%
  arrange(datadate, gvkey)
# save(data.sec.m, file="./data/data.sec.m.RData")
rm(data.sec.d)

# Filter and clean security data stage 3 
# Calculate ME
# Use abs in mutate for negative pricing errors in compustat (just in case)
data.ccme <- data.sec.m %>%
  group_by(gvkey) %>%
  fill(cshom) %>% # fill missing shares (na.locf) (data.frame preferred)
  mutate(meq = cshom * abs(prccm)) %>% # prccm is in EUR
  group_by(datadate, gvkey) %>%
  # mutate(ME = sum(meq)) %>% # sum to group ticker (maybe change later?)
  mutate(ME = meq) %>% # sum to group ticker (maybe change later?)
  ungroup
# save(data.ccme, file="./data/data.ccme.RData")
rm(data.sec.m)

# Filter and clean stage 4
# Finally create data with correct port.weight
data.cln <- data.ccme %>%
  select(datadate, gvkey, isin, conm, prccm, cshom, retadj.1mn, ajexdi, ME) %>%
  group_by(gvkey) %>%
  mutate(port.weight = as.numeric(ifelse(!is.na(lag(ME)), lag(ME), ME/(1+retadj.1mn))),
         port.weight = ifelse(is.na(retadj.1mn) & is.na(prccm), NA, port.weight)) %>%
  ungroup %>%
  arrange(datadate, gvkey)
# save(data.cln, file="./data/data.cln.RData")
rm(data.ccme)


###############################################################################################################
## STEP 3:
## Merge price and fundamental data
##

# load adjusted fundamental data (step 1) and monthly security data (step 2) from local
load(file="./data/data.comp.a.RData")
load(file="./data/data.cln.RData")

data.sec.clc <- data.cln %>%
  mutate(datadate = as.yearmon(datadate)) %>%
  rename(Date = datadate) %>%
  group_by(Date, gvkey) %>%
  ungroup %>%
  as_tibble # need tbl due to filter bug in dplyr when using (faster) data.table

data.comp.a <- data.comp.a %>%
  group_by(datadate, gvkey) %>%
  ungroup %>%
  as_tibble # need tbl due to filter bug in dplyr when using (faster) data.table

# Merge data by date and gvkey while keeping all price data stage 2
data.both.m <- data.comp.a %>%
  mutate(Date = datadate + (18-month(datadate))/12) %>% # map to next year June period when data is known (must occur in previous year)
  merge(data.sec.clc, ., by=c("Date", "gvkey"), all.x=TRUE, allow.cartesian=TRUE) %>% # keep all price records from Compustat monthly security
  arrange(gvkey, Date, desc(datadate)) %>%
  distinct(gvkey, Date, .keep_all = TRUE) %>% # drop older datadates (must sort by desc(datadate))
  group_by(gvkey) %>%
  mutate_at(vars(datadate:InvestChg), funs(na_locf_until(., 11))) %>%
  ungroup %>% 
  mutate(datadate = yearmon(datadate)) %>%
  arrange(Date, gvkey)
# save(data.both.m, file="./data/data.both.m.RData")
rm(data.comp.a, data.sec.clc, data.cln)


###############################################################################################################
## STEP 4:
## Adding Fama French Variables
##

# Fama French Variables stage 1: Calculating (takes 5-10min)
data.both.FF.m <- data.both.m %>%
  group_by(gvkey) %>%
  mutate(d.shares = cshom/lag(cshom)-1, # change in monthly share count (adjusted for splits)
         # d.shares.adj = (cshom * ajexdi)/lag(cshom * ajexdi)-1, # change in monthly share count (adjusted for splits)
         ret.12t2 = (lag(retadj.1mn,1)+1)*(lag(retadj.1mn,2)+1)*(lag(retadj.1mn,3)+1)*(lag(retadj.1mn,4)+1)*
           (lag(retadj.1mn,5)+1)*(lag(retadj.1mn,6)+1)*(lag(retadj.1mn,7)+1)*(lag(retadj.1mn,8)+1)*
           (lag(retadj.1mn,9)+1)*(lag(retadj.1mn,10)+1)*(lag(retadj.1mn,11)+1)-1, # to calc momentum spread
         BE = BE, # data available by end-of-Jun based on Compustat Date mapping 
         ME.Dec = as.numeric(ifelse(month(Date)==6 & lag(ME,6)>0, lag(ME,6), NA)), # previous Dec ME 
         ME.Jun = as.numeric(ifelse(month(Date)==6, ME, NA)), # previous Jun ME
         BM.FF = as.numeric(ifelse(month(Date)==6 & ME.Dec>0, BE/ME.Dec, NA)), 
         OpIB = as.numeric(ifelse(month(Date)==6 & BE>0, OpProf/BE, NA)), 
         GrIA = as.numeric(ifelse(month(Date)==6 & at>0, GrProf/at, NA)),
         CFP.FF = as.numeric(ifelse(month(Date)==6 & ME.Dec>0, Cflow/ME.Dec, NA)),
         Inv.FF = as.numeric(ifelse(month(Date)==6 & InvestChg>0, InvestChg, NA)), # check if ME.Dec > 0 instead of InvestChg > 0 or even BE.Dec > 0
         BM.m = BE/ME, # monthly updated version for spread calc
         CFP.m = Cflow/ME, # monthly updated version for spread calc
         lag.ME.Jun = lag(ME.Jun), # monthly data so only lag by 1 mn
         lag.BM.FF = lag(BM.FF),
         lag.OpIB = lag(OpIB),
         lag.AstChg = lag(AstChg),
         lag.InvestChg = lag(InvestChg))

# Fama French Variables stage 2: filling NAs and fixing inf values and NA port.weights
data.both.FF.m <- data.both.FF.m %>%
  mutate_at(vars(d.shares:lag.InvestChg), funs(ifelse(!is.infinite(.), ., NA))) %>%
  select(Date, datadate, gvkey, sich, naicsh, comp.count, prccm, retadj.1mn, d.shares, ME, port.weight,
         ret.12t2, at:AstChg, ME.Dec:lag.InvestChg) %>%
  arrange(Date, gvkey) %>%
  group_by(gvkey) %>%
  mutate_at(vars(ME.Jun:lag.InvestChg), funs(na_locf_until(., 11))) %>%
  ungroup %>%
  mutate(port.weight = ifelse(is.na(port.weight), 0, port.weight))
# save(data.both.FF.m, file="./data/data.both.FF.m.RData")
rm(data.both.m)


###############################################################################################################
## STEP 5:
## Filter merged data for correct scientific analysis
##

load(file="./data/data.both.FF.m.RData")

# Next step is to clean merged data and remove compustat data errors
# e.g. kill 'RSE Grundbesitz und Beteiligungs-AG Aktie' with horrendous data error (2800 per cent return)
# Create kill list and filter data respectivly
# Also filter sic and nasich codes using stringr package and regex on sic codes starting with 60-67 and
# naicsh codes starting with 52 or 53 to remove financials (banks, insurers, etc.) (See FF1993, p. 429)
# Last winsorize all financial ratios setting the bottom (top) 1% values to the values corresponding to
# the 1st (99th) percentile of the empirical distribution using winsorize function from support_functions file


# Load compustat fundamentals from local
load(file = "data/DE/monthly_eur/data.comp.funda.de.RData")

# Update sich and naicsh codes (using na.locf but from last)
data.comp.funda.de <- data.comp.funda.de %>%
  mutate(sich = na.locf(sich, fromLast = TRUE),
         naicsh = na.locf(naicsh, fromLast = TRUE))

# Filter financial firm gvkeys via sich and naicsh codes using regex and stringr
financial_firms <- data.comp.funda.de %>% 
  filter(str_detect(sich, '^(6)[01234567]') | str_detect(naicsh, '^(52)|^(53)')) %>%
  select(gvkey) %>% unique

# Kill list (huge data errors in compustat)
kill_gvkeys <- c("100679", "220314", "132538",
                 "256228", "238460", "273545",
                 "279220", "282175")
                 
# Create vector with gvkeys for analysis
filtered_gvkeys <- data.comp.funda.de %>%
  filter(exchg == 154 | exchg == 171) %>%  # 1057 (Stufe 1)
  filter(!gvkey %in% financial_firms$gvkey) %>% # 1026 (Stufe 2)
  filter(curcd %in% c("DEM", "EUR", "USD")) %>% # 1014 (Stufe 3)
  filter(!gvkey %in% kill_gvkeys) %>% # 1011 (Stufe 4)
  select(gvkey) %>% unique

# Create cleaned FF data
data.both.FF.cln <- data.both.FF.m %>%
  filter(gvkey %in% filtered_gvkeys$gvkey) %>%
  # group_by(gvkey) %>% # this is wrong
  mutate_at(vars(BM.FF:lag.InvestChg), funs(winsorize(., q = 0.01))) %>% # correct
  ungroup %>%
  arrange(Date, gvkey)
# save(data.both.FF.cln, file="./data/data.both.FF.cln.RData")
rm(kill_gvkeys, financial_firms,filtered_gvkeys, data.both.FF.m, data.comp.funda.de)



###############################################################################################################
## STEP 6:
## Construct Fama-French 5 Factors
##


# Form Factors via function call
Form_FF5Ports <- function(dt) {
  dt.cln <- dt %>%
    group_by(gvkey)
  
  output <- dt.cln %>%
    group_by(Date) %>%
    summarize(MyMkt = weighted.mean(retadj.1mn, w=port.weight, na.rm=TRUE)) %>%
    merge(Form_CharSizePorts2(dt.cln, "lag.ME.Jun", "lag.BM.FF", "port.weight", "retadj.1mn"),
          by = "Date", all.x = TRUE) %>% # SMB.BM, HML
    transmute(Date, MyMkt, MySMB.BM=SMB, MySMBS.BM=Small, MySMBB.BM=Big, MyHML=HML, MyHMLH=High, MyHMLL=Low) %>%
    merge(Form_CharSizePorts2(dt.cln, "lag.ME.Jun", "lag.OpIB", "port.weight", "retadj.1mn"),
          by = "Date", all.x = TRUE) %>% # SMB.OP, RMW
    transmute(Date, MyMkt, MySMB.BM, MySMBS.BM, MySMBB.BM, MyHML, MyHMLH, MyHMLL,
              MySMB.OP=SMB, MySMBS.OP=Small, MySMBB.OP=Big, MyRMW=HML, MyRMWH=High, MyRMWL=Low) %>%
    merge(Form_CharSizePorts2(dt.cln, "lag.ME.Jun", "lag.InvestChg", "port.weight", "retadj.1mn"),
          by = "Date", all.x = TRUE) %>% # SMB.INV, CMA
    transmute(Date, MyMkt, MySMB.BM, MySMBS.BM, MySMBB.BM, MyHML, MyHMLH, MyHMLL, MySMB.OP, MySMBS.OP,
              MySMBB.OP, MyRMW, MyRMWH, MyRMWL, MySMB.INV=SMB, MySMBS.INV=Small, MySMBB.INV=Big,
              MyCMA=HML, MyCMAH=High, MyCMAL=Low) %>%
    mutate(MySMB = (MySMB.BM + MySMB.OP + MySMB.INV) / 3) %>%
    select(Date, MyMkt, MySMB, MySMB.BM:MyCMAL)
  
  return(output)
}


# Create my FamaFrench Data
dt.myFF5DE.m <- Form_FF5Ports(data.both.FF.cln)
# save(dt.myFF5DE.m, file="./data/dt.myFF5DE.m.RData")

