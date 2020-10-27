library(tuneR)
library(ggplot2)

# The filter is constructed based on the audiogram:
#
# * As the recordings' sample rate tops at 48 kHz, the highest filter band is 24 kHz. 
#   The lowest filter band is at 10Hz, which is a realistic lower limit for a recording.
# 
# * For each EQ band, the audiogram value corresponding to the EQ band is computed by interpolating the 
#   audiogram data using a fit function 
#   ([loess](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/loess))
# 
# * Values outside the measurements in the audiogram have to be extrapolated to construct the filter
#   (otherwise they would not be filtered)
# 
# * Equalization steps are spaced in 1 octave intervals (there are 11 octaves between 10Hz and 24kHz)
# 
# * For each EQ step, the filter gain is calculated relatively to the best overall hearing performance in 
#   the audiogram
# 


###################################
#
# Defining the filter values
#
###################################
def_filter <- function(audiogram) {
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

###############################################
#
# Plot the filter values
#
###############################################

plot_filter <- function(filter.table) {
    ggplot(data=filter.table) +
        geom_smooth(aes(Frequency.in.kHz, Gain.in.dB), color="blue", se=FALSE, fullrange=TRUE) +
        geom_point(aes(Frequency.in.kHz, Gain.in.dB), color="blue") +
        geom_label(aes(Frequency.in.kHz, Gain.in.dB, 
                   label=paste(Frequency.in.kHz, "kHz\n" ,Gain.in.dB,"dB")),
                   nudge_x = 0.3, nudge_y=-3) +
        labs(x = "Frequency (kHz)", y = "Weighting (dB)") +
        scale_y_continuous(limits=c(-50, 0)) +
        scale_x_log10(limits=c(0.01, 100)) +
        theme_bw() +
        annotation_logticks(sides="b")  
}

###############################################
#
# Plot the filtered data and the filter values
#
###############################################

plot_filter_fft <- function(fft, filter.table) {
    test <- data.frame(fft$freqArray, 10*log10(fft$power)) # 10*log10(fft$power)
    colnames(test) <- c("x", "y")

    # plot the filtered data and the filter values
    ggplot() +
        geom_line(data=test, 
                  aes(x, y + 40), color="grey") + # add 40 dB to test sound
        geom_smooth(data=filter.table, 
                    aes(Frequency.in.kHz*1000, Gain.in.dB), color="blue", se=FALSE, fullrange=TRUE) +
        geom_point(data=filter.table, 
                   aes(Frequency.in.kHz*1000, Gain.in.dB), color="blue") +
        geom_label(data=filter.table, 
                   aes(Frequency.in.kHz*1000, Gain.in.dB, 
                   label=paste(Frequency.in.kHz, "kHz\n" ,Gain.in.dB,"dB")),
                   nudge_x = 0.3, nudge_y=-3) +
        labs(x = "Frequency (Hz)", y = "Weighting (dB)") +
        scale_y_continuous(limits=c(-50, 0)) +
        scale_x_log10(limits=c(10, 24000)) +
        theme_bw() +
        annotation_logticks(sides="b")  
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
    paste("sox", inputfile, outputfile, eq_string)
}

# References
#Carcagno, S. (2013) Basic Sound Processing with R. 
# http://samcarcagno.altervista.org/blog/basic-sound-processing-r/?doing_wp_cron=1601298903.9209051132202148437500