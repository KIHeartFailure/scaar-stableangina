# Inclusion/exclusion criteria --------------------------------------------------------

flow <- tibble(
  criteria = "Registrations in SCAAR",
  n = nrow(scaar)
)

segvars <- paste0("SEGMENT", 1:20)

scaar <- scaar %>%
  select(LopNr, INTERDAT, !!!syms(segvars), INDIKATION, HEIGHT, WEIGHT, SMOKING_STATUS, d_yob, d_GENDER, CSS, CENTREID) %>%
  rename(lopnr = LopNr) %>%
  mutate(year = year(INTERDAT))

sdata <- scaar %>%
  group_by(lopnr) %>%
  arrange(INTERDAT) %>%
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
  filter(INTERDAT <= ymd("2020-12-31"))
flow <- add_row(flow,
  criteria = "<= 2020",
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
  filter(if_all(all_of(c("INDIKATION", segvars)), ~ !is.na(.)))
flow <- add_row(flow,
  criteria = "No missing data for INDIKATION or SEGMENTS1-20",
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(INDIKATION == 1) %>%
  select(-INDIKATION)

flow <- add_row(flow,
  criteria = "Stable angina pectoris",
  n = nrow(sdata)
)

sdata <- sdata %>%
  filter(if_all(all_of(segvars), ~ . <= 2)) %>%
  select(-contains("SEGMENT"))

flow <- add_row(flow,
  criteria = "All 20 segments <=49% (-, 0-29%, 30-49%)",
  n = nrow(sdata)
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = INTERDAT,
  sosdate = INDATUM,
  diavar = OP_all,
  type = "com",
  name = "excl_angipci",
  opkod = " FNA| FNB| FNC| FND| FNE| FNF| FNG| FNH",
  valsclass = "fac",
  warnings = FALSE
)

rm(metaout)

sdata <- sdata %>%
  filter(sos_com_excl_angipci == "No") %>%
  select(-sos_com_excl_angipci)
flow <- add_row(flow,
  criteria = "No previos FNA-H (STEMI, NSTEMI, MINOCA???? NEED MORE CODES???)",
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
  mutate(birthyear = year - Alder) %>%
  select(year, LopNr, Lan, Kon, birthyear) %>%
  rename(lopnr = LopNr)

sdata <- left_join(
  sdata %>%
    mutate(scbyear = year - 1) %>%
    select(-d_yob, -d_GENDER), # , d_yob, d_GENDER),checked and the same in rtb and scaar
  rtb2,
  by = c("lopnr", "scbyear" = "year")
) %>%
  mutate(year = scbyear + 1) %>%
  arrange(lopnr) %>%
  select(-scbyear) %>%
  filter(!is.na(Kon) & !is.na(birthyear))

flow <- add_row(flow,
  criteria = "Exist in RTB",
  n = nrow(sdata)
)

sdata <- sdata %>%
  mutate(
    tmpenddtm = pmin(sos_deathdtm, scb_emigrationdtm, na.rm = T),
    indexdtm = INTERDAT + global_indexplus
  ) %>%
  filter(is.na(tmpenddtm) | indexdtm < tmpenddtm)

flow <- add_row(flow,
  criteria = paste0("Alive and not emigrated < Procedure and > ", global_indexplus, " days follow-up"),
  n = nrow(sdata)
)
