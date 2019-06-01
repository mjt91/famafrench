###############################################################################################################
## SETUP
##

# WRDS link 
# must first follow instructions for accessing WRDS using R
library(rJava); options(java.parameters = '-Xmx4g'); library(RJDBC)
user <- "username"
pass <- '{SAS002}SASencodedpassword'
wrdsconnect <- function(user=user, pass=pass){
  drv <- JDBC("com.sas.net.sharenet.ShareNetDriver", "/Users/Marius/Documents/WRDS_Drivers/sas.intrnet.javatools.jar", identifier.quote="`")
  wrds <- dbConnect(drv, "jdbc:sharenet://wrds-cloud.wharton.upenn.edu:8551/", user, pass)
  return(wrds)
}
wrds <- wrdsconnect(user=user, pass=pass)



###############################################################################################################
### LOAD COMPUSTAT FROM WRDS ###
# Downloads Compustat data from WRDS global
#

# retrieve Compustat annual fundamental data (takes 2mins)

res <- dbSendQuery(wrds,"select GVKEY, ISIN, DATADATE, FYR, FYEAR, SICH, NAICSH, FIC, EXCHG,
                   AT, LT, SEQ, CEQ, PSTK, TXDITC, TXDB, CURCD,
                   REVT, COGS, XINT, XSGA, IB, TXDI, DVC, ACT, CHE, LCT,
                   DLC, TXP, DP, PPEGT, INVT 
                   from COMPG.G_FUNDA where INDFMT='INDL' and CONSOL='C' and DATAFMT='HIST_STD' and EXCHG in (154, 212, 171, 115, 149, 257, 163)") # STD is unrestatd data
data.comp.funda.de <- dbFetch(res, n = -1) # n=-1 denotes no max but retrieve all record
# save(data.comp.funda.de, file="./data/data.comp.funda.de.RData")



###############################################################################################################
### LOAD COMPUSTAT FROM WRDS ###
# Downloads Compustat data from WRDS
#


# retrieve Compustat daily security data (takes 15mins)
# MONTHEND = 1 constraint returns only end of month data

res <- dbSendQuery(wrds, "select GVKEY, ISIN, CONM, DATADATE, CSHOC, PRCCD, AJEXDI, CURCDD, TRFD, EXCHG, CSHTRD
                   from COMPG.G_SECD where TPCI = '0' and EXCHG in (154, 212, 171, 115, 149, 257, 163) and MONTHEND = 1")
data.comp.sec.de <- dbFetch(res, n = -1) # n=-1 denotes no max but retrieve all record
# save(data.comp.sec.de, file="./data/data.comp.sec.de.RData")



###############################################################################################################
### LOAD COMPUSTAT FROM WRDS ###
# Downloads Compustat data from WRDS
#


## monthly exchange rates

res <- dbSendQuery(wrds, "select DATADATE, TOCURM, FROMCURM, EXRATM, EXRAT1M
                   from COMP.G_EXRT_MTH where TOCURM in ('USD','ILS','DEM','EUR','CNY','BEF','CHF','GBP','MXN','MYR','AUD')")
data.exch.mon <- dbFetch(res, n=-1)
# save(data.exch.mon, file="./data/data.exch.mon.RData")


## daily exchange rates

res <- dbSendQuery(wrds, "select DATADATE, TOCURD, FROMCURD, EXRATD, EXRATTPD  
                   from COMP.G_EXRT_DLY where TOCURD in ('EUR','DEM','ZAR','GBP','HUF','NLG','ATS','THB', 'USD')")
data.exch.dly <- dbFetch(res, n=-1)
# save(data.exch.dly, file="./data/data.exch.dly.RData")


###############################################################################################################
### LOAD COMPUSTAT FROM WRDS ###
# Downloads Compustat data from WRDS
#

# CDAX time series from Jul 1993

res <- dbSendQuery(wrds, "select DATADATE, GVKEYX, PRCCM
                   from COMP.G_IDX_MTH where GVKEYX = '150007'" )
data.idx.de <- fetch(res, n = -1)
# save(data.idx.de, file="./data/data.idx.de.RData")
