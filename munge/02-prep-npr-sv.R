# Link hospital visits ----------------------------------------------------

sv <- sv %>%
  select(LopNr, INDATUMA, UTDATUMA, AR, contains("dia"), contains("op")) %>%
  select(-starts_with("OPD")) %>%
  rename(
    HDIA = hdia,
    lopnr = LopNr
  ) %>%
  mutate(
    INDATUM = ymd(INDATUMA),
    UTDATUM = ymd(UTDATUMA),
    INDATUM = coalesce(INDATUM, UTDATUM),
    UTDATUM = coalesce(UTDATUM, INDATUM),
    EKOD = ""
  ) %>%
  select(-INDATUMA, -UTDATUMA)

sv <- prep_sosdata(sv, utdatum = FALSE, opvar = "op")

sv2 <- sv %>%
  filter(!is.na(INDATUM) & !is.na(UTDATUM)) %>% # obs have missing for either
  mutate(UTDATUM = case_when(
    INDATUM > UTDATUM ~ INDATUM,
    TRUE ~ UTDATUM
  )) %>%
  group_by(lopnr) %>%
  arrange(INDATUM, UTDATUM) %>%
  mutate(
    n = row_number(),
    link = case_when(
      INDATUM <= dplyr::lag(UTDATUM) ~ 1,
      UTDATUM >= lead(INDATUM) ~ 1
    )
  ) %>%
  ungroup() %>%
  arrange(lopnr, INDATUM, UTDATUM)

svlink <- sv2 %>%
  filter(!is.na(link)) %>%
  group_by(lopnr) %>%
  arrange(INDATUM, UTDATUM) %>%
  mutate(link2 = case_when(
    INDATUM > dplyr::lag(UTDATUM) ~ row_number(),
    row_number() == 1 ~ row_number()
  )) %>%
  ungroup() %>%
  arrange(lopnr, INDATUM, UTDATUM) %>%
  mutate(link2 = zoo::na.locf(link2))

svlink <- svlink %>%
  group_by(lopnr, link2) %>%
  summarize(
    DIA_all = paste0(" ", stringr::str_squish(str_c(DIA_all, collapse = " "))),
    OP_all = paste0(" ", stringr::str_squish(str_c(OP_all, collapse = " "))),
    HDIA = paste0(" ", stringr::str_squish(str_c(HDIA, collapse = " "))),
    INDATUM = min(INDATUM),
    UTDATUM = max(UTDATUM),
    .groups = "drop"
  ) %>%
  ungroup()

svlink <- bind_rows(
  sv2 %>% filter(is.na(link)) %>% mutate(sos_hosplinked = 0),
  svlink %>% mutate(sos_hosplinked = 1)
) %>%
  select(-link, -link2, -n, -sosdtm) %>%
  mutate(AR = year(UTDATUM))
