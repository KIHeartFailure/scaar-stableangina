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

# Merge sos data ----------------------------------------------------------

svlink <- read.fst(paste0(fstpath, "prepsvlink.fst"))

patreg <- bind_rows(
  svlink %>% mutate(sos_source = "sv"),
  ov %>% mutate(sos_source = "ov") %>% select(-sosdtm)
)
