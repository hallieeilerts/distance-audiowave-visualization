
# install pacman to streamline further package installation
if (!require("pacman", character.only = TRUE)){
  install.packages("pacman", dep = TRUE)
  if (!require("pacman", character.only = TRUE))
    stop("Package not found")
}

# required packages
pkgs <- c(
  "XML",
  "sp",
  "spacetime",
  "trajectories",
  "geosphere",
  "data.table",
  "tidyr",
  "dplyr",
  "purrr",
  "ggplot2",
  "extrafont"
)

# install missing packages
if(!sum(!p_isinstalled(pkgs))==0){
  p_install(
    package = pkgs[!p_isinstalled(pkgs)], 
    character.only = TRUE
  )
}

# load packages
p_load(pkgs, character.only = TRUE)

# load fonts
loadfonts(device = "win")
windowsFonts()

