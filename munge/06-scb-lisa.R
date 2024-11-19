# anyDuplicated(demo$lopnr)

rtb2 <- rtb %>%
  mutate(
    scb_maritalstatus = case_when(
      Civil %in% c("A", "EP", "OG", "S", "SP") ~ "Single/widowed/divorced",
      Civil %in% c("G", "RP") ~ "Married"
    )
  ) %>%
  select(LopNr, scbyear, scb_maritalstatus)

sdata <- left_join(sdata, rtb2, by = c("lopnr" = "LopNr", "scbyear"))

lisa2 <- lisa %>%
  mutate(
    Sun2000niva = coalesce(Sun2000niva_old, Sun2000niva_Old, Sun2020Niva_Old),
    scb_education = case_when(
      Sun2000niva %in% c(1, 2) ~ "Compulsory school",
      Sun2000niva %in% c(3, 4) ~ "Secondary school",
      Sun2000niva %in% c(5, 6, 7) ~ "University"
    ),
    # DispInk04	Disponibel inkomst (individens delkomponent) - från 2020 ingår lön intjänat i annat nordiskt land	2004-2022	LISA
    # DispInk04_INKLGP	Disponibel inkomst (individens delkomponent) - inkl. lön intjänat i annat nordiskt land	2011-2019	LISA

    scb_dispincome = coalesce(DispInk04_INKLGP, DispInk04)
  ) %>%
  select(LopNr, scbyear, starts_with("scb_"))

sdata <- left_join(
  sdata,
  lisa2,
  by = c("lopnr" = "LopNr", "scbyear")
)

rm(rtb)
rm(rtb2)
rm(lisa)
rm(lisa2)
