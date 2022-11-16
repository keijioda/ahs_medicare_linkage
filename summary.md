AHS-2 Medicare Linkage
================

## Datasets

- Data received from CMS on October 31, 2022
- Contains 4 self-decrypting EXE files for each year of 2008-2020
  - Master Beneficiary Summary File (MBSFABCD)
  - Chronic Conditions (MBSFCC)
  - Cost and Utilization (MBSFCU)
  - MEDPAR (MEDP)
- For 2017 and later, we have:
  - An additional file for a new set of 30 chronic conditions
    (MBSFCHRONIC)
- Also includes a crosswalk file between SSN and BeneID

## Crosswalk

### SSN matches

- The crosswalk file contains 70968 SSNs (`ORIG_SSN`).
- There are 3 matching indicators:
  - `SSN_MATCH` for SSN-to-BeneID match
  - and whenever there is a match, we also have `SEX_MATCH`, and
    `DOB_MATCH`
- Among 70,968 subjects, there were 52,704 matches (74%):
  - There were 115 invalid SSNs (`SSN_MATCH = 9`)

<!-- -->

    ## # A tibble: 3 × 3
    ##   SSN_MATCH     n    pct
    ##       <dbl> <int>  <dbl>
    ## 1         0 18149 25.6  
    ## 2         1 52704 74.3  
    ## 3         9   115  0.162

- Among 52,704 matches, there were 824 subjects (1.6%) whose gender
  mismatched with AHS-2 data
  - How should we deal with these gender mismatches? – to be removed.

<!-- -->

    ## # A tibble: 2 × 3
    ##   SEX_MATCH     n   pct
    ##       <dbl> <int> <dbl>
    ## 1         0   824  1.56
    ## 2         1 51880 98.4

- Among 52,704 matches, there were 3331 subjects (6.3%) whose DOB
  mismatched with AHS-2 data
  - How should we deal with these DOB mismatches? – to be removed.

<!-- -->

    ## # A tibble: 2 × 3
    ##   DOB_MATCH     n   pct
    ##       <dbl> <int> <dbl>
    ## 1         0  3331  6.32
    ## 2         1 49373 93.7

### Anomalies

- There were two BeneIDs that appeared twice in the crosswalk file.
  - Each of these BeneIDs have two different SSNs (below shows only the
    last 4 digits of SSN)

<!-- -->

    ## # A tibble: 4 × 5
    ##   SSN_hidden BENE_ID         SSN_MATCH SEX_MATCH DOB_MATCH
    ##   <chr>      <chr>               <dbl>     <dbl>     <dbl>
    ## 1 5500       2222222jxjxjTHH         1         1         1
    ## 2 9017       2222222jxjxjTHH         1         0         0
    ## 3 9228       2222222T1T1y1Jf         1         1         1
    ## 4 3893       2222222T1T1y1Jf         1         0         0

- There were 106 SSNs that appeared twice in the crosswalk file – see
  the firse several examples below
  - Each of these SSNs have two different BeneIDs (below shows only the
    last 4 digits of SSN)

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

- These duplicates (n = 212) are to be excluded for analysis below.
  Similarly, any BeneIDs with gender or DOB mismatch are to be removed
  (n = 3368).
  - In total, 3571 BeneIDs are to be removed.

## Master Beneficiary Summary (MBSF) File

- All MBSF files of 2008-2020 were imported into R. After excluding
  duplicated cases described above, the number of observations each year
  is:

<!-- -->

    ##  2008  2009  2010  2011  2012  2013  2014  2015  2016  2017  2018  2019  2020 
    ## 27464 28138 28701 29414 30043 30625 31101 31521 31914 32259 32461 32589 32693

- After combining all years of data, we have 44585 unique BeneIDs in
  these 13 years.
  - This indicates that there are 4546 matched beneficiaries that do not
    appear in the MSBF files.

### Age, gender and deaths

- See the distribution of age at last seen. Notice the beneficiaries of
  aged \<60 years.

<!-- -->

    ## # A tibble: 9 × 3
    ##   AgeCat        n      pct
    ##   <fct>     <int>    <dbl>
    ## 1 [30,40)       6  0.0135 
    ## 2 [40,50)      87  0.195  
    ## 3 [50,60)     683  1.53   
    ## 4 [60,70)    8507 19.1    
    ## 5 [70,80)   15435 34.6    
    ## 6 [80,90)   13123 29.4    
    ## 7 [90,100)   6369 14.3    
    ## 8 [100,110)   374  0.839  
    ## 9 [110,120)     1  0.00224

- Current reason for Medicare entitlement (at last seen) indicates that
  3.5% of all beneficiaries are because of disability and/or end-stage
  renal disease:

<!-- -->

    ## # A tibble: 4 × 3
    ##   ENTLMT_RSN_CURR     n     pct
    ##   <fct>           <int>   <dbl>
    ## 1 OASI            43033 96.5   
    ## 2 DIB              1482  3.32  
    ## 3 ESRD               40  0.0897
    ## 4 DIB & ESRD         30  0.0673

- See the distribution of sex according to the year last seen:

<!-- -->

    ## # A tibble: 2 × 3
    ##   SEX_IDENT_CD     n   pct
    ##          <dbl> <int> <dbl>
    ## 1            1 16038  36.0
    ## 2            2 28547  64.0

- How many of them died during 2008-2020? There were 13,218 (29.6%)
  deaths during the 13 years:

<!-- -->

    ## # A tibble: 2 × 3
    ##   Dead      n   pct
    ##   <fct> <int> <dbl>
    ## 1 Alive 31367  70.4
    ## 2 Dead  13218  29.6

- See the distribution of deaths by years:

<!-- -->

    ## # A tibble: 14 × 3
    ##    year_died     n   pct
    ##    <chr>     <int> <dbl>
    ##  1 2008        687  1.54
    ##  2 2009        750  1.68
    ##  3 2010        777  1.74
    ##  4 2011        913  2.05
    ##  5 2012        891  2.00
    ##  6 2013        995  2.23
    ##  7 2014        975  2.19
    ##  8 2015       1092  2.45
    ##  9 2016       1111  2.49
    ## 10 2017       1159  2.60
    ## 11 2018       1231  2.76
    ## 12 2019       1228  2.75
    ## 13 2020       1409  3.16
    ## 14 <NA>      31367 70.4

## Chronic condition data

- All chronic condition files of 2008-2020 were imported into R. After
  excluding duplicated cases described above, we have the same number of
  observations as in the MSBF file (n = 44,585 unique BeneIDs).
- CC files were merged with MSBF to identify Alzheimer’s disease and
  related dementia cases based on `ALZH_DEMEN_EVER`: the date when the
  beneficiary first met the criteria for the disease (after 1999)
  - Among 44,585 subjects, there were 8074 cases (18.1%) of
    Alzheimer/dementia cases

<!-- -->

    ## # A tibble: 2 × 3
    ##   ALZH_DEMEN_YN     n   pct
    ##   <fct>         <int> <dbl>
    ## 1 No            36511  81.9
    ## 2 Yes            8074  18.1

- Number of diagnosis by year
  - Notice that some of these cases are prevalent cases before the AHS-2
    baseline questionnaire

<!-- -->

    ## # A tibble: 22 × 3
    ##    ALZH_DEMEN_DX_YR     n   pct
    ##    <chr>            <int> <dbl>
    ##  1 1999                41 0.508
    ##  2 2000                42 0.520
    ##  3 2001                65 0.805
    ##  4 2002                84 1.04 
    ##  5 2003               130 1.61 
    ##  6 2004               169 2.09 
    ##  7 2005               224 2.77 
    ##  8 2006               269 3.33 
    ##  9 2007               343 4.25 
    ## 10 2008               402 4.98 
    ## 11 2009               435 5.39 
    ## 12 2010               425 5.26 
    ## 13 2011               507 6.28 
    ## 14 2012               479 5.93 
    ## 15 2013               526 6.51 
    ## 16 2014               494 6.12 
    ## 17 2015               558 6.91 
    ## 18 2016               632 7.83 
    ## 19 2017               573 7.10 
    ## 20 2018               589 7.30 
    ## 21 2019               566 7.01 
    ## 22 2020               521 6.45

## Descriptive tables

### Overall

|                      | level    | Overall       |
|:---------------------|:---------|:--------------|
| n                    |          | 44585         |
| SEX_IDENT_CD (%)     | Male     | 16038 (36.0)  |
|                      | Female   | 28547 (64.0)  |
| Age_2008 (mean (SD)) |          | 68.10 (11.09) |
| RTI_RACE_CD (%)      | Unknown  | 387 ( 0.9)    |
|                      | NH-White | 32113 (72.0)  |
|                      | Black    | 9410 (21.1)   |
|                      | Other    | 438 ( 1.0)    |
|                      | Asian    | 891 ( 2.0)    |
|                      | Hispanic | 1242 ( 2.8)   |
|                      | Native   | 104 ( 0.2)    |
| Dead (%)             | Alive    | 31367 (70.4)  |
|                      | Dead     | 13218 (29.6)  |

### Stratified by Alzheimer/dementia cases

|                      | level    | No            | Yes          | p       | test |
|:---------------------|:---------|:--------------|:-------------|:--------|:-----|
| n                    |          | 36511         | 8074         |         |      |
| SEX_IDENT_CD (%)     | Male     | 13262 (36.3)  | 2776 (34.4)  | 0.001   |      |
|                      | Female   | 23249 (63.7)  | 5298 (65.6)  |         |      |
| Age_2008 (mean (SD)) |          | 65.98 (10.27) | 77.69 (9.47) | \<0.001 |      |
| RTI_RACE_CD (%)      | Unknown  | 369 ( 1.0)    | 18 ( 0.2)    | \<0.001 |      |
|                      | NH-White | 25689 (70.4)  | 6424 (79.6)  |         |      |
|                      | Black    | 8075 (22.1)   | 1335 (16.5)  |         |      |
|                      | Other    | 399 ( 1.1)    | 39 ( 0.5)    |         |      |
|                      | Asian    | 779 ( 2.1)    | 112 ( 1.4)   |         |      |
|                      | Hispanic | 1117 ( 3.1)   | 125 ( 1.5)   |         |      |
|                      | Native   | 83 ( 0.2)     | 21 ( 0.3)    |         |      |
| Dead (%)             | Alive    | 28737 (78.7)  | 2630 (32.6)  | \<0.001 |      |
|                      | Dead     | 7774 (21.3)   | 5444 (67.4)  |         |      |

## Cost and utilization data

- All CU files of 2008-2020 were imported into R. After excluding
  duplicated cases described above, we have the same number of
  observations as in the MSBF file (n = 44,585 unique BeneIDs).

## MedPAR (Medicare provider analysis and review) data

- All MedPAR files of 2008-2020 were imported into R. After excluding
  duplicated cases described above, there are n = 25,125 unique BeneIDs
  during 13 years.
  - All of these BeneIDs do appear in the MSBF file.
