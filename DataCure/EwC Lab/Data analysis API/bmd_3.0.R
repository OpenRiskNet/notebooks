library(drc)
library(MASS)
library(RJSONIO)

rawArgs <- commandArgs(trailingOnly = TRUE)
args <- as.numeric(rawArgs)

nx <- as.integer(args[1])
ny <- as.integer(args[2])

x <- args[3 : (nx+3-1)]
y <- args[(nx+3) : (nx+3+ny-1)]

nBMR <- as.integer(args[nx+3+ny])
BMR_levels <- args[(nx+3+ny+1) : (nx+3+ny+nBMR)]

xlabel <- rawArgs[(nx+3+ny+nBMR+1)]
ylabel <- rawArgs[(nx+3+ny+nBMR+2)]

jsonFile <- rawArgs[(nx+3+ny+nBMR+3)]
jsonFile2 <- rawArgs[(nx+3+ny+nBMR+4)]

# silence error messages (they are collected in the result)
control <- drmc(errorm=FALSE, noMessage=TRUE)

doseresponse <- cbind.data.frame(x,y)
result <- drm(doseresponse, fct=LL.5(), control=control)
effDoses <- ED(result, BMR_levels, interval = "delta", display=FALSE)


# find minimal non-zero dose and maximum dose
if (is.null(result$convergence)) {
    dmin <- max(y)
    for (testd in y) {
        if ((testd > 0) & (testd < dmin)) {
            dmin <- testd
        }
    }
    dmax <- max(y)

    # create a dataframe of doses from minimum to maximum dose
    doses <- expand.grid(conc=exp(seq(log(dmin), log(dmax), length=200))) 

    # predict dose-response curve with confidence levels
    pm <- predict(result, newdata=doses, interval="confidence", level=0.95)

    # add doses to the predictions
    pm <- cbind(pm, doses)

    # write predictions to the JSON file
    write(toJSON(pm), jsonFile2)

    # write BMDs to JSON file
    write(toJSON(effDoses), jsonFile)
    
    # create data frame with errors & messages
    x <- data.frame("Error" = "False", "Message" = "BMD calculations done.")
    write(toJSON(x), "message.json")
} else if (result$convergence == FALSE) {
    # convergence not ok
    x <- data.frame("Error" = "True", "Message" = "Convergence failed.")
    write(toJSON(x), "message.json")    
} else {
    x <- data.frame("Error" = "True", "Message" = "Convergence ok. Something else seems wrong.")
    write(toJSON(x), "message.json")    
}