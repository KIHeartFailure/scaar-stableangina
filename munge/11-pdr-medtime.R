lmfunc <- function(year) {
  lm <- read_fst(paste0("./data/fst-data/lm_", year, ".fst"), columns = c("LopNr", "EDATUM", "ATC"))
  lm <- lm %>%
    filter(str_detect(ATC, "C03|C07|C08|C09|C10|B01A|A10"))
}

lmall <- lapply(c(paste0("0", 5:9), 10:20), lmfunc)
lmall <- bind_rows(lmall)

# Select ATC codes --------------------------------------------------------

lmsel <- inner_join(
  sdata %>%
    select(lopnr, indexdtm, censdtm, case),
  lmall,
  by = c("lopnr" = "LopNr"),
  relationship = "many-to-many"
) %>%
  mutate(diff = as.numeric(EDATUM - indexdtm)) %>%
  filter(diff >= -120 & EDATUM <= censdtm) %>%
  select(lopnr, case, ATC, EDATUM)

# allow 5 months between prescriptions. Assume stopped after 5 mo if no new.

accept_limit <- 153

medtimefunc_inner <- function(atc, medname, outcome) {
  medname <- paste0("sos_lm_", medname)

  tmp_sdata <- sdata %>%
    mutate(enddtm = indexdtm + !!sym(outcome)) %>%
    select(lopnr, case, indexdtm, enddtm)

  tmp_data <- inner_join(
    lmsel %>%
      filter(stringr::str_detect(ATC, atc)),
    tmp_sdata,
    by = c("lopnr", "case")
  ) %>%
    filter(EDATUM < enddtm)


  tmp_data2 <- tmp_data %>%
    mutate(EDATUMstop = EDATUM + accept_limit) %>%
    group_by(lopnr, case) %>%
    arrange(EDATUM, EDATUMstop) %>%
    mutate(
      n = row_number(),
      link = case_when(
        EDATUM <= dplyr::lag(EDATUMstop) ~ 1,
        EDATUMstop >= lead(EDATUM) ~ 1
      )
    ) %>%
    ungroup() %>%
    arrange(lopnr, case, EDATUM, EDATUMstop)

  tmp_data2 <- tmp_data %>%
    mutate(
      n = row_number(),
      EDATUMstop = EDATUM + accept_limit
    ) %>%
    group_by(lopnr, case) %>%
    arrange(EDATUM, EDATUMstop) %>%
    mutate(link = case_when(
      EDATUM > dplyr::lag(EDATUMstop) ~ row_number(),
      row_number() == 1 ~ row_number()
    )) %>%
    ungroup() %>%
    arrange(lopnr, case, EDATUM, EDATUMstop) %>%
    mutate(link = zoo::na.locf(link))

  tmp_data3 <- tmp_data2 %>%
    group_by(lopnr, case, link) %>%
    summarise(
      EDATUM = min(EDATUM),
      EDATUMstop = max(EDATUMstop),
      .groups = "drop"
    ) %>%
    ungroup()


  tmp_data4 <- left_join(tmp_sdata,
    tmp_data3,
    by = c("lopnr", "case")
  )

  tmp_data5 <- tmp_data4 %>%
    mutate(
      startdtm = case_when(
        is.na(EDATUM) ~ indexdtm,
        EDATUM < indexdtm ~ indexdtm,
        TRUE ~ EDATUM
      ),
      stopdtm = case_when(
        is.na(EDATUM) ~ enddtm,
        EDATUMstop > enddtm ~ enddtm,
        TRUE ~ EDATUMstop
      ),
      med = if_else(is.na(EDATUM), 0, 1)
    ) %>%
    group_by(lopnr, case) %>%
    arrange(startdtm) %>%
    mutate(
      n = 1:n(),
      last = n == n(),
      lagstopdtm = lag(stopdtm)
    ) %>%
    ungroup()

  # insert post first if needed
  tmp_data_first <- tmp_data5 %>%
    filter(n == 1) %>%
    filter(startdtm > indexdtm) %>%
    mutate(
      med = 0,
      stopdtm = startdtm,
      startdtm = indexdtm
    )

  # insert post last if needed
  tmp_data_last <- tmp_data5 %>%
    filter(last) %>%
    filter(stopdtm < enddtm) %>%
    mutate(
      med = 0,
      startdtm = stopdtm,
      stopdtm = enddtm
    )

  # insert post in middle if needed
  tmp_data_middle <- tmp_data5 %>%
    filter(n >= 2) %>%
    mutate(
      med = 0,
      stopdtm = startdtm,
      startdtm = lagstopdtm
    )

  tmp_data6 <- bind_rows(tmp_data_first, tmp_data5, tmp_data_middle, tmp_data_last) %>%
    arrange(lopnr, case, startdtm, stopdtm) %>%
    rename(!!sym(medname) := med) %>%
    select(lopnr, case, !!sym(medname), startdtm, stopdtm)
}

medtimefunc_fixtime <- function(meddata, medname, meddataall = tmp_meddata_all2) {
  medname <- paste0("sos_lm_", medname)
  meddata <- full_join(meddataall,
    meddata %>% select(-stopdtm),
    by = c("lopnr", "case", "startdtm")
  ) %>%
    group_by(lopnr, case) %>%
    arrange(startdtm, !!sym(medname)) %>%
    fill(!!sym(medname), .direction = "down") %>%
    ungroup() %>%
    arrange(lopnr, case, startdtm, !!sym(medname))
}

medtimefunc <- function(outcome, event) {
  meddata_ac <- medtimefunc_inner(
    atc = "^(C10AA|C10BA0[1-9]|C10BA1[0-3]|C10AX09|C10AX1[3-4])",
    medname = "antikoagulantia",
    outcome = outcome
  )
  meddata_bbl <- medtimefunc_inner(
    atc = "^(C07AB|C07FB)",
    medname = "bbl",
    outcome = outcome
  )
  meddata_rasi <- medtimefunc_inner(
    atc = "^(C09A|C09B|C09C|C09D)",
    medname = "rasiarni",
    outcome = outcome
  )
  meddata_ccb <- medtimefunc_inner(
    atc = "^(C08CA|C09BB|C09DB|C09DX01|C07FB)",
    medname = "ccb",
    outcome = outcome
  )
  meddata_asa <- medtimefunc_inner(
    atc = "^(B01AC04|B01AC22|B01AC24|B01AC06)",
    medname = "asap2y12i",
    outcome = outcome
  )
  meddata_noak <- medtimefunc_inner(
    atc = "^(B01AF|B01AA03)",
    medname = "NOAK_waran",
    outcome = outcome
  )
  meddata_antid <- medtimefunc_inner(
    atc = "^(A10)",
    medname = "antidiabetic",
    outcome = outcome
  )

  tmp_meddata_all <-
    purrr::reduce(
      list(
        meddata_ac,
        meddata_bbl,
        meddata_rasi,
        meddata_ccb,
        meddata_asa,
        meddata_noak,
        meddata_antid
      ),
      dplyr::full_join,
      by =
        c("lopnr", "case", "startdtm", "stopdtm")
    ) %>%
    arrange(lopnr, case, startdtm, desc(stopdtm)) %>%
    select(lopnr, case, startdtm, stopdtm)

  tmp_meddata_all2 <- tmp_meddata_all %>%
    pivot_longer(values_to = "startdtm", cols = c(startdtm, stopdtm)) %>%
    select(-name) %>%
    distinct() %>%
    group_by(lopnr, case) %>%
    arrange(startdtm) %>%
    mutate(stopdtm = lead(startdtm)) %>%
    ungroup() %>%
    arrange(lopnr, case, startdtm) %>%
    filter(!is.na(stopdtm))

  meddata_ac <- medtimefunc_fixtime(
    meddata = meddata_ac,
    medname = "antikoagulantia",
    meddataall = tmp_meddata_all2
  )
  meddata_bbl <- medtimefunc_fixtime(
    meddata = meddata_bbl,
    medname = "bbl",
    meddataall = tmp_meddata_all2
  )
  meddata_rasi <- medtimefunc_fixtime(
    meddata = meddata_rasi,
    medname = "rasiarni",
    meddataall = tmp_meddata_all2
  )
  meddata_ccb <- medtimefunc_fixtime(
    meddata = meddata_ccb,
    medname = "ccb",
    meddataall = tmp_meddata_all2
  )
  meddata_asa <- medtimefunc_fixtime(
    meddata = meddata_asa,
    medname = "asap2y12i",
    meddataall = tmp_meddata_all2
  )
  meddata_noak <- medtimefunc_fixtime(
    meddata = meddata_noak,
    medname = "NOAK_waran",
    meddataall = tmp_meddata_all2
  )
  meddata_antid <- medtimefunc_fixtime(
    meddata = meddata_antid,
    medname = "antidiabetic",
    meddataall = tmp_meddata_all2
  )

  tmp_meddata_all3 <-
    purrr::reduce(
      list(
        meddata_ac,
        meddata_bbl,
        meddata_rasi,
        meddata_ccb,
        meddata_asa,
        meddata_noak,
        meddata_antid
      ),
      dplyr::full_join,
      by =
        c("lopnr", "case", "startdtm", "stopdtm")
    ) %>%
    arrange(lopnr, case, startdtm, desc(stopdtm))

  timemedvars <- names(tmp_meddata_all3)[str_detect(names(tmp_meddata_all3), "sos_lm_")]
  medtimedata <- full_join(
    tmp_meddata_all3 %>%
      mutate(across(starts_with("sos_lm"), ynfac)),
    sdata %>%
      select(-contains(timemedvars)),
    by = c("lopnr", "case")
  ) %>%
    group_by(lopnr, case) %>%
    arrange(startdtm) %>%
    mutate(
      n = 1:n(),
      last = n == n()
    ) %>%
    ungroup() %>%
    mutate(
      event = ynfac(if_else(!!sym(event) == "Yes" & last, 1, 0)),
      starttime = as.numeric(startdtm - indexdtm),
      stoptime = as.numeric(stopdtm - indexdtm)
    )
  return(medtimedata)
}

medtimedata_comp <- medtimefunc(outcome = outvars$time[1], event = outvars$var[1])
medtimedata_deathcv <- medtimefunc(outvars$time[2], outvars$var[2])
medtimedata_hosphf <- medtimefunc(outvars$time[3], event = outvars$var[3])
medtimedata_hospmi <- medtimefunc(outvars$time[4], outvars$var[4])
medtimedata_hospstroke <- medtimefunc(outvars$time[5], outvars$var[5])
medtimedata_revasc <- medtimefunc(outvars$time[6], outvars$var[6])
medtimedata_death <- medtimefunc(outvars$time[7], outvars$var[7])
medtimedata_ca <- medtimefunc(outvars$time[8], outvars$var[8])

rm(list = c("lmall", "lmsel"))
