# default is to use tidyverse functions
select <- dplyr::select
rename <- dplyr::rename
filter <- dplyr::filter
mutate <- dplyr::mutate
complete <- tidyr::complete
fixed <- stringr::fixed

# used for calculation of ci
global_z05 <- qnorm(1 - 0.025)

global_cols <- RColorBrewer::brewer.pal(7, "Dark2")

fstpath <- paste0("./data/fst-data/")

global_endfollowup <- ymd("2019-12-31")

global_indexplus <- 14
