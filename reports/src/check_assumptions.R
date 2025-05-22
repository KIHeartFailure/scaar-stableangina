source(here::here("setup/setup.R"))

# load data
load(here("data/clean-data/sdata.RData"))


# Check assumptions for cases/controls ------------------------------------

checkass <- function(time, event) {
  mod <- coxph(
    formula(paste0(
      "Surv(", time, ",", event, "== 'Yes') ~ case + ",
      paste(modvars, collapse = " + "), "+ frailty(lopnrcase)"
    )),
    data = sdata
  )

  # prop hazard assumption
  testpat <- cox.zph(mod)
  testpatprint <- as_tibble(testpat$table, rownames = "var") %>%
    mutate(rownr = 1:n())
  print(sig <- testpatprint %>% filter(p < 0.05))

  for (i in sig$rownr) {
    x11()
    plot(testpat[i], resid = T, col = "red")
  }

  # ggcoxdiagnostics(mod,
  #                 type = "dfbeta",
  #                 linear.predictions = FALSE, ggtheme = theme_bw()
  # )
}
checkass(time = outvars$time[1], event = outvars$var[1])
checkass(time = outvars$time[2], event = outvars$var[2])
checkass(time = outvars$time[3], event = outvars$var[3]) # hf
checkass(time = outvars$time[4], event = outvars$var[4])
checkass(time = outvars$time[5], event = outvars$var[5])
checkass(time = outvars$time[6], event = outvars$var[6])
checkass(time = outvars$time[7], event = outvars$var[7]) # cancer
checkass(time = outvars$time[8], event = outvars$var[8]) # case

# Check assumptions for cases ---------------------------------------------

checkass <- function(time, event) {
  mod <- coxph(
    formula(paste0(
      "Surv(", time, ",", event, "== 'Yes') ~ ", paste(modvars_case, collapse = " + ")
    )),
    data = dataass
  )

  # prop hazard assumption
  testpat <- cox.zph(mod)
  testpatprint <- as_tibble(testpat$table, rownames = "var") %>%
    mutate(rownr = 1:n())
  print(sig <- testpatprint %>% filter(p < 0.05))

  for (i in sig$rownr) {
    x11()
    plot(testpat[i], resid = T, col = "red")
  }

  # ggcoxdiagnostics(mod,
  #                 type = "dfbeta",
  #                 linear.predictions = FALSE, ggtheme = theme_bw()
  # )
}

dataass <- mice::complete(impsdata, 3)
checkass(time = outvars$time[1], event = outvars$var[1])
dataass <- mice::complete(impsdata, 6)
checkass(time = outvars$time[1], event = outvars$var[1])

dataass <- mice::complete(impsdata, 3)
checkass(time = outvars$time[6], event = outvars$var[6]) # year
dataass <- mice::complete(impsdata, 6)
checkass(time = outvars$time[6], event = outvars$var[6]) # year
