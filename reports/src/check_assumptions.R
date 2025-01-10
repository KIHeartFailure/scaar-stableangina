source(here::here("setup/setup.R"))

# load data
load(here("data/clean-data/rsdata.RData"))

dataass <- mice::complete(imprsdata, 3)
dataass <- mice::complete(imprsdata, 6)

# check assumptions for cox models ----------------------------------------

i <- 1
mod <- coxph(formula(paste0(
  "Surv(", outvars$time[i], ",", outvars$var[i], " == 'Yes') ~ sos_com_charlsonciage_cat + ", paste(modvars, collapse = " + ")
)), data = dataass)

# prop hazard assumption
testpat <- cox.zph(mod)
print(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

x11()
plot(testpat[1], resid = T, col = "red")
plot(testpat[4], resid = T, col = "red")
plot(testpat[28], resid = T, col = "red")

ggcoxdiagnostics(mod,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)

i <- 2
mod <- coxph(formula(paste0(
  "Surv(", outvars$time[i], ",", outvars$var[i], " == 'Yes') ~ sos_com_charlsonciage_cat + ", paste(modvars, collapse = " + ")
)), data = dataass)

# prop hazard assumption
testpat <- cox.zph(mod)
print(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

x11()
plot(testpat[1], resid = T, col = "red")
plot(testpat[4], resid = T, col = "red")
plot(testpat[28], resid = T, col = "red")

ggcoxdiagnostics(mod,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)

i <- 3
mod <- coxph(formula(paste0(
  "Surv(", outvars$time[i], ",", outvars$var[i], " == 'Yes') ~ sos_com_charlsonciage_cat + ", paste(modvars, collapse = " + ")
)), data = dataass)

# prop hazard assumption
testpat <- cox.zph(mod)
print(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

x11()
plot(testpat[1], resid = T, col = "red")
plot(testpat[4], resid = T, col = "red")
plot(testpat[28], resid = T, col = "red")


ggcoxdiagnostics(mod,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)

i <- 4
mod <- coxph(formula(paste0(
  "Surv(", outvars$time[i], ",", outvars$var[i], " == 'Yes') ~ sos_com_charlsonciage_cat + ", paste(modvars, collapse = " + ")
)), data = dataass)

# prop hazard assumption
testpat <- cox.zph(mod)
print(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

x11()
plot(testpat[1], resid = T, col = "red")
plot(testpat[4], resid = T, col = "red")
plot(testpat[28], resid = T, col = "red")

ggcoxdiagnostics(mod,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)

i <- 5
mod <- coxph(formula(paste0(
  "Surv(", outvars$time[i], ",", outvars$var[i], " == 'Yes') ~ sos_com_charlsonciage_cat + ", paste(modvars, collapse = " + ")
)), data = dataass)

# prop hazard assumption
testpat <- cox.zph(mod)
print(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

x11()
plot(testpat[1], resid = T, col = "red")
plot(testpat[4], resid = T, col = "red")
plot(testpat[28], resid = T, col = "red")

ggcoxdiagnostics(mod,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)

i <- 8
mod <- coxph(formula(paste0(
  "Surv(", outvars$time[i], ",", outvars$var[i], " == 'Yes') ~ sos_com_charlsonciage_cat + ", paste(modvars, collapse = " + ")
)), data = dataass)

# prop hazard assumption
testpat <- cox.zph(mod)
print(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

x11()
plot(testpat[1], resid = T, col = "red")
plot(testpat[4], resid = T, col = "red")
plot(testpat[28], resid = T, col = "red")

ggcoxdiagnostics(mod,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)
