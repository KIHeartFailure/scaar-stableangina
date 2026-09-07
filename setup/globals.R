# default is to use tidyverse functions
select <- dplyr::select
rename <- dplyr::rename
filter <- dplyr::filter
mutate <- dplyr::mutate
complete <- tidyr::complete
fixed <- stringr::fixed

# used for calculation of ci
global_z05 <- qnorm(1 - 0.025)

# global_cols <- RColorBrewer::brewer.pal(7, "Dark2")
global_cols <- c("#629B71", "#6c629b", "#919b62", "#9b6291", "#9b7162", "#626f9b", "#9b628c", "#9b626a", "#62819b")

fstpath <- paste0("./data/fst-data/")

global_endfollowup <- ymd("2019-12-31")

global_indexplus <- 14
