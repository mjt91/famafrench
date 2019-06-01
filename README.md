# Calculate Fama French Five Factors

Proposed is a framework to create the five fama french return factors for the German Stock Market. 


[Fama French Website](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html)

## Prerequisites

- Access to the [Wharton Research Data Services](https://wrds-www.wharton.upenn.edu/pages/)
- WRDS offers a [tutorial](https://wrds-web.wharton.upenn.edu/wrds/support/Accessing%20and%20Manipulating%20the%20Data/_007R%20Programming/_001Using%20R%20with%20WRDS.cfm) for accessing and manipulating their database
- **R** (at least verison 3.4.1 (2017-06-30 -- "Single Kandle")) 
    - get the newest version [here](https://www.r-project.org/)
- packages:
```r
install.packages("dplyr")
install.packages("data.table")
install.packages("maggitr")
install.packages("zoo")
install.packages("ggplot2")
install.packages("dtplyr")
install.packages("stringr")
install.packages("tidyr")
install.packages("GRS.test")
install.packages("broom")
```

## Files
- *Fama_French_Factors.R* : Main file to create FF factors and portfolios
- *Get_Data.R* : Download data from WRDS
- *support_functions.R* : helper functions


## Output

Final dataframe (all return data in percent): 
```r
Date        MyRMRF     MySMB     MyHML      MyRMW      MyCMA        RF
Jan 2017  3.6030333  4.512880 -1.5660417 -1.853988 -0.08854058 -0.03088575
Feb 2017  0.6873182  0.675079 -5.1712090  1.256181  1.97829177 -0.03088575
Mar 2017  4.4001741 -2.118636 -3.0813493  3.923298 -3.51113337 -0.03088575
Apr 2017  3.2083001  1.229573 -0.4375045 -1.114785 -2.99156972 -0.03088575
May 2017  5.7685229  9.970641 -7.2115563  1.863716 -1.11868543 -0.03088575
Jun 2017 -1.4123163  3.156754  3.7051396 -1.977690  1.81300581 -0.03088575
```


### Maintainance
Unfortunately I no longer have access to the WRDS data. As of late November 2017 the script was running without any flaws.

