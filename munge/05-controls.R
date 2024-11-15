kontroller2 <- kontroller %>%
  select(LopNrKontroll, FoddAr, Kon) %>%
  rename(lopnr = LopNrKontroll)

patregkontroller <- left_join(kontroller2,
  patreg,
  by = c("lopnr")
) %>%
  mutate(
    pcimm = str_detect(OP_all, " FNA| FNB| FNC| FND| FNE| FNF| FNG| FNH"),
    mimm = str_detect(DIA_all, " I012| I090| I40| I41| I423| I514| I514B")
  ) %>%
  filter(pcimm | mimm) %>%
  rename(casedtm = INDATUM) %>%
  select(lopnr, casedtm)

scaarkontroller <- left_join(kontroller2,
  scaar,
  by = c("lopnr")
) %>%
  rename(casedtm = INTERDAT) %>%
  select(lopnr, casedtm)

bothkontroller <- bind_rows(patregkontroller, scaarkontroller) %>%
  group_by(lopnr) %>%
  arrange(casedtm) %>%
  slice(1) %>%
  ungroup()

kontroller2 <- left_join(kontroller2,
  bothkontroller,
  by = "lopnr"
)

kontroller2 <- left_join(kontroller2,
  dors %>% select(lopnr, sos_deathdtm, sos_deathcause),
  by = "lopnr"
)

kontroller2 <- left_join(kontroller2, sentv2, by = c("lopnr" = "LopNr"))

# matching
# by sex,age, county of residence and they should be alive and without casedtm prior to matchingdtm

kontrollmatch <- inner_join(
  kontroller2 %>%
    select(-Kon, -FoddAr), # checked and the same in rtb and control file
  rtb2,
  by = c("lopnr")
) %>%
  mutate(
    year = year + 1,
    enddtm = pmin(sos_deathdtm, scb_emigrationdtm, na.rm = T),
    enddtm = pmin(enddtm, casedtm, na.rm = T),
  ) %>%
  rename(lopnrcontrol = lopnr)

controls <- left_join(
  sdata %>%
    select(lopnr, indexdtm, year, birthyear, Kon, Lan),
  kontrollmatch,
  by = c("year", "birthyear", "Kon", "Lan")
) %>%
  filter(is.na(enddtm) | enddtm >= indexdtm)

lopnrcase <- sdata$lopnr[1:400]
controlsout <- controls %>%
  slice(1) %>%
  mutate(lopnr = 0)

set.seed(38478257)

for (i in seq_along(lopnrcase)) {
  cav <- controls %>%
    filter(lopnr == lopnrcase[i])
  controlsout <<- bind_rows(
    controlsout,
    controls %>%
      filter(lopnr == lopnrcase[i]) %>%
      slice_sample(n = 2, replace = FALSE)
  )
  controls <<- controls %>%
    filter(!(lopnrcontrol %in% controlsout$lopnrcontrol | lopnr == lopnrcase[i]))
}

sdata <- bind_rows(
  sdata %>% mutate(
    case = 1,
    lopnrcase = lopnr
  ),
  controlsout %>%
    filter(lopnr != 0) %>%
    rename(
      lopnrcase = lopnr,
      lopnr = lopnrcontrol
    ) %>%
    mutate(case = 0)
) %>%
  mutate(case = factor(case, levels = 0:1, labels = c("Control", "Case")))
