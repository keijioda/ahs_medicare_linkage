AHS-2 Medicare Linkage
================

## Datasets

-   Data received from CMS on October 31, 2022
-   Contains 4 self-decrypting EXE files for each year of 2008-2020
    -   Master Beneficiary Summary File (MBSFABCD)
    -   Chronic Conditions (MBSFCC)
    -   Cost and Utilization (MBSFCU)
    -   MEDPAR (MEDP)
-   For 2017 and later, we have:
    -   An additional file for a new set of 30 chronic conditions
        (MBSFCHRONIC)
-   Also includes a crosswalk file between SSN and BeneID

## Crosswalk

### SSN matches

-   The crosswalk file contains 70968 SSNs (`ORIG_SSN`).
-   There are 3 matching indicators:
    -   `SSN_MATCH` for SSN-to-BeneID match
    -   and whenever there is a match, we also have `SEX_MATCH`, and
        `DOB_MATCH`
-   Among 70,968 subjects, there were 52,704 matches (74%):
    -   There were 115 invalid SSNs (`SSN_MATCH = 9`)

<!-- -->

    ## # A tibble: 3 × 3
    ##   SSN_MATCH     n    pct
    ##       <dbl> <int>  <dbl>
    ## 1         0 18149 25.6  
    ## 2         1 52704 74.3  
    ## 3         9   115  0.162

-   Among 52,704 matches, there were 824 subjects (1.6%) whose gender
    mismatched with AHS-2 data
    -   How should we deal with these gender mismatches?

<!-- -->

    ## # A tibble: 2 × 3
    ##   SEX_MATCH     n   pct
    ##       <dbl> <int> <dbl>
    ## 1         0   824  1.56
    ## 2         1 51880 98.4

-   Among 52,704 matches, there were 3331 subjects (6.3%) whose DOB
    mismatched with AHS-2 data
    -   How should we deal with these DOB mismatches?

<!-- -->

    ## # A tibble: 2 × 3
    ##   DOB_MATCH     n   pct
    ##       <dbl> <int> <dbl>
    ## 1         0  3331  6.32
    ## 2         1 49373 93.7

### Anomalies

-   There were two BeneIDs that appeared twice in the crosswalk file.
    -   Each of these BeneIDs have two different SSNs (below shows only
        the last 4 digits of SSN)

<!-- -->

    ## # A tibble: 4 × 5
    ##   SSN_hidden BENE_ID         SSN_MATCH SEX_MATCH DOB_MATCH
    ##   <chr>      <chr>               <dbl>     <dbl>     <dbl>
    ## 1 5500       2222222jxjxjTHH         1         1         1
    ## 2 9017       2222222jxjxjTHH         1         0         0
    ## 3 9228       2222222T1T1y1Jf         1         1         1
    ## 4 3893       2222222T1T1y1Jf         1         0         0

-   There were 106 SSNs that appeared twice in the crosswalk file – see
    the firse several examples below
    -   Each of these SSNs have two different BeneIDs (below shows only
        the last 4 digits of SSN)

<!-- -->

    ## # A tibble: 212 × 5
    ##    SSN_hidden BENE_ID         SSN_MATCH SEX_MATCH DOB_MATCH
    ##    <chr>      <chr>               <dbl>     <dbl>     <dbl>
    ##  1 4697       2222222H1yyJxTJ         1         1         1
    ##  2 4697       222222jygfg2J2H         1         1         1
    ##  3 8398       222222J1jyyJxx1         1         1         1
    ##  4 8398       222222yfxHyTxTx         1         1         1
    ##  5 4196       222222JTf212ff2         1         1         1
    ##  6 4196       222222Jj2yTgj2j         1         1         1
    ##  7 2671       222222221yTTxJ2         1         1         1
    ##  8 2671       2222222g2gTyx2y         1         1         1
    ##  9 0132       22222222THxggHH         1         1         1
    ## 10 0132       2222222HgTJJJxj         1         1         1
    ## # … with 202 more rows

-   For now, these BeneIDs were excluded (n = 212) for analysis below

## Master Beneficiary Summary (MBSF) File

-   All MBSF files of 2008-2020 were imported into R. After excluding
    duplicated cases described above, the number of observations each
    year is:

<!-- -->

    ##  2008  2009  2010  2011  2012  2013  2014  2015  2016  2017  2018  2019  2020 
    ## 29222 29903 30473 31206 31876 32477 32959 33373 33784 34119 34293 34396 34481

-   After combining all years of data, we have 47,292 unique BeneIDs in
    these 13 years.
    -   This indicates that there are 5198 matched beneficiaries that do
        not appear in the MSBF files.

### Age, gender and deaths

-   See the distribution of age at last seen. Notice the beneficiaries
    of aged \<60 years.

<!-- -->

    ## # A tibble: 10 × 3
    ##    AgeCat        n      pct
    ##    <fct>     <int>    <dbl>
    ##  1 [0,30)        2  0.00423
    ##  2 [30,40)      10  0.0211 
    ##  3 [40,50)     101  0.214  
    ##  4 [50,60)     739  1.56   
    ##  5 [60,70)    8998 19.0    
    ##  6 [70,80)   16312 34.5    
    ##  7 [80,90)   13956 29.5    
    ##  8 [90,100)   6775 14.3    
    ##  9 [100,110)   397  0.839  
    ## 10 [110,120)     2  0.00423

-   Current reason for Medicare entitlement (at last seen) indicates
    that 3.6% of all beneficiaries are because of disability and/or
    end-stage renal disease:

<!-- -->

    ## # A tibble: 4 × 3
    ##   ENTLMT_RSN_CURR     n     pct
    ##   <fct>           <int>   <dbl>
    ## 1 OASI            45608 96.4   
    ## 2 DIB              1608  3.40  
    ## 3 ESRD               42  0.0888
    ## 4 DIB & ESRD         34  0.0719

-   See the distribution of sex according to the year last seen:

<!-- -->

    ## # A tibble: 2 × 3
    ##   SEX_IDENT_CD     n   pct
    ##          <dbl> <int> <dbl>
    ## 1            1 17109  36.2
    ## 2            2 30183  63.8

-   How many of them died during 2008-2020? There were 14,222 (30.1%)
    deaths during the 13 years:

<!-- -->

    ## # A tibble: 2 × 3
    ##   Dead      n   pct
    ##   <fct> <int> <dbl>
    ## 1 Alive 33070  69.9
    ## 2 Dead  14222  30.1

-   See the distribution of deaths by years:

<!-- -->

    ## # A tibble: 14 × 3
    ##    year_died     n   pct
    ##    <chr>     <int> <dbl>
    ##  1 2008        754  1.59
    ##  2 2009        811  1.71
    ##  3 2010        839  1.77
    ##  4 2011        971  2.05
    ##  5 2012        962  2.03
    ##  6 2013       1061  2.24
    ##  7 2014       1068  2.26
    ##  8 2015       1175  2.48
    ##  9 2016       1195  2.53
    ## 10 2017       1261  2.67
    ## 11 2018       1315  2.78
    ## 12 2019       1307  2.76
    ## 13 2020       1503  3.18
    ## 14 <NA>      33070 69.9

## Chronic condition data

-   All chronic condition files of 2008-2020 were imported into R. After
    excluding duplicated cases described above, we have the same number
    of observations as in the MSBF file (n = 47,292 unique BeneIDs).
-   CC files were merged with MSBF to identify Alzheimer’s disease and
    related dementia cases based on `ALZH_DEMEN_EVER`: the date when the
    beneficiary first met the criteria for the disease (after 1999)
    -   Among 47,292 subjects, there were 8685 cases (18.4%) of
        Alzheimer/dementia cases

<!-- -->

    ## # A tibble: 2 × 3
    ##   ALZH_DEMEN_YN     n   pct
    ##   <fct>         <int> <dbl>
    ## 1 No            38607  81.6
    ## 2 Yes            8685  18.4

-   Number of diagnosis by year
    -   Notice that some of these cases are prevalent cases before the
        AHS-2 baseline questionnaire

<!-- -->

    ## # A tibble: 22 × 3
    ##    ALZH_DEMEN_DX_YR     n   pct
    ##    <chr>            <int> <dbl>
    ##  1 1999                46 0.530
    ##  2 2000                47 0.541
    ##  3 2001                70 0.806
    ##  4 2002                94 1.08 
    ##  5 2003               144 1.66 
    ##  6 2004               190 2.19 
    ##  7 2005               251 2.89 
    ##  8 2006               295 3.40 
    ##  9 2007               367 4.23 
    ## 10 2008               448 5.16 
    ## 11 2009               469 5.40 
    ## 12 2010               451 5.19 
    ## 13 2011               535 6.16 
    ## 14 2012               518 5.96 
    ## 15 2013               562 6.47 
    ## 16 2014               536 6.17 
    ## 17 2015               587 6.76 
    ## 18 2016               671 7.73 
    ## 19 2017               616 7.09 
    ## 20 2018               627 7.22 
    ## 21 2019               601 6.92 
    ## 22 2020               560 6.45

## Descriptive tables

### Overall

|                      | level    | Overall       |
|:---------------------|:---------|:--------------|
| n                    |          | 47292         |
| SEX_IDENT_CD (%)     | Male     | 17109 (36.2)  |
|                      | Female   | 30183 (63.8)  |
| Age_2008 (mean (SD)) |          | 68.14 (11.14) |
| RTI_RACE_CD (%)      | Unknown  | 414 ( 0.9)    |
|                      | NH-White | 33811 (71.5)  |
|                      | Black    | 10166 (21.5)  |
|                      | Other    | 459 ( 1.0)    |
|                      | Asian    | 967 ( 2.0)    |
|                      | Hispanic | 1355 ( 2.9)   |
|                      | Native   | 120 ( 0.3)    |
| Dead (%)             | Alive    | 33070 (69.9)  |
|                      | Dead     | 14222 (30.1)  |

### Stratified by Alzheimer/dementia cases

|                      | level    | No            | Yes          | p       | test |
|:---------------------|:---------|:--------------|:-------------|:--------|:-----|
| n                    |          | 38607         | 8685         |         |      |
| SEX_IDENT_CD (%)     | Male     | 14115 (36.6)  | 2994 (34.5)  | \<0.001 |      |
|                      | Female   | 24492 (63.4)  | 5691 (65.5)  |         |      |
| Age_2008 (mean (SD)) |          | 65.98 (10.32) | 77.75 (9.47) | \<0.001 |      |
| RTI_RACE_CD (%)      | Unknown  | 393 ( 1.0)    | 21 ( 0.2)    | \<0.001 |      |
|                      | NH-White | 26983 (69.9)  | 6828 (78.6)  |         |      |
|                      | Black    | 8664 (22.4)   | 1502 (17.3)  |         |      |
|                      | Other    | 416 ( 1.1)    | 43 ( 0.5)    |         |      |
|                      | Asian    | 843 ( 2.2)    | 124 ( 1.4)   |         |      |
|                      | Hispanic | 1214 ( 3.1)   | 141 ( 1.6)   |         |      |
|                      | Native   | 94 ( 0.2)     | 26 ( 0.3)    |         |      |
| Dead (%)             | Alive    | 30277 (78.4)  | 2793 (32.2)  | \<0.001 |      |
|                      | Dead     | 8330 (21.6)   | 5892 (67.8)  |         |      |
