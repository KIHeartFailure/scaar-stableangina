# Comorbidities -----------------------------------------------------------

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "hypertension",
  diakod = " I10| I11(?!0)| I1[2-5]",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "hf",
  diakod = " I50| I110",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "copd",
  diakod = " J4[1-4]",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "diabetes",
  diakod = " E1[0-4]",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "af",
  diakod = " I48",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)
sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "stroke",
  diakod = " I6[0-4]| I69[0-4]",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)
sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  opvar = OP_all,
  type = "com",
  name = "ckd",
  diakod = " N18| N19| N26| Q61| Z49| Z992| Z940",
  opkod = " KAS00| KAS10| KAS20| DR014| DR015| DR016| DR020| DR012| DR013| DR023| DR024| TJA33| TJA35",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)
sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = HDIA,
  type = "com",
  name = "cancer3y",
  diakod = " C",
  stoptime = -3 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)
sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "muscoloskeletal3y",
  diakod = " M",
  stoptime = -3 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "aortic",
  diakod = " I0[5-8]| I3[4-9]",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = DIA_all,
  type = "com",
  name = "cardiomyopathy",
  diakod = " I421| I422",
  stoptime = -5 * 365.25,
  valsclass = "fac",
  warnings = FALSE
)

# Outcomes ----------------------------------------------------------------

sdata <- create_sosvar(
  sosdata = patreg %>% filter(sos_source == "sv"),
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = HDIA,
  type = "out",
  name = "hosphf",
  diakod = " I50| I110",
  censdate = censdtm,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg %>% filter(sos_source == "sv"),
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = HDIA,
  type = "out",
  name = "hospstroke",
  diakod = " I6[0-4]",
  censdate = censdtm,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg %>% filter(sos_source == "sv"),
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  diavar = HDIA,
  type = "out",
  name = "hospmi",
  diakod = " I21| I22| I200",
  censdate = censdtm,
  valsclass = "fac",
  warnings = FALSE
)

sdata <- create_sosvar(
  sosdata = patreg,
  cohortdata = sdata,
  patid = lopnr,
  indexdate = indexdtm,
  add_unique = case,
  sosdate = INDATUM,
  opvar = OP_all,
  type = "out",
  name = "revasc",
  opkod = " FNG| FNA| FNB| FNC| FND| FNE| FNF| FNH",
  censdate = censdtm,
  valsclass = "fac",
  warnings = FALSE
)

outcommeta <- metaout
rm(metaout)
rm(patreg)

# outcome from scaar
scaarout <- scaar %>%
  select(LopNr, INTERDAT, !!!syms(segvars), REGTYP) %>%
  rename(lopnr = LopNr) %>%
  filter(if_all(all_of(segvars), ~ . %in% c(NA, 0, 1, 2))) %>%
  filter(REGTYP == 1) %>%
  select(lopnr, INTERDAT)

scaarout2 <- left_join(sdata %>% select(lopnr, case, indexdtm, censdtm),
  scaarout,
  by = "lopnr"
) %>%
  filter(INTERDAT > indexdtm & INTERDAT <= censdtm) %>%
  group_by(lopnr, case) %>%
  arrange(INTERDAT) %>%
  slice(1) %>%
  ungroup() %>%
  rename(scaaroutdtm = INTERDAT) %>%
  select(-censdtm)


sdata <- left_join(sdata, scaarout2, by = c("lopnr", "case", "indexdtm")) %>%
  mutate(
    scaar_out_ca = ynfac(if_else(!is.na(scaaroutdtm), 1, 0)),
    scaaroutdtm = coalesce(scaaroutdtm, censdtm),
    scaar_outtime_ca = as.numeric(scaaroutdtm - indexdtm)
  )

# check!!! remove!!!
scaaroutcheck <- scaar %>%
  select(LopNr, INTERDAT, !!!syms(segvars), REGTYP) %>%
  rename(lopnr = LopNr) %>%
  filter(if_all(all_of(segvars), ~ . %in% c(1, 2))) %>%
  filter(REGTYP == 1) %>%
  select(lopnr, INTERDAT)

scaaroutcheck2 <- left_join(sdata %>% select(lopnr, case, indexdtm, censdtm),
  scaaroutcheck,
  by = "lopnr"
) %>%
  filter(INTERDAT > indexdtm & INTERDAT <= censdtm) %>%
  group_by(lopnr, case) %>%
  arrange(INTERDAT) %>%
  slice(1) %>%
  ungroup() %>%
  rename(scaaroutcheckdtm = INTERDAT) %>%
  select(-censdtm)


sdata <- left_join(sdata, scaaroutcheck2, by = c("lopnr", "case", "indexdtm")) %>%
  mutate(
    scaar_out_cacheck = ynfac(if_else(!is.na(scaaroutcheckdtm), 1, 0)),
    scaaroutcheckdtm = coalesce(scaaroutcheckdtm, censdtm),
    scaar_outtime_cacheck = as.numeric(scaaroutcheckdtm - indexdtm)
  )
