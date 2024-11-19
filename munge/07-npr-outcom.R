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
  diakod = " I1[0-5]",
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
  diakod = " I50",
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
  diakod = " J4[0-4]",
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
  diakod = " 43[0-4]| 438| I6[0-4]| I69[0-4]",
  # stoptime = -5 * 365.25,
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
  diakod = " N1[7-9]| Z491| Z492",
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
  diakod = " I50",
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
