# end fu emigration from Sweden, death or 2020-12-31
sdata <- sdata %>%
  mutate(
    censdtm = pmin(sos_deathdtm, scb_emigrationdtm, na.rm = T),
    censdtm = pmin(censdtm, global_endfollowup, na.rm = T)
  ) %>%
  select(-enddtm, -tmpenddtm)

# fix death and cv death
sdata <- sdata %>%
  mutate(
    sos_deathdtm = if_else(!is.na(sos_deathdtm) & sos_deathdtm <= global_endfollowup, sos_deathdtm, NA_Date_),
    sos_outtime_death = as.numeric(censdtm - indexdtm),
    sos_out_death = ynfac(if_else(!is.na(sos_deathdtm), 1, 0))
  )

sdata <- create_deathvar(
  cohortdata = sdata,
  indexdate = indexdtm,
  censdate = censdtm,
  deathdate = sos_deathdtm,
  name = "cv",
  orsakvar = sos_deathcause,
  orsakkod = "^I",
  valsclass = "fac",
  warnings = FALSE
)

metaout <- metaout %>%
  mutate(Code = str_remove_all(Code, "\\^"))

deathmeta <- metaout
rm(metaout)
