
# Required libraries
pacs <- c("tidyverse", "readxl", "lubridate", "tableone")
sapply(pacs, require, character.only = TRUE)

# Read crosswalk file: n = 70.968
crosswalk <- read_fwf("./Data/12172/2022/ssn_bene_xwalk_res000058038_req012172_2022.dat",
                      fwf_widths(c(9, 15, 1, 1, 1), c("ORIG_SSN", "BENE_ID", "SSN_MATCH", "SEX_MATCH", "DOB_MATCH")))

nrow(crosswalk)
summary(crosswalk)

crosswalk %>% 
  split(.$SSN_MATCH)

# How many matches? -- 52,704 subjects (74%)
table(crosswalk$SSN_MATCH)

# There were 115 invalid SSN
crosswalk %>% 
  group_by(SSN_MATCH) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# Gender mismatch -- 824 subjects (1.6%)
crosswalk %>% 
  filter(SSN_MATCH == 1) %>% 
  group_by(SEX_MATCH) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# DOB mismatch -- 3331 subjects (6.3%)
crosswalk %>% 
  filter(SSN_MATCH == 1) %>% 
  group_by(DOB_MATCH) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# How many have both gender and DOB mismatch -- 787 subjects (1.5%)
crosswalk %>% 
  filter(SSN_MATCH == 1, SEX_MATCH == 0, DOB_MATCH == 0) %>%
  nrow()

# How many have either gender OR DOB mismatch -- 3368 subjects (6.4%)
crosswalk %>% 
  filter(SSN_MATCH == 1 & (SEX_MATCH == 0 | DOB_MATCH == 0)) %>%
  nrow()

# Extract matched BENE_IDs
all_matched_bene_ids <- crosswalk %>% 
  filter(SSN_MATCH == 1)

summary(all_matched_bene_ids)
nrow(all_matched_bene_ids)

# BENE_IDs of gender or DOB mismatch (to be removed)
mismatches <- crosswalk %>% 
  filter(SSN_MATCH == 1 & (SEX_MATCH == 0 | DOB_MATCH == 0)) %>%
  select(BENE_ID)
  
# There are two duplicates in BENE_IDs...
all_matched_bene_ids %>% 
  summarize(n = n_distinct(BENE_ID))

dup_BENE_IDs <- all_matched_bene_ids %>% 
  group_by(BENE_ID) %>% 
  summarize(n = sum(n())) %>% 
  filter(n > 1)

all_matched_bene_ids %>% 
  filter(BENE_ID %in% dup_BENE_IDs$BENE_ID)

# There are 106 SSN duplicates ???
all_matched_bene_ids %>% 
  summarize(n = n_distinct(ORIG_SSN))

dup_SSNs <- all_matched_bene_ids %>% 
  group_by(ORIG_SSN) %>% 
  summarize(n = sum(n())) %>% 
  filter(n > 1)

all_matched_bene_ids %>% 
  filter(ORIG_SSN %in% dup_SSNs$ORIG_SSN)

# BENE_IDs that need to be removed:
# Gender/DOB mismatch
# SSN/BENE_ID duplicates
exclude_BENE_IDs <- dup_BENE_IDs %>% 
  select(BENE_ID) %>% 
  union(all_matched_bene_ids %>% 
          filter(ORIG_SSN %in% dup_SSNs$ORIG_SSN) %>% 
          select(BENE_ID)
  ) %>% 
  union(mismatches)

# 3571 BENE_IDs to be removed
length(unique(exclude_BENE_IDs$BENE_ID))

# Read MBSF Summary data on each year
# Data specification of MSBF files
fts_msbf <- read_excel("./Data/mbsf_format.xlsx")
fts_msbf

# Create file names
year <- 2008:2020
fname <- paste0("./Data/12172/", year, "/mbsf_abcd_summary_res000058038_req012172_", year, ".dat")

# Read all MSBF files of 13 years
all_msbf <- fname %>% 
  lapply(\(x) read_fwf(x, fwf_widths(fts_msbf$length, fts_msbf$long_name))) %>% 
  lapply(\(x) anti_join(x, exclude_BENE_IDs)) %>% 
  setNames(year)

all_msbf %>% sapply(nrow)

# Long format over years
all_msbf_long <- all_msbf %>% 
  do.call(rbind, .) %>% 
  arrange(BENE_ID, BENE_ENROLLMT_REF_YR)

# Num of beneficiaries each year
all_msbf_long %>% 
  group_by(BENE_ENROLLMT_REF_YR) %>% 
  tally()

all_msbf_long %>% 
  group_by(BENE_ENROLLMT_REF_YR) %>% 
  tally() %>% 
  ggplot(aes(x = BENE_ENROLLMT_REF_YR, y = n)) + geom_bar(stat = "identity")

# Unique beneficiaries across years: n = 44,585
all_msbf_bene_ids <- all_msbf_long %>% 
  select(BENE_ID) %>% 
  distinct()

nrow(all_msbf_bene_ids)

all_msbf_bene_ids %>% 
  left_join(crosswalk, by = "BENE_ID")

# 4546 matched beneficiaries were never appeared in MSBF files
bene_ids_no_show <- all_matched_bene_ids %>% 
  anti_join(exclude_BENE_IDs) %>% 
  anti_join(all_msbf_bene_ids)

nrow(bene_ids_no_show)

all_msbf %>% 
  lapply(inner_join, y = bene_ids_no_show)

# Age at the last year of appearance
all_msbf_long %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  mutate(AgeCat = cut(AGE_AT_END_REF_YR, breaks = c(0, 3:12 * 10), right = FALSE)) %>% 
  group_by(AgeCat) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# Current Reason for Entitlement Code
all_msbf_long %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  mutate(ENTLMT_RSN_CURR = factor(ENTLMT_RSN_CURR, levels = 0:3, labels = c("OASI", "DIB", "ESRD", "DIB & ESRD"))) %>% 
  group_by(ENTLMT_RSN_CURR) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# Sex/race at the last year of appearance
all_msbf_long %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  group_by(SEX_IDENT_CD) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# How many died during 2008-2020
# 13,218 (29.6%) died
all_msbf_long %>%
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  mutate(Dead = ifelse(is.na(BENE_DEATH_DT), 0, 1),
         Dead = factor(Dead, levels = 0:1, labels = c("Alive", "Dead"))) %>% 
  group_by(Dead) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# N deaths = 13,218
n_deaths <- all_msbf_long %>%
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  filter(!is.na(BENE_DEATH_DT)) %>% nrow()

all_msbf_long %>%
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  mutate(year_died = substr(BENE_DEATH_DT, 1, 4)) %>% 
  group_by(year_died) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# Read chronic conditions data on each year
# Data specification of CC files
fts_cc <- read_excel("./Data/mbsf_cc_format.xlsx")
fts_cc

# Create file names
year <- 2008:2020
fname <- paste0("./Data/12172/", year, "/mbsf_cc_summary_res000058038_req012172_", year, ".dat")

# Read all MSBF files of 13 years
all_cc <- fname %>% 
  lapply(\(x) read_fwf(x, fwf_widths(fts_cc$length, fts_cc$long_name))) %>% 
  lapply(\(x) anti_join(x, exclude_BENE_IDs)) %>% 
  setNames(year)

# Long format over years
all_cc_long <- all_cc %>% 
  do.call(rbind, .) %>% 
  arrange(BENE_ID, BENE_ENROLLMT_REF_YR)

# Num of beneficiaries each year
all_cc_long %>% 
  group_by(BENE_ENROLLMT_REF_YR) %>% 
  tally()

# Unique beneficiaries across years: n = 44,585
all_cc_bene_ids <- all_cc_long %>% 
  select(BENE_ID) %>% 
  distinct()

nrow(all_cc_bene_ids)

# Alzheimer/dementia status at the last year of appearance
# Alzheimer only: n = 3356
all_cc_long %>% 
  mutate(ALZH_YN    = ifelse(is.na(ALZH_EVER), 0, 1)) %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  group_by(ALZH_YN) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100) 

# Alzheimer/dementia: n = 8074
all_cc_long %>% 
  mutate(ALZH_DEMEN_YN = ifelse(is.na(ALZH_DEMEN_EVER), 0, 1)) %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  group_by(ALZH_DEMEN_YN) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100) 

# Both Alzheimer and dementia: n = 8074
all_cc_long %>% 
  mutate(ALZH_DEMEN_YN = ifelse(is.na(ALZH_DEMEN_EVER) & is.na(ALZH_EVER), 0, 1)) %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  group_by(ALZH_DEMEN_YN) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100) 

# Year of Alzheimer/dementia diagnosis at the last year of appearance
# Alzheimer only
all_cc_long %>% 
  filter(!is.na(ALZH_EVER)) %>% 
  mutate(ALZH_DX_YR = substr(ALZH_EVER, 1, 4)) %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  group_by(ALZH_DX_YR) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100) %>% 
  print(n = Inf)

# Both Alzheimer and dementia
all_cc_long %>% 
  filter(!is.na(ALZH_DEMEN_EVER)) %>% 
  mutate(ALZH_DEMEN_DX_YR = substr(ALZH_DEMEN_EVER, 1, 4)) %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  group_by(ALZH_DEMEN_DX_YR) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100) %>% 
  print(n = Inf)

# Generate data for demographic table
RTI_labels <- c("Unknown", "NH-White", "Black", "Other", "Asian", "Hispanic", "Native")
stop_date  <- as.Date("2008-12-31")

msbf_demog <- all_msbf_long %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>% 
  select(BENE_ID, AGE_AT_END_REF_YR:ESRD_IND) %>% 
  mutate(BENE_BIRTH_DT = ymd(BENE_BIRTH_DT),
         BENE_DEATH_DT = ymd(BENE_DEATH_DT),
         Dead = ifelse(is.na(BENE_DEATH_DT), 0, 1),
         Dead = factor(Dead, levels = 0:1, labels = c("Alive", "Dead")),
         COVSTART      = ymd(COVSTART),
         SEX_IDENT_CD  = factor(SEX_IDENT_CD, levels = 1:2, labels = c("Male", "Female")),
         RTI_RACE_CD   = factor(RTI_RACE_CD, levels = 0:6, labels = RTI_labels),
         Age_2008      = trunc((BENE_BIRTH_DT %--% stop_date) / years(1)),
         AgeCat_2008 = cut(Age_2008, breaks = c(0, 3:11 * 10), right = FALSE))

cc_alzh <- all_cc_long %>% 
  mutate(ALZH_DEMEN_YN = ifelse(is.na(ALZH_DEMEN_EVER) & is.na(ALZH_EVER), 0, 1),
         ALZH_DEMEN_YN = factor(ALZH_DEMEN_YN, label = c("No", "Yes"))) %>% 
  group_by(BENE_ID) %>% 
  slice(n()) %>%
  select(BENE_ID, ALZH_DEMEN_YN, ALZH_EVER, ALZH_DEMEN_EVER)

# Demographic table
cc_alzh %>% 
  group_by(ALZH_DEMEN_YN) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

msbf_demog %>% 
  left_join(cc_alzh, by = "BENE_ID") %>% 
  CreateTableOne(vars = c("SEX_IDENT_CD", "Age_2008", "RTI_RACE_CD", "Dead"), data = .) %>% 
  print(showAllLevels = TRUE)

msbf_demog %>% 
  left_join(cc_alzh, by = "BENE_ID") %>% 
  CreateTableOne(strata = "ALZH_DEMEN_YN", vars = c("SEX_IDENT_CD", "Age_2008", "RTI_RACE_CD", "Dead"), data = .) %>% 
  print(showAllLevels = TRUE)

msbf_demog %>% 
  group_by(AgeCat_2008) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

msbf_demog %>% 
  mutate(ENTLMT_RSN_CURR = factor(ENTLMT_RSN_CURR, levels = 0:3, labels = c("OASI", "DIB", "ESRD", "DIB & ESRD"))) %>% 
  group_by(ENTLMT_RSN_CURR) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

msbf_demog %>% 
  filter(ENTLMT_RSN_CURR > 1) %>% 
  select(BENE_ID, AGE_AT_END_REF_YR, ENTLMT_RSN_ORIG, ENTLMT_RSN_CURR)

msbf_demog %>% 
  group_by(Dead) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# Need to decide what to do with:
  # Gender mismatch
  # DOB mismatch
  # SSN duplicates -- more than one SSN is associated with a BENE_ID
  # BENE_ID duplicates -- more than one BENE_ID is associated with a SSN
  # Young Medicare beneficiaries with disabilities and/or ESRD

# Read Cost Use data on each year
# Data specification of CU files
fts_cu <- read_excel("./Data/mbsf_cu_format.xlsx")
fts_cu

# Create file names
year <- 2008:2020
fname <- paste0("./Data/12172/", year, "/mbsf_costuse_res000058038_req012172_", year, ".dat")

# Read all MSBF files of 13 years
all_cu <- fname %>% 
  lapply(\(x) read_fwf(x, fwf_widths(as.integer(fts_cu$length), fts_cu$long_name))) %>% 
  lapply(\(x) anti_join(x, exclude_BENE_IDs)) %>% 
  setNames(year)

# Long format over years
all_cu_long <- all_cu %>% 
  do.call(rbind, .) %>% 
  arrange(BENE_ID, BENE_ENROLLMT_REF_YR)

# Num of beneficiaries each year
all_cu_long %>% 
  group_by(BENE_ENROLLMT_REF_YR) %>% 
  tally()

# Unique beneficiaries across years: n = 44,585
all_cu_bene_ids <- all_cu_long %>% 
  select(BENE_ID) %>% 
  distinct()

nrow(all_cu_bene_ids)

# Read MEDPAR data on each year
# Data specification of MEDPAR files
fts_mp <- read_excel("./Data/mbsf_mp_format.xlsx")
fts_mp

# Create file names
year <- 2008:2020
fname <- paste0("./Data/12172/", year, "/medpar_all_file_res000058038_req012172_", year, ".dat")

# Read all MSBF files of 13 years
all_mp <- fname %>% 
  lapply(\(x) read_fwf(x, fwf_widths(fts_mp$length, fts_mp$long_name))) %>% 
  lapply(\(x) anti_join(x, exclude_BENE_IDs)) %>% 
  setNames(year)

# Long format over years
all_mp_long <- all_mp %>% 
  do.call(rbind, .) %>% 
  arrange(BENE_ID, MEDPAR_YR_NUM)

# Num of beneficiaries each year
all_mp_long %>% 
  group_by(MEDPAR_YR_NUM) %>% 
  tally()

# Unique beneficiaries across years: n = 25,125
all_mp_bene_ids <- all_mp_long %>% 
  select(BENE_ID) %>% 
  distinct()

nrow(all_mp_bene_ids)

all_mp_bene_ids %>% inner_join(bene_ids_no_show) %>% nrow()
all_mp_bene_ids %>% inner_join(all_msbf_bene_ids) %>% nrow()
