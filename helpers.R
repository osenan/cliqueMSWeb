percentageA <- function(peaklist) {
    per1 = sum(!is.na(peaklist$an1))
    per2 = sum(!is.na(peaklist$an2))
    per3 = sum(!is.na(peaklist$an3))
    per4 = sum(!is.na(peaklist$an4))
    per5 = sum(!is.na(peaklist$an5))
    meanper <- mean(c(per1,per2,per3,per4,per5))
    return(meanper/nrow(peaklist))
}

mastot <- function(peaklist) {
    meanmass <- c(length(unique(peaklist$mass1)),
                  length(unique(peaklist$mass2)),
                  length(unique(peaklist$mass3)),
                  length(unique(peaklist$mass4)),
                  length(unique(peaklist$mass5))
                  )
    return(mean(meanmass))
}

searchmass <- function(peaklist, rtmin, rtmax, mm, ppm) {
    rtminC <- peaklist[peaklist$rtmin >= rtmin,]
    rtmaxC <- rtminC[rtminC$rtmax <= rtmax,]
    rowsC <- unique(unlist(lapply(1:5, function(x) {
        mass = paste("mass",x, sep = "")
        goodR <- rtmaxC[!is.na(rtmaxC[,mass]),]
        error <- abs(goodR[,mass]-mm)/mm
        pos <- which(sqrt(2)*error < ppm*1e-6)
        candidates <- rownames(goodR[pos,])
    })))
    return(rowsC)
}

