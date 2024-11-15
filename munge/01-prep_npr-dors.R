dors <- dors %>%
  group_by(LopNr) %>%
  arrange(ULORSAK) %>%
  slice(n()) %>% # select ULORSAk not ""
  ungroup()

dors <- dors %>%
  mutate(sos_deathdtm = ymd(case_when(
    substr(DODSDAT, 5, 8) == "0000" ~ paste0(substr(DODSDAT, 1, 4), "0701"),
    substr(DODSDAT, 7, 8) == "00" ~ paste0(substr(DODSDAT, 1, 6), "15"),
    TRUE ~ DODSDAT
  ))) %>%
  rename(
    sos_deathcause = ULORSAK,
    lopnr = LopNr
  ) %>%
  select(-DODSDAT) %>%
  filter(sos_deathdtm <= global_endfollowup)
