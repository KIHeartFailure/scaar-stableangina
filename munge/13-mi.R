# Impute missing values ---------------------------------------------------

sdatauseforimp <- sdata %>%
  filter(case == "ANOCA") %>%
  select(lopnr, indexdtm, !!!syms(modvars_case), year, scb_age, contains(outvars$var), !!!syms(outvars$time))

noimpvars <- names(sdatauseforimp)[!names(sdatauseforimp) %in% modvars_case]

# Nelson-Aalen estimator
na <- basehaz(coxph(Surv(sos_outtime_comp, sos_out_comp == "Yes") ~ 1,
  data = sdata, method = "breslow"
))

sdatauseforimp <- left_join(sdatauseforimp, na, by = c("sos_outtime_comp" = "time"))

ini <- mice(sdatauseforimp, maxit = 0, print = F)

pred <- ini$pred
pred[, noimpvars] <- 0
pred[noimpvars, ] <- 0 # redundant

# change method used in imputation to prop odds model
meth <- ini$method
meth[c("scb_education", "year_cat", "scb_dispincome_cat")] <- "polr"
meth[noimpvars] <- ""

## check no cores
cores_2_use <- detectCores() - 1
if (cores_2_use >= 10) {
  cores_2_use <- 10
  m_2_use <- 1
} else if (cores_2_use >= 5) {
  cores_2_use <- 5
  m_2_use <- 2
} else {
  stop("Need >= 5 cores for this computation")
}

cl <- makeCluster(cores_2_use)
clusterSetRNGStream(cl, 49956)
registerDoParallel(cl)

impsdata <-
  foreach(
    no = 1:cores_2_use,
    .combine = ibind,
    .export = c("meth", "pred", "sdatauseforimp"),
    .packages = "mice"
  ) %dopar% {
    mice(sdatauseforimp,
      m = m_2_use, maxit = 10, method = meth,
      predictorMatrix = pred,
      printFlag = FALSE
    )
  }
stopImplicitCluster()

# Check if all variables have been fully imputed --------------------------

datacheck <- mice::complete(impsdata, 1)

for (i in seq_along(modvars_case)) {
  if (any(is.na(datacheck[, modvars_case[i]]))) stop("Missing for imp vars")
}
for (i in seq_along(modvars_case)) {
  if (any(is.na(datacheck[, modvars_case[i]]))) print(paste0("Missing for ", modvars_case[i]))
}
