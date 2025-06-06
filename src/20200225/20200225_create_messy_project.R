create_messy_project <- function() {
  dir.create(path = file.path("messy_project"))
  dir.create(path = file.path("messy_project", "Script1"))
  dir.create(path = file.path("messy_project", "script2"))
  writeLines(
    text =
      "*",
    con = file.path("messy_project", ".gitignore")
  )
  writeLines(
    text = "Version: 1.0

RestoreWorkspace: Yes
SaveWorkspace: No
AlwaysSaveHistory: Default

EnableCodeIndexing: Yes
UseSpacesForTab: Yes
NumSpacesForTab: 2
Encoding: UTF-8

RnwWeave: knitr
LaTeX: XeLaTeX

AutoAppendNewline: Yes
StripTrailingWhitespace: Yes
",
    con = file.path("messy_project", "messy_project.Rproj")
  )
  writeLines(
    text = "",
    con = file.path("messy_project", "analysis test july2018.R")
  )
  writeLines(
    text = "#visualizations
library(tidyverse)
setwd('c:/R/messy_project/')
birds <- read_csv('bird obs 20170621.csv')
fig1 <- ggplot(birds, aes(x = PlaatsGemeente)) + geom_bar()
ggsave('figure1.jpg', fig1)
    ",
    con = file.path("messy_project", "1.R")
  )
  writeLines(
    text = "#data preparation",
    con = file.path("messy_project", "2.R")
  )
  writeLines(
    text = "#this file contains helper functions that will be useful throughout the entire project",
    con = file.path("messy_project", "helpers.R")
  )
  writeLines(
   text = "#analyze the data for paper",
   con = file.path("messy_project", "Script1", "analysis-final.R")
  )
  writeLines(
    text = "#analyze the data for paper
#after revision",
    con = file.path("messy_project", "Script1", "analysis-finalfinal.R")
  )
  writeLines(
    text = "Suppose this file contains data about bird ringing in Belgium. Give the file a better name if you know the date pattern is MMYYYY.",
    con = file.path("messy_project", "dirtydata-012020.csv")
  )
  writeLines(
   text = "",
   con = file.path("messy_project", "figure1.jpg")
  )
  # writeLines(
  #   text = "",
  #   con = file.path("messy_project", "README.md")
  # )
  writeLines(
    text = "id,EuringCode,PlaatsGemeente,PlaatsToponym,PlaatsToponymDetail
89043,05910,Agadir,Strand,Agadir beach
    89032,05910,Agadir,Strand,Plage Paradise
    78701,05910,Albert Village,Vuilstort,Albion Landfill Site
    137556,05910,Arteixo,Strand,Playa de Alba
    135360,5910,Barreiros,Strand,Arealonga Beach
    98162,04560,Beveren,Doelpolder Noord,eiland
    106631,04560,Beveren,Prosperpolder Noord,eiland 6
    9314,05920,Blankenberge,Haven,Oosterstaketsel
    49470,05920,Blankenberge,Pier,strand onder pier
    18725,,Blankenberge,Strand,1 golfbreker oost
    18728,,Blankenberge,Strand,2de golfbreker oost
    18729,,Blankenberge,Strand,3de golfbreker oost
    30586,05920,Blankenberge,Strand,camping Esmeralda Tritonlaan
    138932,5920,Blankenberge,WZC De Strandjutter,dak
    136535,5910,Borssele,Sloehaven,Achter
    9857,05910,Borssele,Sloehaven,Arrow Terminal
    136528,,Borssele,Sloehaven,Covra
    23269,05920,Borssele,Sloehaven,EPZ-centrale
    136547,5910,Borssele,Sloehaven,Groot
    57096,,Borssele,Van Cittershaven,Thermphos
    108428,5910,Borssele,Van Cittershaven,Verbrugge West
    136664,5920,Boulogne-sur-Mer,Haven,bus
    56315,05920,Boulogne-sur-Mer,Haven,Comilog
    66454,05920,Boulogne-sur-Mer,Haven,continentale nutrition
    1368,05920,Boulogne-sur-Mer,Loubet,dak
    32208,05920,Breskens,Haven,vuurtoren
    112336,,Brugge,Pathoekeweg,kolonie
    138001,5910,Brussel,Marie-Louiseplein,vijver
    113101,,Cadiz,Strand,Playa de La Caleta
    64787,05920,Calais,Bassin de Plaisance,parking
    56223,05920,Calais,Haven,Bassin du Paradis
    56622,05910,Calais,Haven,broedkolonie
    42841,05920,Calais,Haven,Quai Auguste Delpierre
    46571,,Calais,Haven,Quai de la Loire
    14213,05920,Calais,Haven,vissershaven
    65676,,Calais,Quai de la Loire,kolonie
    78199,05920,Calais,Quai de la Loire,quai  de la Loire - colony
    101945,5910,Calais,Quai Delpierre,kolonie
    48694,05910,Cambrils,Strand,La LLosa Beach
    59564,,Camperduin,Hondsb. Zeewering,km 25
    42837,05910,Carino,Strand,La Concha
    95193,,Carnota,Strand,Larino beach
    78029,05910,Cervo,Strand,San Cibrao beach
    22939,,Chiclana de la Frontera,Vuilstort,Victoria
    42574,05920,De Panne,Strand,De Rampe
    104498,5920,De Panne,Strand,Monument
    13760,05920,De Panne,Strand,Slufter
    30681,05920,De Panne,Strand,Westhoek
    133613,04560,Delfzijl,Breebaartpolder,Termunten
    113191,04560,Doel,Doeldok,Dam
    ",
    con = file.path("messy_project", "bird obs 20170621.csv")
  )
}
