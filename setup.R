#mran.date <- "2020-04-28"
#options(repos=paste0("https://cran.microsoft.com/snapshot/",mran.date,"/"))
# Above lines are commented out, as we use the default CRAN repository for 
# the rocker images
# They would need to be switched to the PPM anyway... MRAN is dead.

pkgTest <- function(x,try=FALSE)
{
        if (!require(x,character.only = TRUE))
        {
                install.packages(x,dep=TRUE)
                if(!require(x,character.only = TRUE)) stop("Package not found")
        }
  if ( try ) {
    print(paste0("Unloading ",x))
    detach(paste0("package:",x), unload = TRUE, character.only = TRUE)
  }
  return("OK")
}



global.libraries <- c("foreign","tidyverse","REBayes","splines")

results <- sapply(as.list(global.libraries), pkgTest)

# install Rmosek

rmosek.dir <- Sys.getenv("RMOSEKDIR")
source(file.path(rmosek.dir,"builder.R"), echo=TRUE)
attachbuilder()
install.rmosek()