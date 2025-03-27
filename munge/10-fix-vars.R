sdata <- sdata %>%
  mutate(
    scaar_stenos = factor(pmax(!!!syms(segvars)), levels = 1:2, labels = c("0-29", "30-49")),
    scb_region = case_when(
      Lan == "01" ~ "Stockholm",
      Lan == "03" ~ "Uppsala",
      Lan == "04" ~ "Sodermanland",
      Lan == "05" ~ "Ostergotland",
      Lan == "06" ~ "Jonkoping",
      Lan == "07" ~ "Kronoberg",
      Lan == "08" ~ "Kalmar",
      Lan == "09" ~ "Gotland",
      Lan == "10" ~ "Blekinge",
      Lan == "12" ~ "Skane",
      Lan == "13" ~ "Halland",
      Lan == "14" ~ "Vastra Gotaland",
      Lan == "17" ~ "Varmland",
      Lan == "18" ~ "Orebro",
      Lan == "19" ~ "Vastmanland",
      Lan == "20" ~ "Dalarna",
      Lan == "21" ~ "Gavleborg",
      Lan == "22" ~ "Vasternorrland",
      Lan == "23" ~ "Jamtland",
      Lan == "24" ~ "Vasterbotten",
      Lan == "25" ~ "Norrbotten"
    ),
    scb_age = year(indexdtm) - birthyear,
    scb_age_cat = factor(
      case_when(
        scb_age < 65 ~ 1,
        scb_age <= 80 ~ 2,
        scb_age > 80 ~ 3,
      ),
      levels = 1:3,
      labels = c("<65", "65-80", ">80")
    ),
    scb_sex = factor(Kon, levels = 1:2, labels = c("Male", "Female")),
    year = scbyear + 1,
    year_cat = factor(case_when(
      year <= 2010 ~ "2006-2010",
      year <= 2015 ~ "2011-2015",
      year <= 2019 ~ "2016-2019"
    )),
    scaar_bmi = round(WEIGHT / (HEIGHT / 100)^2, 1),
    scaar_bmi_cat = factor(
      case_when(
        is.na(scaar_bmi) ~ NA_real_,
        scaar_bmi < 30 ~ 1,
        scaar_bmi >= 30 ~ 2
      ),
      levels = 1:2,
      labels = c("<30", ">=30")
    ),
    scaar_smoke = if_else(SMOKING_STATUS == 9, NA_real_, SMOKING_STATUS),
    scaar_smoke = factor(scaar_smoke, levels = 0:2, labels = c("Never", "Previous", "Current")),
    scaar_css = case_when(
      is.na(CSS) | CSS == 9 ~ NA_real_,
      CSS == 1 ~ 1,
      CSS %in% c(2, 3, 4) ~ 2
    ),
    scaar_css = factor(scaar_css, levels = 1:2, labels = c("<=1", ">=2")),
    sos_com_hypertension = case_when(
      sos_com_hf == "No" & (sos_lm_rasiarni == "Yes" | sos_lm_ccb == "Yes") ~ "Yes",
      TRUE ~ sos_com_hypertension
    ),
    sos_out_comp = if_else(sos_out_deathcv == "Yes" |
      sos_out_hospmi == "Yes" |
      sos_out_hospstroke == "Yes", "Yes", "No"),
    sos_outtime_comp = pmin(sos_outtime_hospmi, sos_outtime_hosphf),
    sos_outtime_comp = pmin(sos_outtime_comp, sos_outtime_hospstroke),
    sos_outtime_comp = pmin(sos_outtime_comp, sos_outtime_revasc),
    sos_out_comp_cr = factor(create_crevent(sos_out_comp, sos_out_death, eventvalues = c("Yes", "Yes")),
      levels = 0:2, labels = c("cens", "comp", "death")
    ),
  )

# income
inc <- sdata %>%
  reframe(incsum = list(enframe(quantile(scb_dispincome,
    probs = c(0.33, 0.66),
    na.rm = TRUE
  ))), .by = year) %>%
  unnest(cols = c(incsum)) %>%
  pivot_wider(names_from = name, values_from = value)

sdata <- left_join(
  sdata,
  inc,
  by = "year"
) %>%
  mutate(
    scb_dispincome_cat = factor(
      case_when(
        scb_dispincome < `33%` ~ 1,
        scb_dispincome < `66%` ~ 2,
        scb_dispincome >= `66%` ~ 3
      ),
      levels = 1:3,
      labels = c("1st tertile within year", "2nd tertile within year", "3rd tertile within year")
    )
  ) %>%
  select(-`33%`, -`66%`)

# impute education and income
typeedu <- sdata %>%
  count(scb_education) %>%
  slice(which.max(n)) %>%
  pull(scb_education)

typemar <- sdata %>%
  count(scb_maritalstatus) %>%
  slice(which.max(n)) %>%
  pull(scb_maritalstatus)

sdata <- sdata %>%
  mutate(
    scb_educationimp = replace_na(scb_education, typeedu),
    scb_maritalstatusimp = replace_na(scb_maritalstatus, typemar)
  )

inc <- sdata %>%
  reframe(incsum = list(enframe(quantile(scb_dispincome,
    probs = c(0.5),
    na.rm = TRUE
  ))), .by = year) %>%
  unnest(cols = c(incsum)) %>%
  pivot_wider(names_from = name, values_from = value)

sdata <- left_join(
  sdata,
  inc,
  by = "year"
) %>%
  mutate(scb_dispincomeimp = coalesce(scb_dispincome, `50%`)) %>%
  select(-`50%`)

inc <- sdata %>%
  reframe(incsum = list(enframe(quantile(scb_dispincomeimp,
    probs = c(0.33, 0.66),
    na.rm = TRUE
  ))), .by = year) %>%
  unnest(cols = c(incsum)) %>%
  pivot_wider(names_from = name, values_from = value)

sdata <- left_join(
  sdata,
  inc,
  by = "year"
) %>%
  mutate(
    scb_dispincomeimp_cat = factor(
      case_when(
        scb_dispincomeimp < `33%` ~ 1,
        scb_dispincomeimp < `66%` ~ 2,
        scb_dispincomeimp >= `66%` ~ 3
      ),
      levels = 1:3,
      labels = c("1st tertile within year", "2nd tertile within year", "3rd tertile within year")
    )
  ) %>%
  select(-`33%`, -`66%`)

for (i in seq_along(modvars)) {
  if (any(is.na(sdata[, modvars[i]]))) stop("Missing for imp vars")
}

for (i in seq_along(modvars)) {
  if (any(is.na(sdata[, modvars[i]]))) print(paste0("Missing for ", modvars[i]))
}

sdata <- sdata %>%
  mutate(across(where(is_character), factor))

## Create numeric variables needed for comp risk model
# for (i in seq_along(c("case", modvars))) {
#  sdata <- create_crvar(sdata, c("case", modvars)[i])
# }
