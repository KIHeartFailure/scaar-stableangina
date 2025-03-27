lmfunc <- function(year) {
  lm <- read_fst(paste0("./data/fst-data/lm_", year, ".fst"), columns = c("LopNr", "EDATUM", "ATC"))
  lm <- lm %>%
    filter(str_detect(ATC, "C03|C07|C08|C09|C10|B01A|A10"))
}

lmall <- lapply(c(paste0("0", 5:9), 10:20), lmfunc)
lmall <- bind_rows(lmall)

# Select ATC codes --------------------------------------------------------

lmsel <- left_join(
  sdata %>%
    select(lopnr, indexdtm, case),
  lmall,
  by = c("lopnr" = "LopNr"),
  relationship = "many-to-many"
) %>%
  mutate(diff = as.numeric(EDATUM - indexdtm)) %>%
  filter(diff >= -120 & diff <= 0) %>% # indexdtm is global_indexplus days after INTERDAT so this is until global_indexplus days after intervention
  select(lopnr, case, ATC)

metatimeprint <- paste0("-120-", global_indexplus, " days")

sdata <- create_medvar(
  atc = "^(C10AA|C10BA0[1-9]|C10BA1[0-3]|C10AX09|C10AX1[3-4])", medname = "antikoagulantia",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)

sdata <- create_medvar(
  atc = "^(C07AB|C07FB)", medname = "bbl",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)

sdata <- create_medvar(
  atc = "^(C09A|C09B|C09C|C09D)", medname = "rasiarni",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)

sdata <- create_medvar(
  atc = "^(C08CA|C09BB|C09DB|C09DX01|C07FB)", medname = "ccb",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)

sdata <- create_medvar(
  atc = "^(B01AC04|B01AC22|B01AC24|B01AC06)", medname = "asap2y12i",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)

sdata <- create_medvar(
  atc = "^(B01AF|B01AA03)", medname = "NOAK_waran",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)

sdata <- create_medvar(
  atc = "^(A10)", medname = "antidiabetic",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)
sdata <- create_medvar(
  atc = "^C03(?!DA)", medname = "diuretic",
  cohortdata = sdata,
  meddata = lmsel,
  id = c("lopnr", "case"),
  valsclass = "fac",
  metatime = metatimeprint
)

metalm[, "Register"] <- "Prescribed Drug Register"

rm(list = c("lmall", "lmsel"))
