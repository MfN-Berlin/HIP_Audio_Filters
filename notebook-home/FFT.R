library(tuneR)
library(ggplot2)
library(dplyr)

# The filter is constructed based on the audiogram:
#
# * As the recordings' sample rate tops at 48 kHz, the highest filter band is 24 kHz. 
#   The lowest filter band is at 10Hz, which is a realistic lower limit for a recording.
# 
# * Equalization steps are spaced in 1 octave intervals (there are 11 octaves between 10Hz and 24kHz)
# 
# * For each EQ step, the filter weight is computed by applying the M-weighting function described in 
#   Southall et al. (2007), appendix A, p. 500
# 

R <- function(f, f.low, f.high) { 
    resp <- (f.high^2 * f^2)/((f^2 + f.high^2) * (f^2 + f.low^2))
    return(resp)
}

M <- function(R.f, R.max) {
    resp <- 20 * log(R.f / R.max)
    return(resp)
}

# Make a sequence of frequencies that will be plotted 
# Frequency.in.kHz, in steps of 1 octave, covering the frequency range in limits_x
make.f.seq <- function(min.f, max.f) {
    limits.x <- c(min.f, max.f)
    octaves <- round(log2(limits.x[2]/limits.x[1]))
    seq <- 2^(seq(log2(limits.x[1]), log2(limits.x[2]), length.out=octaves ))
    return(seq)
}

###################################
#
# Defining the filter values
# apply Southall et al. (2007), appendix A, p. 500
#
# @param seq a sequence of frequencies in kilohertz to plot
# @param f.low, f.high functional hearing range in kilohertz
# @returns a table with weights in dB for each frequency in seq
###################################
make.M.table <- function(seq, f.low, f.high) {
    r <- numeric(length(seq))
    for (i in 1:length(seq)) {
        f <- seq[i]
        r[i] <- R(f, f.low, f.high)    
    }

    R.max <- max(abs(r))
    m <- numeric(length(r))
    for (i in 1:length(r)) {
        R.f <- r[i]
        m[i] <- M(R.f, R.max)
    }
    M.table <- data.frame(seq, m)
    colnames(M.table) <- c("Frequency.in.kHz", "Gain.in.dB")
    return(M.table)
}

# plot the M-weighting table
plot.M <- function(M.table, labels=FALSE) {
    p <- ggplot(data=M.table) +
        geom_smooth(aes(Frequency.in.kHz, Gain.in.dB), color="blue", se=FALSE, fullrange=TRUE) +
        geom_point(aes(Frequency.in.kHz, Gain.in.dB), color="blue") +
        labs(x = "Frequency (kHz)", y = "Weighting (dB)") +
        scale_y_continuous() +
        scale_x_log10() +
        coord_cartesian(xlim=c(0.02, 24), ylim=c(0,-50)) + # this is the range that will actually be shown
        theme_classic() +
        annotation_logticks(sides="b")
    if (labels) {
        p <- p +
            geom_text(aes(Frequency.in.kHz, Gain.in.dB, 
            label=paste(round(Frequency.in.kHz, digits=3), "kHz\n" , round(Gain.in.dB, digits=3),"dB")),
            check_overlap = TRUE)
    }
    return(p)
}

###################################
#
# Compute FFT for the input file
#
###################################
comp_fft <- function(sndObj) {
    # convert data to range -1, 1
    # s1 <- sndObj@.Data
    s1 <- sndObj@.Data[!is.na(sndObj@.Data)]

    #s1 <- sndObj@.Data

    s1 <- s1 / 2^(sndObj@bit -1)
    # compute fft
    n <- length(s1)
    p <- fft(s1)

    # plot fft
    nUniquePts <- ceiling((n+1)/2)
    p <- p[1:nUniquePts] #select just the first half since the second half 
                     # is a mirror image of the first
    p <- abs(p)  #take the absolute value, or the magnitude, drop phase info
    p <- p / n #scale by the number of points so that
           # the magnitude does not depend on the length 
           # of the signal or on its sampling frequency  
    p <- p^2  # square it to get the power 

    # multiply by two (see technical document for details)
    # odd nfft excludes Nyquist point
    if (n %% 2 > 0){
        p[2:length(p)] <- p[2:length(p)]*2 # we've got odd number of points fft
    } else {
        p[2: (length(p) -1)] <- p[2: (length(p) -1)]*2 # we've got even number of points fft
    }
    freqArray <- (0:(nUniquePts-1)) * (sndObj@samp.rate / n) #  create the frequency array 
    resp <- list("power"=p, "nUniquePts"=nUniquePts, "freqArray"=freqArray)
}

####################################################
#
# Generate sox command
# The generated command can be used to invoque sox 
# by copy-pasting it in a Linux terminal.
#
####################################################
sox_command <- function(inputfile, outputfile, filter.table, Q) {
    filter.table.truncated <- filter.table[filter.table$Frequency.in.kHz < 24,]
    eq_string <- paste("equalizer", filter.table.truncated$Frequency.in.kHz*1000, Q, filter.table.truncated$Gain.in.dB)
    eq_string <- paste(eq_string, collapse=" ")
    paste("sox", inputfile, outputfile, eq_string, "norm -3")
}

####################################################
# compute the functional hearing frequency range
#
# @param audiogram a data frame containing audiogram data with the columns "Frequency.in.kHz" and "SPL"
# @return a data frame with "eff.freq.low" and "eff.freq.high" in kHz
####################################################
def.f.range <- function(audiogram) {
    eff.freq.low <- min(audiogram$Frequency.in.kHz)
    eff.freq.high <- max(audiogram$Frequency.in.kHz)    
    return(data.frame(eff.freq.low, eff.freq.high))
}

####################################################
# plot the data, the fit curve, and the effective hearing range
#
# @param audiogram a data frame containing audiogram data with the columns "Frequency.in.kHz" and "SPL"
# @param a data frame with "eff.freq.low" and "eff.freq.high" in kHz, as returned by def.f.range()
####################################################
plot.effective <- function(audiogram, range) {
    label.y.pos = 160 # where to put the range labels

    ggplot(audiogram) +
        geom_jitter(aes(Frequency.in.kHz, SPL), width=0.05, alpha=0.25) +
        geom_smooth(aes(Frequency.in.kHz, SPL), color="seagreen", se=FALSE, fullrange=TRUE) +
        geom_vline(xintercept=range$eff.freq.low, linetype=3) +
        geom_vline(xintercept=range$eff.freq.high, linetype=3) +
        annotate("text", 
                 x=range$eff.freq.low, 
                 y=label.y.pos, 
                 label=paste(range$eff.freq.low, "kHz"), 
                 hjust=-0.1, vjust=1, size=5) +
        annotate("text", 
                 x=range$eff.freq.high, 
                 y=label.y.pos, 
                 label=paste(round(range$eff.freq.high), "kHz"), 
                 hjust=1.1, vjust=1, size=5) +
        annotate("text", 
                 x=range$eff.freq.low + 2.5, 
                 y=label.y.pos, 
                 label="<--- functional hearing range --->", hjust=0.42, vjust=-1, size=5) +
        theme_classic() +
        labs(x="Frequency in kHz", y="dB SPL") +
        scale_x_log10() +
        scale_y_continuous() +
        coord_cartesian(xlim=c(0.01, 500), ylim=c(0, 160)) + # this is the range that will actually be shown
        annotation_logticks(sides="b")
}

###################################
#
# Defining the filter values DEPRECATED
# uses loess smoothing to fit a weighting filter to the audiogram
#
###################################
def_filter_deprecated <- function(audiogram) {
    # Frequency and SPL limits
    limits_x <- c(0.02, 24)  # Frequencies from 10Hz to 24kHz
    limits_y <- c(-50, 160)  # SPL from -50 to 160 dB

    # define the fit function
    audiogram.lo <- loess(
        SPL ~ Frequency.in.kHz, 
        audiogram, 
        control = loess.control(surface="direct", statistics="exact"))

    # Frequency.in.kHz, in steps of 1 octave, covering the frequency range in limits_x
    octaves <- round(log2(limits_x[2]/limits_x[1]))
    seq <- 2^(seq(log2(limits_x[1]), log2(limits_x[2]), length.out=octaves ))

    # Fitted SPL values, with extrapolation to cover the whole filter range
    SPL.fit <- predict(audiogram.lo, data.frame(Frequency.in.kHz = seq), se = TRUE)$fit

    # calculate SPL relative to best hearing performance
    SPL.rel <- min(SPL.fit) - SPL.fit

    # Print result as a table
    filter.table <- data.frame(round(seq, digits=3), round(SPL.rel))
    colnames(filter.table) <- c("Frequency.in.kHz", "Gain.in.dB")
    return(filter.table)
}



# References
#Carcagno, S. (2013) Basic Sound Processing with R. 
# http://samcarcagno.altervista.org/blog/basic-sound-processing-r/?doing_wp_cron=1601298903.9209051132202148437500
#
#Southall, B.L., Bowles, A.E., Ellison, W.T., Finneran, J.J., Gentry, R.L., Greene Jr, C.R., Kastak, D., Ketten, D.R., Miller, #J.H., Nachtigall, P.E. and Richardson, W.J., 2007. Overview. Aquatic mammals, 33(4), p.411.