# Variables for baseline tables -----------------------------------------------

tabvars <- c(
  # demo
  "year",
  "year_cat",
  "scb_sex",
  "scb_age",
  "scb_age_cat",

  # comorbs
  "scaar_stenos",
  "scaar_smoke",
  "scaar_bmi",
  "scaar_bmi_cat",
  "sos_com_hf",
  "sos_com_diabetes",
  "sos_com_hypertension",
  "sos_com_stroke",
  "sos_com_af",
  "sos_com_copd",
  "sos_com_ckd",
  "scaar_css",
  "sos_com_cancer3y",

  # treatments
  "sos_lm_rasiarni",
  "sos_lm_bbl",
  "sos_lm_diuretic",
  "sos_lm_ccb",
  "sos_lm_antikoagulantia",
  "sos_lm_asap2y12i",
  "sos_lm_NOAK_waran",
  "sos_lm_antidiabetic",

  # socec
  "scb_maritalstatus",
  "scb_education",
  "scb_dispincome_cat"
)

# Variables for models (imputation, log, cox reg) ----------------------------

tabvars_not_in_mod <- c(
  "scb_age_cat", "year_cat", "year", "scb_age", "scb_sex",
  "scaar_smoke",
  "scaar_bmi",
  "scaar_bmi_cat",
  "scaar_css",
  "scb_dispincome_cat",
  "scb_education",
  "scb_maritalstatus",
  "scaar_stenos",
  "sos_com_diabetes"
)

modvars <- c(tabvars[!(tabvars %in% tabvars_not_in_mod)], "scb_educationimp", "scb_dispincomeimp_cat", "scb_maritalstatusimp")

tabvars_not_in_mod <- c(
  "year", "scb_age",
  "scaar_bmi",
  "sos_com_ckd",
  "sos_com_diabetes"
)

modvars_case <- tabvars[!(tabvars %in% tabvars_not_in_mod)]

outvars <- tibble(
  var = c(
    "sos_out_comp", "sos_out_death", "sos_out_deathcv", "sos_out_hosphf", "sos_out_hospmi",
    "sos_out_hospstroke", "sos_out_revasc", "scaar_out_ca"
  ),
  time = c(
    "sos_outtime_comp", "sos_outtime_death", "sos_outtime_death", "sos_outtime_hosphf", "sos_outtime_hospmi",
    "sos_outtime_hospstroke", "sos_outtime_revasc", "scaar_outtime_ca"
  ),
  name = c(
    "Composite of cardiovascular death, heart failure hospitalization, myocardial infarction or stroke", "Death",
    "Cardiovascular death", "First heart failure hospitalization", "First myocardial infarction", "First stroke", "First revascularization",
    "First repeated diagnostic coronary angiography"
  ),
  shortname = c("Composite", "Death", "CV death", "HF hospitalization", "MI", "Stroke", "Revascularization", "Coronary angiography"),
  composite = c(T, F, F, F, F, F, F, F),
  primary = c(T, F, F, F, F, F, F, F),
  order = c(1, 7, 2, 3, 4, 5, 6, 8)
) %>%
  arrange(order)

metavars <- bind_rows(
  metavars %>%
    filter(str_detect(variable, "shf_", negate = T)),
  tibble(
    variable = c(
      "year",
      "scaar_smoke",
      "scaar_bmi",
      "scaar_css",
      "scaar_stenos",
      "sos_com_hf",
      "sos_com_ckd",
      "sos_lm_rasiarni",
      "sos_lm_bbl",
      "sos_lm_diuretic",
      "sos_lm_ccb",
      "sos_lm_antikoagulantia",
      "sos_lm_asap2y12i",
      "sos_lm_NOAK_waran",
      "sos_lm_antidiabetic",
      "scb_sex",
      "scb_age"
    ),
    label = c(
      "Year of intervention",
      "Smoking",
      "BMI",
      "CSS",
      "Degree of stenosis",
      "Heart failure",
      "CKD",
      "RASi/ARNi",
      "Beta-blockers",
      "Diuretics",
      "Calcium channel blockers",
      "Lipid lowering",
      "Antiplatelet therapy",
      "Anticoagulation",
      "Glucose lowering",
      "Sex",
      "Age"
    ),
    units = c(rep(NA, 2), "kg/m²", rep(NA, 13), "years")
  )
)
