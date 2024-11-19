# Inclusion/exclusion criteria --------------------------------------------------------

flow <- tibble(
  criteria = "Registrations in SCAAR",
  n = nrow(scaar)
)

segvars <- paste0("SEGMENT", 1:20)

scaar <- scaar %>%
  select(LopNr, INTERDAT, !!!syms(segvars), INDIKATION, HEIGHT, WEIGHT, SMOKING_STATUS, d_yob, d_GENDER, CSS, CENTREID, REGTYP) %>%
  rename(lopnr = LopNr) %>%
  mutate(
    year = year(INTERDAT),
    scbyear = year - 1,
    indexdtm = INTERDAT + global_indexplus
  )

sdata <- scaar %>%
  group_by(lopnr) %>%
  arrange(indexdtm) %>%
  slice(1) %>%
  ungroup()
flow <- add_row(flow,
  criteria = "First registration in SCAAR",
  n = nrow(sdata)
)

# tidsgräns
sdata <- sdata %>%
  filter(INTERDAT >= ymd("2006-01-01"))
flow <- add_row(flow,
  criteria = ">= 2006",
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(INTERDAT <= ymd("2019-12-31"))
flow <- add_row(flow,
  criteria = "<= 2019",
  n = nrow(sdata)
)

grund2 <- grund %>%
  filter(AterPNr == 1) %>%
  distinct(LopNr)
# table(duplicated(grund$LopNr))
# ej återanvända pnr
sdata <- anti_join(sdata,
  grund2,
  by = c("lopnr" = "LopNr")
)
flow <- add_row(flow,
  criteria = "Not re-used PINs",
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(if_all(all_of(c("INDIKATION", "REGTYP", segvars)), ~ !is.na(.)))
flow <- add_row(flow,
  criteria = "No missing data for INDIKATION, SEGMENTS1-20 or REGTYP",
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(INDIKATION == 1) %>%
  select(-INDIKATION)
flow <- add_row(flow,
  criteria = "Indication = Stable angina pectoris",
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(if_all(all_of(segvars), ~ . <= 2)) # %>%
# select(-contains("SEGMENT"))
flow <- add_row(flow,
  criteria = "All 20 segments <=49% (-, 0-29%, 30-49%)",
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(REGTYP == 1) %>%
  select(-REGTYP)
flow <- add_row(flow,
  criteria = "Angio (no PCI) recorded in SCAAR",
  n = nrow(sdata)
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  sosdate = INDATUM,
  diavar = DIA_all,
  opvar = OP_all,
  type = "com",
  name = "excl_angipci",
  opkod = " FNA| FNB| FNC| FND| FNE| FNF| FNG| FNH",
  diakod = " I21| I22| I200| I012| I090| I40| I41| I423| I514",
  valsclass = "fac",
  warnings = FALSE
)
rm(metaout)
sdata <- sdata %>%
  filter(sos_com_excl_angipci == "No") %>%
  select(-sos_com_excl_angipci)
flow <- add_row(flow,
  criteria = paste0("No STEMI/NSTEMI/IAP/MI/Myocarditis (previous or within the first ", global_indexplus, " days)"),
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(year >= d_yob + 18)
flow <- add_row(flow,
  criteria = ">= 18 years of age",
  n = nrow(sdata)
)

# emigration
sentv2 <- sentv %>%
  group_by(LopNr) %>%
  arrange(SenUtvDatum) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(scb_emigrationdtm = ymd(SenUtvDatum)) %>%
  select(-SenUtvDatum)
sdata <- left_join(sdata, sentv2, by = c("lopnr" = "LopNr"))

sdata <- left_join(
  sdata,
  dors %>% select(lopnr, sos_deathdtm, sos_deathcause),
  by = "lopnr"
)

rtb2 <- rtb %>%
  mutate(birthyear = scbyear - Alder) %>%
  select(scbyear, LopNr, Lan, Kon, birthyear) %>%
  rename(lopnr = LopNr)

sdata <- left_join(
  sdata %>%
    select(-d_yob, -d_GENDER), # , d_yob, d_GENDER),checked and the same in rtb and scaar
  rtb2,
  by = c("lopnr", "scbyear" = "scbyear")
) %>%
  arrange(lopnr) %>%
  filter(!is.na(Kon) & !is.na(birthyear))

flow <- add_row(flow,
  criteria = "Exist in RTB",
  n = nrow(sdata)
)

sdata <- sdata %>%
  mutate(
    tmpenddtm = pmin(sos_deathdtm, scb_emigrationdtm, global_endfollowup, na.rm = T)
  ) %>%
  filter(is.na(tmpenddtm) | indexdtm < tmpenddtm)

flow <- add_row(flow,
  criteria = paste0("Alive, not emigrated and with fu > ", global_indexplus, " days after intervention"),
  n = nrow(sdata)
)
