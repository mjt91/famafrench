# Readme zur Masterarbeit von Marius Theiß

## Info
* **Autor: Marius Theiß** - *Matr.Nr. 140415* - [marius.theiss@udo.edu](mairus.theiss@udo.edu)

* **Abgabedatum:** - _24. November 2017_

* **Titel:** _Eine Handvoll Faktoren: Bestimmung der fünf Fama-French-Faktoren für Deutschland_

* **Lesen? (Achtung Clickbait):** [Masterarbeit.pdf](Masterarbeit_Marius_Theiß_Matr140415.pdf)


## Setup
Dieses Readme dient als Hilfe und Übersicht zu der Masterarbeit _Eine Handvoll Faktoren: Bestimmung der fünf Fama-French-Faktoren für Deutschland_. Die Programmierarbeit wurde fast vollständig in R durchgeführt. Im Folgenden werden die Voraussetzungen vorgestellt die Skripte und Datensätze auf dem eigenen Computer zu initialisieren und zu laden. Die vorliegenden Skripte bieten ein Framework zur Bestimmung der fünf Risikofaktoren für das neue Fama-French-Fünffaktorenmodell.


### Voraussetzungen
Um die korrekte Funktionsweise der Skripte zu gewährleisten wird mindestens [R version 3.4.1 (2017-06-30) -- "Single Candle"](https://www.r-project.org) vorausgesetzt. Die Verwendung von [RStudio](https://www.rstudio.com/) wird empfohlen, ist aber optional. Außerdem werden die folgenden Pakete benötigt:
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

Um die Daten von [Wharton Research Data Services](https://wrds-www.wharton.upenn.edu/pages/) per [Skript](./Projekt/scripts/DE/monthly_eur/Get_Data.R) herunterzuladen wird empfohlen dieser [Anleitung](https://wrds-web.wharton.upenn.edu/wrds/support/Accessing%20and%20Manipulating%20the%20Data/_007R%20Programming/_001Using%20R%20with%20WRDS.cfm) von WRDS zu folgen. 


### Skripte (siehe ./Projekt/scripts/)
Die folgende Liste enthält die wichtigsten Skripte der Masterarbeit. Aus Gründen der Übersichtlichkeit sind jedoch nicht alle Skripte aufgelistet. Für eine vollständige Liste sei auf `Anhang D`  in der [Masterarbeit](Masterarbeit_Marius_Theiß_Matr140415.pdf) oder den Unterordner `./Projekt/scripts/`  verwiesen.

* [Fama_French_Factors_DE_eur.R](./Projekt/scripts/DE/monthly_eur/Fama_French_Factors_DE_eur.R) 
    - Hauptprogramm zur Berechnung der Fama French Risikofaktoren für den deutschen Aktienmarkt.

* [support_functions_de_eur.R](./Projekt/scripts/DE/monthly_eur/support_functions_de_eur.R)
    - Ausgelagerte Support-Funktionen für das Hauptprogramm.

* [Get_Data.R](./Projekt/scripts/DE/monthly_eur/Get_Data.R) 
    - Funktionen um die Daten von Wharton Research Data Services abzurufen.

* [regports_4x4.R](./Projekt/scripts/DE/monthly_eur/wd/regports_4x4.R)
    - Konstruiert die 16 Regressionsportfolios anhand einer 4x4 Sortierung

* [fama_french_regressions.R](./Projekt/scripts/DE/monthly_eur/wd/fama_french_regressions.R)
    - Führt die Zeitreihenregressionen durch.

* [run_regressions_on_your_own.R](./Projekt/scripts/DE/monthly_eur/wd/run_regressions_on_your_own.R)
    - Kleines Skript unabhängig von der Masterarbeit, welches den Einsatz der berechneten Faktoren erlaubt.
    - Schön formatierte Ausgabe inklusive.

### Data files (siehe ./Projekt/data/)
Die folgende Liste enthält die wichtigsten Datensätze der Masterarbeit. Aus Gründen der Übersichtlichkeit sind jedoch nicht alle Datensätze aufgelistet. Für eine vollständige Liste sei auf den Unterordner `./Projekt/data/` verwiesen.

* [dt.MyFF5_Research_Factors.txt](./Projekt/data/dt.MyFF5_Research_Factors.txt)
    - Die fünf Fama-French-Risikofaktoren für den deutschen Markt
    - Januar 1992 bis einschließlich Juni 2017
    - Alle Werte in Prozent und gerundet auf zwei Nachkommastellen

* [4x4_ports_size_bm.txt](./Projekt/data/4x4_ports_size_bm.txt)
    - 16 Portfolios sortiert anhand Firmengröße-Buch-Martwert-Verhältnisses

* [4x4_ports_size_op.txt](./Projekt/data/4x4_ports_size_op.txt)
    - 16 Portfolios sortiert anhand Firmengröße-operative-Rentabilität

* [4x4_ports_size_inv.txt](./Projekt/data/4x4_ports_size_inv.txt)
    -  16 Portfolios sortiert anhand Firmengröße-Investment

* [dt.myFF5DE.m.RDATA](./Projekt/data/DE/monthly_eur/dt.myFF5DE.m.RDATA)
    - Finaler Datensatz erstellt durch das Skript Fama_French_Factors_DE.R.

* [dt.myFF5.RDATA](./Projekt/data/DE/monthly_eur/dt.myFF5.RDATA)
    - Obiger Datensatz zusammengestaucht auf den Zeitraum Januar 1992 bis Jul 2017. Enthält die risikolose Anleihe und den Faktor RMRF.

* [dt.myFF5.mp.RData](./Projekt/data/DE/monthly_eur/dt.myFF5.mp.RData)
    - Transformation des finalen Datensatzes in die Form von Fama and French
    - Alle Werte in Prozent und gerundet auf zwei Nachkommastellen
    - Der wohl wichtigste und elementarste Datensatz der Sammlung

* [BBK01.SU0104.csv](./Projekt/data/DE/monthly_eur/BBK01.SU0104.csv)
    - Zeitreihe des Geldmarktsatzes von Dezember 1959 bis Mai 2012.
    - Download via [Deutsche Bundesbank](http://www.bundesbank.de/Navigation/DE/Statistiken/Zeitreihen_Datenbanken/Makrooekonomische_Zeitreihen/its_details_value_node.html?tsId=BBK01.SU0104&listId=www_s11b_mb03)

* [BBK01.SU03010.csv](./Projekt/data/DE/monthly_eur/BBK01.SU03010.csv)
    - Zeitreihe des 1-Monats-Euribor von Januar 1999 bis September 2017.
    - Download via [Deutsche Bundesbank](https://www.bundesbank.de/Navigation/DE/Statistiken/Zeitreihen_Datenbanken/Makrooekonomische_Zeitreihen/its_details_value_node.html?tsId=BBK01.SU0310)

* [BBK01.WU001A.csv](./Projekt/data/DE/monthly_eur/BBK01.WU001A.csv)
    - Zeitreihe des CDAX Kursindex von Juni 1994 bis September 2017.
    - Download via [Deutsche Bundesbank](https://www.bundesbank.de/Navigation/DE/Statistiken/Zeitreihen_Datenbanken/Makrooekonomische_Zeitreihen/its_details_properties_node.html?https=1&tsId=BBK01.WU001A)



## Auszug und zentrale Ergebnisse

### Abstract
Die vorliegende Arbeit untersucht, in wie weit sich die Fama-French-Risikofaktoren des neuen Fünffaktorenmodells aus der renommierten Compustat Global Datenbank für den deutschen Aktienmarkt konstruieren lassen. Es wird ein Framework samt Filterverfahren für die Compustat Datenbank vorgestellt, mit dem sich die Risikofaktoren für das Fama-French-Fünffaktorenmodell konstruieren lassen. Die Datenbank erlaubt einen Gesamtuntersuchungszeitraum von Januar 1992 bis einschließlich Juni 2017. Im weiteren Verlauf der Arbeit wurden, analog zu den Risikofaktoren, die Regressionsportfolios konstruiert. Im Anschluss wurde getestet, wie gut das Fama-French-Fünffaktorenmodell im Test gegen das CAPM und das Fama-French-Dreifaktorenmodell die Überschussrenditen des deutschen Aktienmarktes erklären kann. Die zentralen Ergebnisse dieser Arbeit sind wie folgt. Erstens findet sich für den Datensatz eine insignifikante positive Marktrisikoprämie, eine signifikante negative Größenprämie (Size Premium), eine signifikante positive Substanzprämie (Value Premium), einen insignifikanten positiven Rentabilitätsfaktor und einen insignifikanten positiven Investmentfaktor. Zweitens sind die Faktoren allesamt negativ mit der Marktrisikoprämie korreliert. Untereinander sind die Faktoren nur schwach oder leicht positiv korreliert. Die Korrelation mit den internationalen Gegenstücken ist kaum bis verschwindend gering ausgeprägt. Daraus wird geschlussfolgert, dass die Risikofaktoren länderspezifisch sind. Drittens zeigen sich alle Modelle in der Regressionsanalyse in der Lage die Renditen der Portfolios sortiert nach Firmengröße und Buch-Marktwert-Verhältnis und die Renditen der Portfolios sortiert nach Firmengröße und operativer Rentabilität hinreichend gut zu erklären. Die Auswertung der Regressions-Alphas und GRS Statistiken zeigt allerdings, dass das CAPM und das Dreifaktorenmodell erhebliche Schwierigkeiten haben die Renditen der Portfolios sortiert nach Firmengröße und Investment zu erklären. Nur das Fama-French-Fünffaktorenmodell weist hier keine signifikante GRS Statistik auf. Eine detaillierte Analyse aller Regressionen ergibt, dass das Fünffaktorenmodell das CAPM und das Dreifaktorenmodell in jeder Statistik bezüglich der Modellperformance dominiert. Vor dem Hintergrund der gefundenen Ergebnisse und der angrenzenden Literatur von Fama and French (2015, 2017) argumentiert diese Arbeit daher für die länderspezifische Erweiterung des Dreifaktorenmodells auf das Fünffaktorenmodell für den deutschen Aktienmarkt.

### Risikoprämien der letzten 6 Monate (in %)
Auszug aus dem Datasatz der berechneten Risikofaktoren **dt.myFF5.mp.RData**

```r
Date        MyRMRF     MySMB     MyHML      MyRMW      MyCMA        RF
Jan 2017  3.6030333  4.512880 -1.5660417 -1.853988 -0.08854058 -0.03088575
Feb 2017  0.6873182  0.675079 -5.1712090  1.256181  1.97829177 -0.03088575
Mar 2017  4.4001741 -2.118636 -3.0813493  3.923298 -3.51113337 -0.03088575
Apr 2017  3.2083001  1.229573 -0.4375045 -1.114785 -2.99156972 -0.03088575
May 2017  5.7685229  9.970641 -7.2115563  1.863716 -1.11868543 -0.03088575
Jun 2017 -1.4123163  3.156754  3.7051396 -1.977690  1.81300581 -0.03088575
```


### Kumulierte Summe der berechneten Risikofaktoren
![Fama French Faktoren](./Projekt/figures/cumulative_factor_returns_0.png)

### Korrelation des Marktportfolios mit dem CDAX (Jun 1994 - Jun 2017)
![Korrelation MyRM vs CDAX](./Projekt/figures/MyRM_vs_CDAX.png)

