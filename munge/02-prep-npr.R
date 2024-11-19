ov <- ov %>%
  select(LopNr, INDATUMA, AR, contains("dia"), contains("op")) %>%
  rename(
    HDIA = hdia,
    lopnr = LopNr
  ) %>%
  mutate(
    INDATUM = ymd(INDATUMA),
    EKOD = ""
  ) %>%
  select(-INDATUMA)

ov <- prep_sosdata(ov, utdatum = FALSE, opvar = "op")

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

# Merge sos data ----------------------------------------------------------

patreg <- bind_rows(
  sv %>% mutate(sos_source = "sv"),
  ov %>% mutate(sos_source = "ov") %>% select(-sosdtm)
)
