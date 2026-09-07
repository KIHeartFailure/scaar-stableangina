# Project specific packages, functions and settings -----------------------

# Munge data --------------------------------------------------------------
source(here::here("setup/setup.R"))
dors <- read_fst("./data/fst-data/dors.fst")
source("./munge/01-prep_npr-dors.R")
write.fst(dors, paste0(fstpath, "prepdors.fst"))

# ov + sv
source(here::here("setup/setup.R"))
sv <- read_fst("./data/fst-data/sv.fst")
ov <- read_fst("./data/fst-data/ov.fst")
source("./munge/02-prep-npr.R")
write.fst(patreg, paste0(fstpath, "patreg.fst"))

# scaar
source(here::here("setup/setup.R"))
scaar <- read.fst("./data/fst-data/scaar.fst")
grund <- read.fst("./data/fst-data/grund.fst")
patreg <- read.fst(paste0(fstpath, "patreg.fst"))
dors <- read.fst(paste0(fstpath, "prepdors.fst"))
sentv <- read.fst(paste0(fstpath, "sentv.fst"))
rtb <- read.fst(paste0(fstpath, "rtb.fst"))
source(here("munge/03-pop-selection.R"))

# controls and matching
kontroller <- read.fst(paste0(fstpath, "kontroller.fst"))
source(here("munge/04-controls.R"))

# fu time
source(here("munge/05-endtime.R"))

save(
  file = here("data/clean-data/meta1"),
  list = c(
    "flow",
    "segvars",
    "deathmeta"
  )
)

# socioec
lisa <- read.fst(paste0(fstpath, "lisa.fst"))
source(here("munge/06-scb-lisa.R"))
write.fst(sdata, paste0(fstpath, "sdata1.fst"))

# comorbs + outcomes
source(here::here("setup/setup.R"))
patreg <- read.fst(paste0(fstpath, "patreg.fst"))
scaar <- read.fst("./data/fst-data/scaar.fst")
sdata <- read.fst(paste0(fstpath, "sdata1.fst"))
load(here("data/clean-data/meta1"))
source(here("munge/07-npr-outcom.R"))
write.fst(sdata, paste0(fstpath, "sdata2.fst"))

save(
  file = here("data/clean-data/meta2"),
  list = c(
    "outcommeta"
  )
)

# medications
source(here::here("setup/setup.R"))
sdata <- read.fst(paste0(fstpath, "sdata2.fst"))
source(here("munge/08-pdr-med.R"))
write.fst(sdata, paste0(fstpath, "sdata3.fst"))

save(
  file = here("data/clean-data/meta3"),
  list = c(
    "metalm"
  )
)

# fixvars and imp
source(here::here("setup/setup.R"))
sdata <- read.fst(paste0(fstpath, "sdata3.fst"))

metavars <- read.xlsx("P:/k2_stat_heartfailure/Projects/20210525_shfdb4/dm/metadata/meta_variables.xlsx")
load(here("data/clean-data/meta1"))
load(here("data/clean-data/meta2"))
load(here("data/clean-data/meta3"))

source(here("munge/09-vars.R"))
source(here("munge/10-fix-vars.R"))
source(here("munge/11-pdr-medtime.R"))
source(here("munge/12-create-fgdata.R"))
source(here("munge/13-mi.R"))
write.fst(sdata, paste0(fstpath, "sdata4.fst"))

# Cache/save data ---------------------------------------------------------

save(
  file = here("data/clean-data/sdata.RData"),
  list = c(
    "sdata",
    "impsdata",
    "sdatauseforimp",
    "sdatafg_comp",
    "flow",
    "modvars",
    "modvars_case",
    "tabvars",
    "outvars",
    "metavars",
    "metalm",
    "deathmeta",
    "outcommeta",
    ls()[str_detect(ls(), "^medtimedata_")]
  )
)

# create workbook to write tables to Excel
wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, sheet = "Information")
openxlsx::writeData(wb, sheet = "Information", x = "Tables in xlsx format for tables in Statistical report: Outcomes of stable angina patients with non-obstructive coronary artery disease", rowNames = FALSE, keepNA = FALSE)
openxlsx::saveWorkbook(wb,
  file = here::here("output/tabs/tables.xlsx"),
  overwrite = TRUE
)

# create powerpoint to write figs to PowerPoint
figs <- officer::read_pptx()
print(figs, target = here::here("output/figs/figs.pptx"))
