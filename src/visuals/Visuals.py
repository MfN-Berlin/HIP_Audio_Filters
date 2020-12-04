# -*- coding: utf-8 -*-
'''
Created on 11.11.2020
Draw a spectrogram or waveform using ffmpeg or sox
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''
import os


class AbstractSpectro:
    """Base class for spectrogram plotters"""

    def outfile_path(self, infile, outpath):
        """Returns the path to the out file"""
        outfile = "%s/%s_spg.png" % (
            outpath,
            os.path.basename(infile).split(".")[0]
        )
        return outfile

    def draw(self, infile, outpath):
        """
        Draw spectrograms.
        """
        raise "Abstract method"


class SoxSpectro(AbstractSpectro):
    """
    Draw spectrograms using sox (http://sox.sourceforge.net/).
    """

    def draw(self, infile, outpath):
        """
        Draw spectrograms using sox (http://sox.sourceforge.net/).
        """
        outfile = self.outfile_path(infile, outpath)

        command = "sox %s -n remix 1 spectrogram -x 630 -y 80 -l -m -c "" -a -r -o %s" % (
            infile,
            outfile
        )
        os.system(command)


class FfmpegSpectro(AbstractSpectro):
    """
    Draw spectrograms using ffmpeg (https://ffmpeg.org/ffmpeg-filters.html#showspectrumpic).
    """

    def draw(self, infile, outpath):
        """
        Draw spectrograms using ffmpeg (https://ffmpeg.org/ffmpeg-filters.html#showspectrumpic).
        """
        outfile = self.outfile_path(infile, outpath)

        command = "ffmpeg -i %s -lavfi showspectrumpic=s=630x80:legend=0:gain=.5:color=8 %s" % (
            infile,
            outfile
        )
        os.system(command)


class AbstractWave:
    """Base class for waveform plotters"""

    def outfile_path(self, infile, outpath):
        """Returns the path to the out file"""
        outfile = "%s/%s_wave.png" % (
            outpath,
            os.path.basename(infile).rsplit(".", 1)[0]
        )
        return outfile

    def draw(self, infile, outpath):
        """
        Draw spectrograms.
        """
        raise "Abstract method"


class FfmpegWave(AbstractWave):
    """
    Draw spectrograms using ffmpeg (https://ffmpeg.org/ffmpeg-filters.html#showspectrumpic).
    """

    def draw(self, infile, outpath):
        """
        Draw spectrograms using ffmpeg (https://ffmpeg.org/ffmpeg-filters.html#showspectrumpic).
        """
        outfile = self.outfile_path(infile, outpath)

        command = "ffmpeg -i %s -lavfi showwavespic=s=630x80:colors=blue %s" % (
            infile,
            outfile
        )
        os.system(command)
