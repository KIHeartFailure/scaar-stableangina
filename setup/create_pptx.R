create_pptx <- function(plot, left = 0.5, top = 0.5, width = 10, height = 6, forestp = FALSE) {
  if (!forestp) {
    plot <- rvg::dml(ggobj = plot)
    figs %>%
      officer::add_slide(layout = "Title and Content", master = "Office Theme") %>%
      officer::ph_with(plot, location = officer::ph_location(
        width = width, height = height, left = left, top = top
      )) %>%
      print(target = here::here("output/figs/figs.pptx"))
  }

  if (forestp) {
    # 2. Save the forest plot to a temporary high-res PNG file
    # (Adjust width and height to match your PowerPoint aspect ratio)
    tmp_img <- tempfile(fileext = ".png")
    png(tmp_img, width = width, height = height, units = "in", res = 300)
    print(plot)
    dev.off()

    figs %>%
      officer::add_slide(layout = "Title and Content", master = "Office Theme") %>%
      officer::ph_with(value = officer::external_img(tmp_img), location = officer::ph_location(
        width = width, height = height, left = left, top = top
      )) %>%
      print(target = here::here("output/figs/figs.pptx"))
  }
}
